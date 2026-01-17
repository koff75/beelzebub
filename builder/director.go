package builder

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/mariocandela/beelzebub/v3/parser"
	"github.com/mariocandela/beelzebub/v3/plugins"
	"github.com/mariocandela/beelzebub/v3/tracer"

	amqp "github.com/rabbitmq/amqp091-go"
	log "github.com/sirupsen/logrus"
)

type Director struct {
	builder *Builder
}

func NewDirector(builder *Builder) *Director {
	return &Director{
		builder: builder,
	}
}

func (d *Director) BuildBeelzebub(beelzebubCoreConfigurations *parser.BeelzebubCoreConfigurations, beelzebubServicesConfiguration []parser.BeelzebubServiceConfiguration) (*Builder, error) {
	d.builder.beelzebubServicesConfiguration = beelzebubServicesConfiguration
	d.builder.beelzebubCoreConfigurations = beelzebubCoreConfigurations
	if err := d.builder.buildLogger(beelzebubCoreConfigurations.Core.Logging); err != nil {
		return nil, err
	}

	d.builder.setTraceStrategy(d.standardOutStrategy)

	if beelzebubCoreConfigurations.Core.Tracings.RabbitMQ.Enabled {
		d.builder.setTraceStrategy(d.rabbitMQTraceStrategy)
		err := d.builder.buildRabbitMQ(beelzebubCoreConfigurations.Core.Tracings.RabbitMQ.URI)
		if err != nil {
			return nil, err
		}
	}

	if beelzebubCoreConfigurations.Core.BeelzebubCloud.Enabled {
		d.builder.setTraceStrategy(d.beelzebubCloudStrategy)
	}

	return d.builder.build(), nil
}

func (d *Director) standardOutStrategy(event tracer.Event) {
	log.WithFields(log.Fields{
		"status": event.Status,
		"event":  event,
	}).Info("New Event")

	if lokiURL := os.Getenv("LOKI_URL"); lokiURL != "" {
		go pushToLoki(lokiURL, event)
	}
}

// pushToLoki sends the event to Loki's push API so Grafana/Loki dashboards can display it.
// LOKI_URL should be the Loki base URL (e.g. http://loki.railway.internal:3100).
func pushToLoki(lokiURL string, event tracer.Event) {
	defer func() {
		if r := recover(); r != nil {
			log.Warnf("loki push: panic recovered: %v", r)
		}
	}()
	line := lokiLogLine{
		Msg:             event.Msg,
		SourceIp:        event.SourceIp,
		RequestURI:      event.RequestURI,
		UserAgent:       event.UserAgent,
		HTTPMethod:      event.HTTPMethod,
		Body:            event.Body,
		Headers:         event.Headers,
		Handler:         event.Handler,
		Description:     event.Description,
		DateTime:        event.DateTime,
		ID:              event.ID,
		HostHTTPRequest: event.HostHTTPRequest,
		Protocol:        event.Protocol,
		Status:          event.Status,
	}
	lineJSON, err := json.Marshal(line)
	if err != nil {
		log.Debugf("loki push: marshal log line: %v", err)
		return
	}

	pushURL := lokiURL
	if !strings.Contains(lokiURL, "/loki/api/v1/push") {
		pushURL = strings.TrimSuffix(lokiURL, "/") + "/loki/api/v1/push"
	}

	ts := fmt.Sprintf("%d", time.Now().UnixNano())
	payload := map[string]interface{}{
		"streams": []map[string]interface{}{
			{
				"stream": map[string]string{"service": "beelzebub"},
				"values": [][]string{{ts, string(lineJSON)}},
			},
		},
	}
	body, err := json.Marshal(payload)
	if err != nil {
		log.Debugf("loki push: marshal payload: %v", err)
		return
	}

	resp, err := http.Post(pushURL, "application/json", bytes.NewReader(body))
	if err != nil {
		log.Warnf("loki push: %v", err)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		log.Warnf("loki push: status %d from %s", resp.StatusCode, pushURL)
	}
}

type lokiLogLine struct {
	Msg             string `json:"msg"`
	SourceIp        string `json:"source_ip"`
	RequestURI      string `json:"request_uri"`
	UserAgent       string `json:"user_agent"`
	HTTPMethod      string `json:"http_method"`
	Body            string `json:"body,omitempty"`
	Headers         string `json:"headers,omitempty"`
	Handler         string `json:"handler,omitempty"`
	Description     string `json:"description,omitempty"`
	DateTime        string `json:"datetime,omitempty"`
	ID              string `json:"id,omitempty"`
	HostHTTPRequest string `json:"host,omitempty"`
	Protocol        string `json:"protocol,omitempty"`
	Status          string `json:"status,omitempty"`
}

func (d *Director) beelzebubCloudStrategy(event tracer.Event) {
	log.WithFields(log.Fields{
		"status": event.Status,
		"event":  event,
	}).Info("New Event")

	if lokiURL := os.Getenv("LOKI_URL"); lokiURL != "" {
		go pushToLoki(lokiURL, event)
	}

	conf := d.builder.beelzebubCoreConfigurations.Core.BeelzebubCloud

	beelzebubCloud := plugins.InitBeelzebubCloud(conf.URI, conf.AuthToken, false)

	result, err := beelzebubCloud.SendEvent(event)
	if err != nil {
		log.Error(err.Error())
	} else {
		log.WithFields(log.Fields{
			"status": result,
			"event":  event,
		}).Debug("Event published on beelzebub cloud")
	}
}

func (d *Director) rabbitMQTraceStrategy(event tracer.Event) {
	log.WithFields(log.Fields{
		"status": event.Status,
		"event":  event,
	}).Info("New Event")

	if lokiURL := os.Getenv("LOKI_URL"); lokiURL != "" {
		go pushToLoki(lokiURL, event)
	}

	eventJSON, err := json.Marshal(event)
	if err != nil {
		log.Error(err.Error())
		return
	}

	publishing := amqp.Publishing{ContentType: "application/json", Body: eventJSON}

	if err = d.builder.rabbitMQChannel.PublishWithContext(context.TODO(), "", RabbitmqQueueName, false, false, publishing); err != nil {
		log.Error(err.Error())
	} else {
		log.WithFields(log.Fields{
			"status": event.Status,
			"event":  event,
		}).Debug("Event published")
	}
}
