#!/bin/bash
# This is the test run

SG_ID "sg-0b0c61a02e2106b1f" # replace with your security group id
AMI_ID "ami-0220d79f3f480ecf5" # replace with your AMI id


for instance in $0
do
    aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t3.micro --tag-specifications 
    "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Reservations[0].Instances[0].InstanceId[0].
    PrivateIpAddress' --output text 
    done


