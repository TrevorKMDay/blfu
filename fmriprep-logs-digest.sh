#!/bin/bash

files=$(find fmriprep_logs/ -name "*.out")

ok_files=$(grep -l "Singularity run finished at .* with exit code 0" ${files})
bad_files=$(grep -lv "Singularity run finished at .* with exit code 0" ${files})

echo "Succesful runs:"

for f in ${ok_files} ; do

    sub=$(grep -o "BLFU[0-9][0-9][0-9][0-9][0-9][0-9]" "${f}" | sort -u)
    ses=$(grep -Eo "ses-(ERS|BLFU)[123][AB]?" "${f}" | sort -u)

    echo "${f} ${sub} ${ses}"

done