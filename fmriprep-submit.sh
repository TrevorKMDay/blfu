#!/bin/bash

BLFU=/home/feczk001/shared/projects/BLFU
code=${BLFU}/code
BLFU_BIDS=/home/feczk001/shared/projects/BLFU/BIDS2

# if [ ${#} -eq 1 ] ; then
#     task=${1}
# else
#     echo "Usage: ${0} sub"
#     exit 1
# fi

# subs=$(echo BLFU{100619,710922,714783,800807,938316,961964})
subs=BLFU100619

for sub in ${subs} ; do

    sessions=$(find "${BLFU}/BIDS2/sub-${sub}" -type d -name "ses-*" \
                -exec basename {} \;)

    for ses in ${sessions} ; do

        echo "${sub} ${ses}"

        ses_dir="${BLFU_BIDS}/sub-${sub}/${ses}"
        if [ ! -d "${ses_dir}/func" ] ; then

            echo "INFO: ${ses_dir} lacks func/ dir, setting anat-only"
            func=0

        else

            func=1

        fi


        # sub_ses script takes sub/ses value only no prefix

        jfix=${sub//BLFU}_${ses//ses-}_fmriprep
        mkdir -p fmriprep_logs

        sbatch \
            --time=48:00:00         \
            -n 32                   \
            --mem=480GB             \
            --partition=msibigmem   \
            -o "fmriprep_logs/${jfix}.out"        \
            -e "fmriprep_logs/${jfix}.err"        \
            -J "${jfix}"            \
            ${code}/fmriprep-run-sub_ses.sh \
                "${sub//sub-/}" "${ses//ses-}" "${func}"


    done

done