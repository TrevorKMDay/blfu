#!/bin/bash

# Set up the pipeline
faird_code=/home/faird/shared/code
faird_pls=${faird_code}/external/pipelines/
fmriprep=${faird_pls}/fmriprep/fmriprep_23.1.4.sif

echo "Start time: $(date)"
echo "FMRIPREP: ${fmriprep}"
echo

if [ ${#} -eq 2 ] ; then
    sub=${1}
    ses=${2}
else
    echo "Usage: ${0} sub ses"
    exit 1
fi

BLFU_BIDS=/home/feczk001/shared/projects/BLFU/BIDS2
ses_dir="${BLFU_BIDS}/sub-${sub}/ses-${ses}"

# Check for if any part-mag files exist, if they do, the BIDS conversion isn't
#   complete
n_part_mag=$(find "${ses_dir}" -name "*part-mag*" | wc -l)
if [ "${n_part_mag}" -gt 0 ] ; then

    echo -n "Found part-mag files in ${ses_dir}; BIDS conversion incomplete, "
    echo    "not starting fmriprep"
    exit 1

fi

if [ ! -d "${ses_dir}/func" ] ; then

    echo "INFO: ${ses_dir} lacks func/ dir, setting anat-only"
    func=0

else

    func=1

fi

sbatch \
    --time=48:00:00         \
    -n 32                   \
    --mem=480GB             \
    --partition=msibigmem   \
    -J "${sub}_${ses}_fmriprep"    \
    /home/feczk001/shared/projects/BLFU/code/fmriprep-run-sub_ses.sh \
        "${sub}" "${ses}" ${func}
