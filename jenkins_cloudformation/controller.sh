#!/bin/bash

STACK_NAME="namefacedude"
KEY_NAME="namefacedude-key"

## Get current IP address
MY_IP=$(curl --silent http://checkip.amazonaws.com/)

## Validate IP address (makes sure Route 53 doesn't get updated with a malformed payload)
if [[ ! $MY_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	exit 1
fi

## Remove the existing key if it exists
rm -rf $KEY_NAME.pem

## Create key pair
aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    --tag-specifications "ResourceType=key-pair,Tags=[{Key=StackName,Value=$STACK_NAME}]" \
    --query "KeyMaterial" \
    --output text > $KEY_NAME.pem

## Set permissions
chmod 400 $KEY_NAME.pem

aws cloudformation deploy \
    --template-file vpc.json \
    --stack-name $STACK_NAME \
    --parameter-overrides StackName=$STACK_NAME, MyIpAddress=$MY_IP