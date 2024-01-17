# BLFU Processing

1. `dcm2bids` scripts
2. `BIDS1_to_2.sh`: Merges attempts and saves them to `BIDS2/`, this is the
    working directory.
3. `fmriprep` scripts

## DCM2BIDS

Relies on `3TME_XA30_ME4_NORDIC_16bit_maton_PA_Pha_part[12].json` files.
Note that I copied my own nordic files for debugging so I could set the log 
directory.

### dcm2bids3-part1-sub_ses.sh

Takes `dicom_dir`, `sub_label`, and `ses_label` and writes to `BIDS/`. Takes up
to an hour or so depending on how many func files there are. 

After this script is done, there will only be `part-mag` files in `func/`.

### dcm2bids3-submit-part1-all.sh

Loops over my dicoms dir, extracts sub and ses labels from directory name,
and runs conversion script if output directory does not exist in `BIDS/`.

### dcm2bids3-part2-sub_ses.sh

Takes identical arguments to `part1`. Converts phase files and runs one
sbatch script per mag/phase pair to run NORDIC. They are submitted with 
`sbatch --wait`, which means this script does not exit until all runs are done.
Takes 15-45 minutes (excluding queue time).

### dcm2bids3-submit-part2-all.sh

Loops over `BIDS/` and identifies sessions that are ready to be converted. 
If there are no `part-mag` files, it assumes it is converted and skips it.
Because I have few sessions (33) I just let it run in sequence, but would need
to be parallelized to handle many more sessions.

### BIDS1_to_2.sh

The `BLFU` sessions have two attempts: `A1` and `A2`. This script combines those
and removes the `A.` label from all sessions and copies them to `BIDS2`. 
It skips those that still have any `part-` files remaining. Relies on 
`combine_bids_sessions`. 

## FMRIPREP
