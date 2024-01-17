#!/bin/bash

BLFU=/home/feczk001/shared/projects/BLFU/
BIDS=${BLFU}/BIDS

dicoms=$(find ${BLFU}/dicoms/ -mindepth 1 -maxdepth 1 -type d)

echo "Found $(echo ${dicoms} | wc -w) dicom dirs"

n=1
for dicom in ${dicoms} ; do

    bn=$(basename "${dicom}")
    # Use 6-digit ID to not capture session ID, which also can start with
    #   BLFU
    sub=$(echo "${bn}" | grep -o "BLFU[0-9][0-9][0-9][0-9][0-9][0-9]")

    # Use extended regex to capture BLFU/ERS
    #   Session prefixes: BLFU or ERS,
    #   Each can be part of wave 1, 2, 3
    #   One subject has waves 2A and B
    #   Each dicom has an attempt, but no A2s for ERS
    ses1=$(echo "${bn}" | grep -Eo "(BLFU|ERS)[123][AB]?_A[12]$")
    ses2=${ses1//_/}

    BIDS_out_dir="${BIDS}/sub-${sub}/ses-${ses2}/"
 
    echo ${n} ${sub} ${ses1}

    if [ -e "${BIDS_out_dir}" ] ; then

        echo "${BIDS_out_dir} already exists!"

    else

        echo "Directory for sub-${sub} ses-${ses2} doesn't exist!"

        sbatch ${BLFU}/code/dcm2bids3-part1-sub_ses.sh \
            "${dicom}" "${sub}" "${ses2}"

        # break
    
    fi

    n=$(( n + 1 ))

done