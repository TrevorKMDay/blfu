#!/bin/bash

fp_out=/home/feczk001/shared/projects/BLFU/fmriprep_out/

cd ${fp_out} || exit 1 

s3cmd sync --recursive * s3://blfu.fmriprep/
