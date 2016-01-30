#!/bin/bash
set -ex

echo "Usage: ./create-raspberry.sh [Rxxx]"
echo " where xxx is the Raspberry device number"

THING_NAME="$1"
if [ -z "$THING_NAME" ]; then
  echo "Missing thing name argument"
  exit 1
fi

# Create the thing and its certificate
aws iot create-thing --thing-name "$THING_NAME"
CERT=$(aws iot create-keys-and-certificate --set-as-active \
  --certificate-pem-outfile "certificate.pem.crt" --private-key-outfile "private.pem.key")
CERT_ARN=$(echo "$CERT" | jq -r .certificateArn)
aws iot attach-thing-principal --thing-name "$THING_NAME" --principal "$CERT_ARN"

# Attach general raspberry.policy to the created certificate
aws iot attach-principal-policy --policy-name raspberry.policy --principal "$CERT_ARN"
