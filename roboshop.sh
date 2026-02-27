#!/bin/bash
# This is the test run

SG_ID="sg-0b0c61a02e2106b1f" # replace with your security group id
AMI_ID="ami-0220d79f3f480ecf5" # replace with your AMI id
for instance in $@

do
    INSTANCE_ID=$(aws ec2 run-instances \
   --image-id $AMI_ID \
   --instance-type "t3.micro" \
   --security-group-ids $SG_ID \
   --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
   --query 'Instances[0].InstanceId' \
   --output text )

   if [ $instance == "frontend" ]; then
      IP=$(
        aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text
      )
    else
      IP=$(
        aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text
      )     
   fi  
   echo "IP Address :$IP"   
done
