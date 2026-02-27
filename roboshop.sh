#!/bin/bash
# This is the test run

SG_ID="sg-0b0c61a02e2106b1f" # replace with your security group id
AMI_ID="ami-0220d79f3f480ecf5" # replace with your AMI id
ZONE_ID="Z05277511KWWUC7XA3P5L" # replace with your hosted zone id Z05277511KWWUC7XA3P5L
DOMAIN_NAME="www.baludevops.online.com" # replace with your domain name


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
      RECORD_NAME="$instance.$DOMAIN_NAME" # baludevops.online.com
    else
      IP=$(
        aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text
      )
      RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.baludevops.online.com
     
   fi  
   echo "IP Address :$IP" 

   aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch
 { 
    
    "Comment": "updating record ",
    "Changes": [
      {
      "Action": "UPDATE",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
          ]
      }
      }
    ]
  }
  echo "Record updated for $instance" 
done
