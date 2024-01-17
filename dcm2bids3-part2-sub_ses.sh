#!/bin/bash

#!/bin/bash

#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=16gb

# conda init bash
# conda activate dcm2bids3

if [[ ${CONDA_DEFAULT_ENV} != "dcm2bids3" ]] ; then
    echo "ERROR: Make sure to activate conda env dcm2bids3"
    exit 1
fi

if [ ${#} -eq 3 ] ; then
    dir=${1}
    sub=${2}
    ses=${3}
else
    echo "Usage: ${0} dir sub_label ses_label"
    echo "  No sub-/ses- prefix"
    exit 1
fi

BLFU=/home/feczk001/shared/projects/BLFU
# config_part2="${BLFU}/code/3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part2.json"
# config_part2="${BLFU}/code/3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part2-nopostop.json"
config_part2="${BLFU}/code/3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part2-mypostop.json"

dcm2bids \
    -d "${dir}"         \
    -p "${sub}"         \
    -s "${ses}"         \
    -c ${config_part2}  \
    -o ${BLFU}/BIDS     \
    -l INFO
