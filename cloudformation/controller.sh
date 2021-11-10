#!/bin/bash

STACK_CMD=$1
STACK_NAME=$2
STACK_DEF=file://templates/$STACK_NAME/stack-definition.json
PARAMETERS_FILE=file://templates/$STACK_NAME/parameters.json
TS=$(date +"%s")


echo $TIMESTAMP
if [ $STACK_CMD == "create-stack" ]
then
    ## Create stack
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body $STACK_DEF \
        --parameters $PARAMETERS_FILE
fi


if [ $STACK_CMD == "execute-change-set" ]
then
    ## Create change set
    aws cloudformation create-change-set \
            --stack-name $STACK_NAME \
            --template-body $STACK_DEF \
            --change-set-name $STACK_NAME-changeset-$TS \
            --parameters $PARAMETERS_FILE

    ## Execute change-set
    aws cloudformation execute-change-set \
            --stack-name $STACK_NAME \
            --change-set-name $STACK_NAME-changeset-$TS
fi

if [ $STACK_CMD == "delete-stack" ]
then
    ## Delete stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME
fi