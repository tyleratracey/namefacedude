#!/bin/bash
STACK_NAME="namefacedude"
SG_NAME="jenkins_sg"
KEY_NAME="jenkins_key"

VPC_ID="vpc-af53dfd2"
SUBNET_ID="subnet-d4656699"

IMAGE_ID="ami-02e136e904f3da870"
INSTANCE_COUNT="1"
INSTANCE_TYPE="t2.micro"

## Get current IP address
MY_IP=$(curl --silent http://checkip.amazonaws.com/)

## Validate IP address (makes sure Route 53 doesn't get updated with a malformed payload)
if [[ ! $MY_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	exit 1
fi

DEFAULT_VPC=`aws ec2 describe-vpcs \
                        --filters Name="is-default",Values="true" \
                        --query "Vpcs[*].VpcId" \
                        --output text`

DEFAULT_SUBNET=`aws ec2 describe-subnets \
                        --filters Name="vpc-id",Values=$DEFAULT_VPC \
                        `

## Clean up old security groups
OLD_SECURITY_GROUPS=`aws ec2 describe-security-groups \
                        --filters Name="tag:StackName",Values=$STACK_NAME \
                        --query "SecurityGroups[*].GroupId" \
                        --output text`


for SG_ID in $OLD_SECURITY_GROUPS; do
    aws ec2 delete-security-group \
        --group-id $SG_ID
done

## Clean up old key pairs
OLD_KEY_PAIRS=`aws ec2 describe-key-pairs \
                        --filters Name="tag:StackName",Values=$STACK_NAME \
                        --query "KeyPairs[*].KeyPairId" \
                        --output text`

for KEY_ID in $OLD_KEY_PAIRS; do
    aws ec2 delete-key-pair \
        --key-pair-id $KEY_ID
done

## Clean up old key pairs
OLD_INSTANCES=`aws ec2 describe-instances \
                        --filters Name="tag:StackName",Values=$STACK_NAME \
                        --query "Reservations[*].Instances[*].InstanceId" \
                        --output text`

for INSTANCE_ID in $OLD_INSTANCES; do
    aws ec2 delete-instance \
        --instance-id $INSTANCE_ID
done



## Create new security group
SG_GROUP_ID=`aws ec2 create-security-group \
                --group-name $SG_NAME \
                --description "Jenkins security group" \
                --tag-specifications "ResourceType=security-group,Tags=[{Key=StackName,Value=$STACK_NAME}]" \
                --vpc-id $VPC_ID \
                --query "GroupId" \
                --output text`

echo $SG_GROUP_ID

## Add SSH connectivity
aws ec2 authorize-security-group-ingress \
        --region us-east-1 \
        --group-id $SG_GROUP_ID \
        --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{"CidrIp"="$MY_IP/32","Description"="SSH"}]"

## Add TCP port 8080 connectivity
aws ec2 authorize-security-group-ingress \
        --region us-east-1 \
        --group-id $SG_GROUP_ID \
        --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges="[{"CidrIp"="0.0.0.0/0","Description"="TCP"}]"

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

## Terminate EC2


## Create EC2
#aws ec2 run-instances \
#    --image-id $IMAGE_ID \
#    --count $INSTANCE_COUNT \
#    --instance-type $INSTANCE_TYPE \
#    --key-name $KEY_NAME \
#    --security-group-ids $SG_GROUP_ID \
#    --subnet-id $SUBNET_ID \
#    --user-data file://install_jenkins.sh \
#    --tag-specifications 'ResourceType=instance,Tags=[{Key=StackName,Value=namefacedude}]'

