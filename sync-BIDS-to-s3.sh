#!/bin/bash

bucket=s3://blfu

s3cmd sync /home/feczk001/shared/projects/BLFU/BIDS2/sub-* ${bucket}/BIDS/
