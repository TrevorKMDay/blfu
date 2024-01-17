#!/bin/bash

BLFU=/home/feczk001/shared/projects/BLFU
config_part2=${BLFU}/code/3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part2.json

dicoms=$(find ${BLFU}/dicoms/ -mindepth 1 -maxdepth 1 -type d)

for dicom in ${dicoms} ; do

    bn=$(basename "${dicom}")

    # Use 6-digit ID to not capture session ID, which also can start with
    #   BLFU
    sub=$(echo "${bn}" | grep -o "BLFU[0-9][0-9][0-9][0-9][0-9][0-9]")

    # Use extended regex to capture BLFU/ERS
    ses1=$(echo "${bn}" | grep -Eo "(BLFU|ERS)[123][AB]?_A[12]$")
    ses2=${ses1//_/}

    sub_ses_func=${BLFU}/BIDS/sub-${sub}/ses-${ses2}/func

    part_mag=$(find "${sub_ses_func}" -name "*part-mag*.nii.gz" 2>/dev/null)
    n_part_mag=$(echo ${part_mag} | wc -w)

    # echo -e "${sub} ${ses2} ${n_part_mag}"

    if [ "${n_part_mag}" -gt 0 ] ; then
        echo rm -rf ${BLFU}/BIDS/sub-${sub}/ses-${ses2}
    fi

done