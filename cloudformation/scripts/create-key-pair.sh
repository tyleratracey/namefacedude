#!bash

KEY_NAME="masterkey"
STACK_NAME="namefacedude"

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