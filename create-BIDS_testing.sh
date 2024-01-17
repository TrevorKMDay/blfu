#!/bin/bash

BIDS1=/home/feczk001/shared/projects/BLFU/BIDS
BIDS2=/home/feczk001/shared/projects/BLFU/BIDS2
BIDS_testing=/home/feczk001/shared/projects/BLFU/BIDS_testing

mkdir -p ${BIDS_testing}/sub-BLFU961964/ 

# cp -Ru ${BIDS2}/sub-BLFU938316/ses-ERS1 ${BIDS_testing}/sub-BLFU938316

echo "Starting copy ..."

cp -Ru ${BIDS2}/sub-BLFU961964/ses-ERS2 ${BIDS_testing}/sub-BLFU961964/ 
cp -u ${BIDS1}/dataset_description.json ${BIDS2}/

echo "Done"
