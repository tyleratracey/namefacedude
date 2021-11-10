#!bash

## Get current IP address
MY_IP=$(curl --silent http://checkip.amazonaws.com/)

## Validate IP address (makes sure it get updated with a malformed payload)
if [[ ! $MY_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Something wehnt wrong when trying to find your public IP address..."
	exit 1
fi

echo $MY_IP
