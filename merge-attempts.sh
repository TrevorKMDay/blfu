#!/bin/bash


BLFU=/home/feczk001/shared/projects/BLFU/
code=${BLFU}/code

BIDS=${1}
sub=${2}
A1=${3}
A2=${4}
new_ses=${5}

cp -u ${code}/dataset_description.json "${BIDS}"

combine_bids_session=${code}/combine_bids_sessions/run.py

python3 ${combine_bids_session}             \
    "${BIDS}"                               \
    "${sub}"                                \
    --session-list      "${A1}" "${A2}"     \
    --new-session-name  "${new_ses}"        \
    --bold-entities     task echo