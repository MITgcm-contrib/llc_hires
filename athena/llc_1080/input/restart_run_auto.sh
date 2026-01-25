#!/usr/bin/env bash
TARGET_DIR="/nobackup/$USER/llc_1080/MITgcm/run_30x30/"
cd "$TARGET_DIR" || { echo "Directory not found"; exit 1; }
if ./check_run_success.sh; then
   echo "Proceeding to next stage"
   ./bump_diag_run.sh move_diags_noR.sh move_diags.sh
   ./move_diags_noR.sh
   ./create_R.sh
   ./move_diags.sh
   ./update_datacal.sh
   sleep 10 
   qsub llc1080_30x30x11152_asyncio_restart.sh 
else
   echo "Stopping pipeline"
   exit 1
fi

