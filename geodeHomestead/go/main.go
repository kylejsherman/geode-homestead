package main

import (
	"context"
	"log"

	runtime "github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

func HandleRequest(ctx context.Context) {
	log.Printf("Hello World! From %s. This is a change", lambdacontext.FunctionName)
}

func main() {
	runtime.Start(HandleRequest)
}
