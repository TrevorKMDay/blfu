#!/bin/bash

#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=16gb

# conda init bash
# conda activate dcm2bids3

if [ ${#} -eq 3 ] ; then
    dir=${1}
    sub=${2}
    ses=${3}
else
    echo "Usage: ${0} dir sub_label ses_label"
    echo "  No sub-/ses- prefix"
    exit 1
fi

# requires conda env: dcm2bids3

BLFU=/home/feczk001/shared/projects/BLFU
config=${BLFU}/code/3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part1.json

if [ -e "${dir}" ] ; then 
    echo "DIR EXISTS"
else 
    echo "DIR BAD" 
    exit 1 
fi

dcm2bids \
    -d "${dir}"         \
    -p "${sub}"         \
    -s "${ses}"         \
    -c ${config}        \
    -o ${BLFU}/BIDS     \
    -l DEBUG            
