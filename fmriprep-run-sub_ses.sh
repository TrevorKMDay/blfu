#!/bin/bash

# References:

# DCAN fmriprep RTD:
#   https://data-processing-handbook.readthedocs.io/en/latest/pipelines/
# fmriprep RTD: https://fmriprep.org/en/stable/

# Set up the pipeline
faird_code=/home/faird/shared/code
faird_pls=${faird_code}/external/pipelines/
fmriprep=${faird_pls}/fmriprep/fmriprep_23.1.4.sif

echo "Start time: $(date)"
echo "FMRIPREP: ${fmriprep}"
echo

if [ ${#} -eq 3 ] ; then
    sub=${1}
    ses=${2}
    func=${3}
else
    echo "Usage: ${0} sub ses func[0/1]"
    exit 1
fi

# Freesurfer license
fs_lic=${faird_code}/external/utilities/freesurfer_license/license.txt

# Sessions that have been NORDIC'd, combined across attempts and anats copied
#   from BLFU to ERS, where applicable
# BLFU_BIDS=/home/feczk001/shared/projects/BLFU/BIDS2

# Only one sub/ses
BLFU_BIDS=/home/feczk001/shared/projects/BLFU/BIDS2
BLFU_out=/home/feczk001/shared/projects/BLFU/fmriprep_out2

if [ ! -d "${BLFU_BIDS}/sub-${sub}/" ] ; then
    echo " -- ERROR: participant sub-${sub} does not exist in ${BLFU_BIDS}"
    exit 1
fi

if [ ! -d "${BLFU_BIDS}/sub-${sub}/ses-${ses}" ] ; then
    echo -n " -- ERROR: participant sub-${sub} ses-${ses} does not exist in "
    echo    "${BLFU_BIDS}"
    exit 1
fi

tmp_BIDS=$(mktemp -d /tmp/BIDS.XXXX)
tmp_out=$(mktemp -d /tmp/fmriprep_out.XXX)

echo " -- Copying sub-${sub} ses-${ses} to sham BIDS dir: ${tmp_BIDS}"
echo " -- Done copying at: $(date)"

mkdir -p "${tmp_BIDS}/sub-${sub}"
cp -r ${BLFU_BIDS}/dataset_description.json "${tmp_BIDS}/"

rsync -r --progress "${BLFU_BIDS}/sub-${sub}/ses-${ses}" \
    "${tmp_BIDS}/sub-${sub}"

# Delete README files from merge from temp dir
find "${tmp_BIDS}/sub-${sub}" -name "README" -delete

mkdir -p ${BLFU_out}

# Following option suggestions in DCAN fmriprep RTD

#   "participant" as pos arg is processing stage to be run - only "participant"
#       is available for fmriprep

echo "Starting singularity run: $(date)"

if [ "${func}" -eq 1 ] ; then
    anat_only_flag=""
else
    echo "Setting anat-only"
    anat_only_flag="--anat-only"
fi

singularity run --cleanenv                      \
    -B "${tmp_BIDS}":/data:ro                   \
    -B "${tmp_out}":/out                          \
    -B ${fs_lic}:/opt/freesurfer/license.txt    \
    -B /tmp:/work                               \
    ${fmriprep}                                 \
        /data /out participant                  \
        --participant-label     "${sub}"        \
        --cifti-output          "91k"           \
        --fd-spike-threshold    0.2             \
        --nprocs                "32"            \
        --omp-nthreads          "3"             \
        --stop-on-first-crash                   \
        --work-dir              /work           \
        ${anat_only_flag}                       \
        -vvv

echo "$(date): Singularity run finished at with exit code ${?}"

echo "Starting upload"

s3=s3://blfu.fmriprep

s3cmd sync -F "${tmp_out}"/* "${s3}/sub-${sub}_ses-${ses}/"

echo "$(date): s3 upload finished at with exit code ${?}"