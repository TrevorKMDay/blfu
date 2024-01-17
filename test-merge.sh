#!/bin/bash

BLFU=/home/feczk001/shared/projects/BLFU/
code=${BLFU}/code
BIDS=${BLFU}/BIDS
BIDS2=${BIDS}2

sub="BLFU800807"

${code}/merge-attempts.sh ${sub} BLFU1A{1,2} BLFU1
