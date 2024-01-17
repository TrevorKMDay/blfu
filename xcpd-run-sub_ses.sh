#!/bin/bash

#SBATCH -J xcpd
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=240G
#SBATCH -t 3:00:00
#SBATCH -p msibigmem
#SBATCH --mail-type=ALL
#SBATCH --mail-user=day00096@umn.edu

module load singularity

BLFU=/home/feczk001/shared/projects/BLFU
fp_out=${BLFU}/fmriprep_out2
xcpd_out=${BLFU}/xcpd_out

# Set up the pipeline
faird_code=/home/faird/shared/code
# faird_pls=${faird_code}/external/pipelines/

xcpd=${BLFU}/code/singularity/xcp_d_0.5.2.sif

# Freesurfer license
fs_lic=${faird_code}/external/utilities/freesurfer_license/license.txt

if [ ${#} -eq 2 ] ; then
    sub=${1}
    ses=${2}
    task=restME
else
    echo "Usage: ${0} sub ses"
    exit 1
fi

sub_ses_fp=${fp_out}/ # sub-${sub}_ses-${ses}
sub_ses_out=${xcpd_out}/processed/ # sub-${sub}_ses-${ses}
sub_ses_work=${xcpd_out}/work_dir/ # sub-${sub}_ses-${ses}

fp_in=${sub_ses_fp}/sub-${sub}/ses-${ses}

if [ -d "${fp_in}" ] ; then
    echo "Input directory ${fp_in} exists!"
    echo
else
    echo "Input directory ${fp_in} doesn't exist!"
    exit 1
fi

# See:
#  https://data-processing-handbook.readthedocs.io/en/latest/pipelines/#5-xcp-d
#  https://xcp-d.readthedocs.io/en/latest/usage.html

# radius=50 # does radius do anything for fmriprep?
FD=0.3

# bandstop filters
#  see: https://xcp-d.readthedocs.io/en/latest/workflows.html

bs_min=20
bs_max=35

mkdir -p ${sub_ses_out} ${sub_ses_work}

# Update dd.json with master copy
# cp -u ${fp_out}/dataset_description.json ${sub_ses_out}

echo "XCPD: ${xcpd}"

singularity run --cleanenv \
    -B ${fs_lic}:/opt/freesurfer/license.txt    \
    -B ${sub_ses_fp}:/fmriprep_out              \
    -B ${sub_ses_out}:/xcpd_out                 \
    -B ${sub_ses_work}:/wkdir                   \
    ${xcpd}                             \
        --participant-label "${sub}"    \
        --task-id           ${task}     \
        --cifti                         \
        --fd-thresh         ${FD}       \
        --head-radius       auto        \
        --combineruns                   \
        --resource-monitor              \
        --dcan-qc                       \
        --omp-nthreads      3           \
        --despike                       \
        --motion-filter-type notch      \
            --band-stop-min ${bs_min}   \
            --band-stop-max ${bs_max}   \
        --warp-surfaces-native2std      \
        --work-dir          /wkdir      \
        --input-type        fmriprep    \
        /fmriprep_out                   \
        /xcpd_out                       \
        participant
        