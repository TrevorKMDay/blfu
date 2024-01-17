#!/bin/bash

module load python3

BLFU=/home/feczk001/shared/projects/BLFU/
code=${BLFU}/code
BIDS=${BLFU}/BIDS
BIDS2=${BIDS}2
combined=${BLFU}/niftis_desc-combined/

mkdir -p ${BIDS2}

# Subs with no retries
subs1=$(echo sub-BLFU{710922,714783,961964})
# subs with retries
subs2=$(echo sub-BLFU{800807,938316,100619})
subs="${subs1} ${subs2}"

force=false
while getopts f flag ; do 
    case "${flag}" in
        f) force=true ;;
    esac
done

echo "Subs identified:"
echo "  ${subs}"

cp_and_rm_A1 () {

    source_f=${1}
    target_dir=${2}

    source_bn=$(basename "${source_f}")
    source_modality=$(basename "$(dirname "${source_f}")")
    dest=${target_dir}/${source_modality}/${source_bn//A1/}

    mkdir -p "$(dirname "${dest}")"
    cp -u "${source_f}" "${dest}"

}

cp_A1 () {

    source=${1}
    target=${2}

    mkdir -p "${target}"

    files=$(find "${source}" -type f)

    for f in ${files} ; do cp_and_rm_A1 "${f}" "${target}" ; done

}

cp_anat_to_ERS () {

    source=${1}
    ers=${2}

    mkdir -p "${ers}/anat"

    files=$(find "${source}/anat" -type f)

    for f in ${files} ; do

        f_bn=$(basename "${f}")
        newname=${f_bn//ses-BLFU/ses-ERS}

        cp -u --no-clobber "${f}" "${ers}/anat/${newname}"

    done
}

for sub in ${subs} ; do

    echo
    echo "${sub}"

    # BLFU SESSIONS

    # Only BLFU sessions had A1/A2
    session=BLFU
    for wave in 1 2 2A 2B 3 ; do

        source_A1=${BIDS}/${sub}/ses-${session}${wave}A1
        source_A2=${BIDS}/${sub}/ses-${session}${wave}A2

        combined_out=${combined}/${sub}/ses-${session}${wave}
        BIDS2_out=${BIDS2}/${sub}/ses-${session}${wave}

        # If the session hasn't been acquired, skip it
        if [ ! -e  "${source_A1}" ] ; then continue ; fi

        # IF THE A2 DIR EXISTS, DO THE MERGE
        if [ -e "${source_A2}" ] ; then

            if [ "$(find "${source_A2}" -name "*part*" | wc -l)" -gt 0 ] ; then
                echo "ERROR: part files found in ${source_A2}, skipping."
                echo "Fix this dir."
                continue
            fi

            if [ -e "${combined_out}" ] ; then

                echo "    ${combined_out} already exists, not re-merging."
                echo "    Delete to merge again"

            else

                echo "Merging ${sub} ses-${session}${wave} A1 and A2"
                echo "  saving to: ${combined_out}"

                # Args: bids_dir sub_value sessions_to_merge new_session_name
                ${code}/merge-attempts.sh   \
                    ${BIDS}                 \
                    "${sub//sub-}"          \
                    ${session}${wave}A{1,2} \
                    ${session}${wave}

            fi

            if [ -e "${BIDS2_out}" ] & [[ ${force} == "false" ]]  ; then

                echo "    ${BIDS2_out} already exists."
                echo "    Delete to re-copy (or set -f)"
                echo "  Done with BLFU${wave}"

            else

                dest="${BIDS2}/${sub}/ses-${session}${wave}"

                rm -rf ${dest}

                # Copy nifti_desc-combined session dir to BIDS2 sub dir
                echo "    Copying ${combined_out} to ${BIDS2}/${sub}/"
                cp -R "${combined_out}" "${dest}"
                echo "  Done with BLFU${wave}"

                # Don't quote find to allow word separation
                python3 ${code}/set-IF.py \
                    --jsons "${dest}"/fmap/*.json \
                    --bolds "${dest}"/func/*.nii.gz

            fi

        else

            if [ "$(find "${source_A1}" -name "*part*" | wc -l)" -gt 0 ] ; then
                echo "ERROR: part files found in ${source_A1}, skipping."
                echo "Fix this dir."
            else

                # If there is only one attempt, no need to merge data - just
                #   copy it and remove 'A1'.
                cp_A1 "${source_A1}" "${BIDS2}/${sub}/ses-${session}${wave}"
                echo "  Done with BLFU${wave}"

            fi

        fi


    done

    # EXTENDED RESTING STATE

    session=ERS
    for wave in 1 2 3 ; do

        source_ers=${BIDS}/${sub}/ses-${session}${wave}A1
        target_ers=${BIDS2}/${sub}/ses-ERS${wave}

        # Skip sessions that don't exist
        if [ ! -e "${source_ers}" ] ; then continue ; fi

        if [ "$(find "${source_ers}" -name "*part*" | wc -l)" -gt 0 ] ; then
            echo "ERROR: part files found in ${source_ers}, skipping."
            echo "Fix this dir."
            continue
        fi

        # Copy ERSnA1 and remove the A1 suffix
        # ERSes never had an A2, but named for consistency
        cp_A1 "${source_ers}" "${target_ers}"

        if [ ! -d "${target_ers}/anat/" ] ; then

            # Copy corresponding anat files from BLFUn to ERSn if none were
            #   collected at the ERS visit
            cp_anat_to_ERS "${BIDS2}/${sub}/ses-BLFU${wave}" "${target_ers}"

        fi

        python3 ${code}/set-IF.py \
            --jsons "${target_ers}"/fmap/*.json \
            --bolds "${target_ers}"/func/*.nii.gz

        echo "  Done with ERS${wave}"

    done

done