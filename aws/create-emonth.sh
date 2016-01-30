#!/bin/bash
set -ex

echo "Usage: ./create-emonth.sh [ETxxx] [Rxxx] [NN]"
echo " where ETxxx is the Emonth device serial number"
echo "       Rxxx is the Raspberry device serial number, connected to the EmonTH sensor"
echo "       NN is the configured node number of the EmonTH device"

THING_NAME="$1"
RASP_THING="$2"
NODE_NUMBER="$3"
if [ -z "$THING_NAME" -o -z "$RASP_THING" -o -z "$NODE_NUMBER" ]; then
  echo "Missing arguments"
  exit 1
fi

# Create the thing, no certificate needed since Emonth in itself makes no connection to AWS IoT
aws iot create-thing --thing-name "$THING_NAME"

# Create the rules for the EmonTH device
COLLECT_RULE="$(cat emonth.collect.rule | sed s/Rxxx/${RASP_THING}/g | sed s/ETxxx/${THING_NAME}/g | sed s/NN/${NODE_NUMBER}/g)"
aws iot create-topic-rule --rule-name "${THING_NAME}_collect_rule" --topic-rule-payload "$COLLECT_RULE"

ARCHIVE_RULE="$(cat emonth.archive.rule | sed s/ETxxx/${THING_NAME}/g)"
aws iot create-topic-rule --rule-name "${THING_NAME}_archive_rule" --topic-rule-payload "$ARCHIVE_RULE"
