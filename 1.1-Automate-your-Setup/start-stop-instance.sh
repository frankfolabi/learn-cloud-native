#!/bin/bash

# Bash script to interactively start and stop AWS instance used for lab.
# Ensure AWS CLI and jq are installed
# Prompt user for region choice
echo "Select AWS region:"
echo "1) us-east-1"
echo "2) us-west-2"
read -rp "Enter option (1 or 2): " REGION_CHOICE

# Set region based on input
case "$REGION_CHOICE" in
  1)
    REGION="us-east-1"
    ;;
  2)
    REGION="us-west-2"
    ;;
  *)
    echo "Invalid choice. Defaulting to us-east-1"
    REGION="us-east-1"
    ;;
esac

echo "Using region: $REGION"

echo "Checking for the instances in $REGION region ..."

INSTANCE_ID=$(aws ec2 describe-instances \
    --region $REGION \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value]' \
    --output json | jq -r '.[0][0][0]')

echo "Do you want to start or stop the cloud lab instance? (start/stop)"
read -r ACTION
if [ "$ACTION" == "start" ]; then
    aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region $REGION
    echo "Starting instance $INSTANCE_ID..."

    HOST_ALIAS="cloudlab"
    SSH_CONFIG=~/.ssh/config

    echo "Waiting to get the public IP for instance $INSTANCE_ID ..."

    # Poll until public IP is available
    while true; do
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "$REGION" \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text)

    if [[ -n "$PUBLIC_IP" && "$PUBLIC_IP" != "None" ]]; then
        echo "Instance is ready. Public IP: $PUBLIC_IP"
        break
    else
        echo "Still waiting for public IP..."
        sleep 5
    fi
    done

    # Update HostName line in SSH config for this alias
    if grep -q "^Host $HOST_ALIAS" "$SSH_CONFIG"; then
    sed -i "/^Host $HOST_ALIAS$/,/^Host / s/^\s*HostName .*/  HostName $PUBLIC_IP/" "$SSH_CONFIG"
    echo "Updated HostName for $HOST_ALIAS to $PUBLIC_IP"
    else
    echo "Host $HOST_ALIAS not found in $SSH_CONFIG. Add it manually or use an append script."
    exit 1
    fi

    echo "SSH configuration now updated. Login to the instance on your terminal."


elif [ "$ACTION" == "stop" ]; then
    aws ec2 stop-instances --instance-ids "$INSTANCE_ID" --region $REGION
    echo "Stopping instance $INSTANCE_ID..."

else
    echo "Invalid action. Please enter 'start' or 'stop'."
fi


