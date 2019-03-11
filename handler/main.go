package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/GSA/grace-customer/handler/request"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/caarlos0/env"
)

var defaultRegion = "us-east-1"

type config struct {
	Bucket   string `env:"GRACE_CUSTOMER_BUCKET,required"`
	KmsKeyID string `env:"GRACE_CUSTOMER_KMS_KEY,required"`
	Prefix   string `env:"GRACE_CUSTOMER_PREFIX" envDefault:"new"`
}

func handler(ctx context.Context, sqsEvent events.SQSEvent) error {
	var cfg config
	err := env.Parse(&cfg)
	if err != nil {
		log.Fatalf("failed to parse environment variables: %v", err)
	}
	for _, message := range sqsEvent.Records {
		log.Printf("The message %s for event source %s = %s \n", message.MessageId, message.EventSource, message.Body)
		req := new(request.Request)
		err := json.Unmarshal([]byte(message.Body), req)
		if err != nil {
			log.Printf("Not a valid request: %s", message.Body)
			log.Printf("Error: %v", err)
		}
		err = uploadRequest(cfg.Bucket, cfg.Prefix, cfg.KmsKeyID, req)
		if err != nil {
			log.Fatalf("failed to upload request to s3: %v\n", err)
		}
		log.Printf("Uploaded request to %s, lambda will process from here", cfg.Bucket)
	}
	return nil
}

func uploadRequest(bucket string, prefix string, kmsKeyID string, req *request.Request) error {
	sess := session.New(&aws.Config{Region: &defaultRegion})
	svc := s3.New(sess)
	buf := bytes.Buffer{}
	err := json.NewEncoder(&buf).Encode(req)
	if err != nil {
		return fmt.Errorf("failed to encode request as JSON: %v", err)
	}
	var sseKeyID *string
	var sseType *string

	if len(kmsKeyID) > 0 {
		sseKeyID = &kmsKeyID
		sseType = aws.String("aws:kms")
	}
	_, err = svc.PutObject(&s3.PutObjectInput{
		Key:                  aws.String(fmt.Sprintf("%s/%s", prefix, req.ProjectName)),
		Bucket:               &bucket,
		Body:                 bytes.NewReader(buf.Bytes()),
		SSEKMSKeyId:          sseKeyID,
		ServerSideEncryption: sseType,
	})
	return err
}

func main() {
	lambda.Start(handler)
}
