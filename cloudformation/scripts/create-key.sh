#!bash

KEY_NAME=$1

## Create key pair
aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    --query "KeyMaterial" \
    --output text > $KEY_NAME.pem

## Set permissions
chmod 400 $KEY_NAME.pem