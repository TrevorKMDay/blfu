#!/bin/bash

BIDS=/home/elisonj/shared/BCP/UNC/UNC_BIDS/

for ses in "${BIDS}"/sub-*/ses-* ; do

    python IntendedFor_tkmd.py --ses "${ses}"

done