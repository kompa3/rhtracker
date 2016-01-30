#!/bin/bash
set -ex

# Create the universal raspberry.policy which will be attached to all Raspberry thing certificates
aws iot create-policy --policy-name raspberry.policy --policy-document file://raspberry.policy
