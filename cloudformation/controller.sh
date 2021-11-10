#!/bin/bash

STACK_CMD=$1
STACK_NAME=$2
STACK_DEF=file://templates/$STACK_NAME/stack-definition.json
PARAMETERS_FILE=file://templates/$STACK_NAME/parameters.json
#PARAMS=($(jq -r '.Parameters[] | [.ParameterKey, .ParameterValue] | "ParameterKey=\(.[0]),ParameterValue=\(.[1])"' ${PARAMETERS_FILE}))

if [ $STACK_CMD == "create-stack" ]
then
    ## Create stack
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body $STACK_DEF \
        --parameters $PARAMETERS_FILE
fi


if [ $STACK_CMD == "delete-stack" ]
then
    ## Delete stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME
fi