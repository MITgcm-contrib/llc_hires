#!/bin/bash
#PBS -N shrink_by_folder
#PBS -q normal
#PBS -l select=30:ncpus=128:model=rom_ait
#PBS -l walltime=06:00:00
#PBS -l place=scatter
#PBS -j oe
#PBS -W group_list=s1353

set -euo pipefail

###############################################################################
# USER SETTINGS
###############################################################################
RUNDIR="$PBS_O_WORKDIR/shrink_${PBS_JOBID}"
mkdir -p "$RUNDIR"

SHRINK_EXE="${PBS_O_WORKDIR}/shrink"

# Manifest format, pipe-delimited:
# data_folder|theta_mask_file|u_mask_file|v_mask_file
MANIFEST="${PBS_O_WORKDIR}/mask_manifest_apr13.txt"

JOBS_PER_NODE=5
DRYRUN=0
MAX_FILES=0
DO_SETSTRIPE=0
STRIPE_COUNT=-1
STRIPE_SIZE=16M

###############################################################################
# SETUP
###############################################################################
cd "$PBS_O_WORKDIR"

echo "==== JOB INFO ===="
echo "Start time    : $(date)"
echo "Job ID        : ${PBS_JOBID:-unknown}"
echo "Submit host   : $(hostname)"
echo "Work dir      : $PBS_O_WORKDIR"
echo "Run dir       : $RUNDIR"
echo "Shrink exe    : $SHRINK_EXE"
echo "Manifest      : $MANIFEST"
echo "Jobs/node     : $JOBS_PER_NODE"
echo "Dry run       : $DRYRUN"
echo "Max files     : $MAX_FILES"
echo "Setstripe     : $DO_SETSTRIPE"
echo

###############################################################################
# BASIC CHECKS
###############################################################################
[[ -x "$SHRINK_EXE" ]] || { echo "ERROR: shrink executable missing or not executable: $SHRINK_EXE"; exit 1; }
[[ -f "$MANIFEST" ]]   || { echo "ERROR: manifest file missing: $MANIFEST"; exit 1; }

command -v parallel >/dev/null 2>&1 || { echo "ERROR: GNU parallel not found in PATH"; exit 1; }
command -v pbsdsh   >/dev/null 2>&1 || { echo "ERROR: pbsdsh not found in PATH"; exit 1; }
command -v mktemp   >/dev/null 2>&1 || { echo "ERROR: mktemp not found in PATH"; exit 1; }
command -v find     >/dev/null 2>&1 || { echo "ERROR: find not found in PATH"; exit 1; }

if [[ ! -s "$MANIFEST" ]]; then
    echo "ERROR: manifest is empty"
    exit 1
fi

###############################################################################
# BUILD RUN LIST
#
# Output format:
# mask|infile
###############################################################################
RUNLIST_RAW="${PBS_O_WORKDIR}/runlist.raw.${PBS_JOBID}.txt"
RUNLIST="${PBS_O_WORKDIR}/runlist.${PBS_JOBID}.txt"
BAD_MANIFEST="${PBS_O_WORKDIR}/bad_manifest.${PBS_JOBID}.txt"
: > "$RUNLIST_RAW"
: > "$BAD_MANIFEST"

while IFS='|' read -r FOLDER THETA_MASK U_MASK V_MASK; do
    [[ -z "${FOLDER// }" ]] && continue
    [[ "${FOLDER:0:1}" == "#" ]] && continue

    if [[ ! -d "$FOLDER" ]]; then
        echo "MISSING_FOLDER|$FOLDER" >> "$BAD_MANIFEST"
        continue
    fi
    [[ -f "$THETA_MASK" ]] || { echo "MISSING_THETA_MASK|$FOLDER|$THETA_MASK" >> "$BAD_MANIFEST"; continue; }
    [[ -f "$U_MASK"     ]] || { echo "MISSING_U_MASK|$FOLDER|$U_MASK" >> "$BAD_MANIFEST"; continue; }
    [[ -f "$V_MASK"     ]] || { echo "MISSING_V_MASK|$FOLDER|$V_MASK" >> "$BAD_MANIFEST"; continue; }

    find -L "$FOLDER" -maxdepth 1 -type f \( \
        -name 'Theta*.data' -o \
        -name 'Salt*.data'  -o \
        -name 'U*.data'     -o \
        -name 'V*.data'     -o \
        -name 'W*.data' \
    \) | sort | while IFS= read -r infile; do
        base="$(basename "$infile")"
        case "$base" in
            Theta*.data) echo "${THETA_MASK}|${infile}" >> "$RUNLIST_RAW" ;;
            Salt*.data)  echo "${THETA_MASK}|${infile}" >> "$RUNLIST_RAW" ;;
            U*.data)     echo "${U_MASK}|${infile}"     >> "$RUNLIST_RAW" ;;
            V*.data)     echo "${V_MASK}|${infile}"     >> "$RUNLIST_RAW" ;;
            W*.data)     echo "${THETA_MASK}|${infile}" >> "$RUNLIST_RAW" ;;
            *) echo "UNMATCHED_FILE|$infile" >> "$BAD_MANIFEST" ;;
        esac
    done

done < "$MANIFEST"

if [[ -s "$BAD_MANIFEST" ]]; then
    echo "ERROR: manifest/build problems found. See $BAD_MANIFEST"
    exit 1
fi

if [[ ! -s "$RUNLIST_RAW" ]]; then
    echo "ERROR: no matching .data files found from manifest folders"
    exit 1
fi

sort -u "$RUNLIST_RAW" > "${PBS_O_WORKDIR}/runlist.unique.${PBS_JOBID}.txt"

if [[ "$MAX_FILES" -gt 0 ]]; then
    head -n "$MAX_FILES" "${PBS_O_WORKDIR}/runlist.unique.${PBS_JOBID}.txt" > "$RUNLIST"
else
    cp "${PBS_O_WORKDIR}/runlist.unique.${PBS_JOBID}.txt" "$RUNLIST"
fi

NFILES=$(wc -l < "$RUNLIST")
echo "Validated unique input file count: $NFILES"
echo

###############################################################################
# OPTIONAL OUTPUT DIRECTORY STRIPING
###############################################################################
if [[ "$DO_SETSTRIPE" -eq 1 ]]; then
    echo "Applying directory striping to output directories..."
    awk -F'|' '
        {
            infile=$2
            out=infile
            sub(/\.data$/, ".shrunk", out)
            sub(/\/[^/]+$/, "", out)
            print out
        }
    ' "$RUNLIST" | sort -u > "outdirs.${PBS_JOBID}.txt"

    while IFS= read -r d; do
        [[ -z "$d" ]] && continue
        [[ -d "$d" ]] || continue
        lfs setstripe -c "$STRIPE_COUNT" -S "$STRIPE_SIZE" "$d" 2>/dev/null || true
    done < "outdirs.${PBS_JOBID}.txt"

    echo "Done with setstripe."
    echo
fi

###############################################################################
# NODE SLOT LIST: first PBS slot for each unique hostname
###############################################################################
awk '
    !seen[$0]++ { print NR-1 "|" $0 }
' "$PBS_NODEFILE" > "node_slots.${PBS_JOBID}.txt"

NNODES=$(wc -l < "node_slots.${PBS_JOBID}.txt")

if [[ "$NNODES" -lt 1 ]]; then
    echo "ERROR: no nodes found in PBS_NODEFILE"
    exit 1
fi

echo "Allocated unique nodes: $NNODES"
echo "First-slot map:"
cat "node_slots.${PBS_JOBID}.txt"
echo



###############################################################################
# NODE LIST
###############################################################################
sort -u "$PBS_NODEFILE" > "nodes.${PBS_JOBID}.txt"
NNODES=$(wc -l < "nodes.${PBS_JOBID}.txt")

if [[ "$NNODES" -lt 1 ]]; then
    echo "ERROR: no nodes found in PBS_NODEFILE"
    exit 1
fi

echo "Allocated unique nodes: $NNODES"
echo

###############################################################################
# PER-FILE WORKER
#
# args: SHRINK_EXE MASK INFILE DRYRUN
###############################################################################
cat > "do_shrink.${PBS_JOBID}.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

SHRINK_EXE="$1"
MASK="$2"
INFILE="$3"
DRYRUN="$4"

if [[ "$INFILE" != *.data ]]; then
    echo "BAD_SUFFIX $INFILE" >&2
    exit 17
fi

if [[ ! -f "$MASK" ]]; then
    echo "MISSING_MASK $MASK" >&2
    exit 18
fi

OUTFILE="${INFILE%.data}.shrunk"
OUTDIR="$(dirname "$OUTFILE")"
OUTBASE="$(basename "$OUTFILE")"

if [[ "$OUTFILE" == "$INFILE" ]]; then
    echo "REFUSING_SAME_IN_OUT $INFILE" >&2
    exit 14
fi

if [[ ! -f "$INFILE" ]]; then
    echo "MISSING_INPUT $INFILE" >&2
    exit 11
fi

if [[ ! -d "$OUTDIR" ]]; then
    echo "MISSING_OUTDIR $OUTDIR" >&2
    exit 12
fi

if [[ -e "$OUTFILE" ]]; then
    echo "SKIP_EXISTS $OUTFILE"
    exit 0
fi

if [[ "$DRYRUN" -eq 1 ]]; then
    echo "DRYRUN $MASK | $INFILE -> $OUTFILE"
    exit 0
fi

TMPOUT=$(mktemp "${OUTDIR}/.${OUTBASE}.tmp.XXXXXX") || {
    echo "MKTEMP_FAIL $OUTDIR" >&2
    exit 15
}

cleanup_tmp() {
    if [[ -n "${TMPOUT:-}" && -e "${TMPOUT:-}" ]]; then
        rm -f "$TMPOUT"
    fi
}
trap cleanup_tmp EXIT

if "$SHRINK_EXE" "$MASK" "$INFILE" "$TMPOUT"; then
    if [[ ! -s "$TMPOUT" ]]; then
        echo "EMPTY_TMP $TMPOUT" >&2
        exit 13
    fi

    if mv -n "$TMPOUT" "$OUTFILE"; then
        trap - EXIT
        echo "OK $MASK | $INFILE -> $OUTFILE"
        exit 0
    else
        echo "MOVE_CONFLICT $OUTFILE" >&2
        exit 16
    fi
else
    rc=$?
    echo "SHRINK_FAIL rc=$rc mask=$MASK file=$INFILE" >&2
    exit "$rc"
fi
EOF

chmod +x "do_shrink.${PBS_JOBID}.sh"

###############################################################################
# PER-NODE RUNNER
#
# Shard lines are: mask|infile
###############################################################################
cat > "node_runner.${PBS_JOBID}.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

SHRINK_EXE="$1"
RUNLIST="$2"
NODE_INDEX="$3"
NNODES="$4"
JOBS_PER_NODE="$5"
JOBID="$6"
DRYRUN="$7"
RUNDIR="$8"

HOST=$(hostname)
SHARD="${RUNDIR}/shard.${JOBID}.${NODE_INDEX}.txt"
LOG="${RUNDIR}/parallel.${JOBID}.${NODE_INDEX}.log"
STDERR_LOG="${RUNDIR}/parallel.${JOBID}.${NODE_INDEX}.stderr"
FAILS="${RUNDIR}/failed.${JOBID}.${NODE_INDEX}.txt"

awk -v idx="$NODE_INDEX" -v n="$NNODES" '
    NF > 0 && ((NR-1) % n) == idx { print }
' "$RUNLIST" > "$SHARD"

if [[ ! -s "$SHARD" ]]; then
    echo "Node index $NODE_INDEX on $HOST got empty shard" > "$LOG"
    : > "$FAILS"
    exit 0
fi

PAR_RC=0
parallel -j "$JOBS_PER_NODE" \
    --colsep '\|' \
    --joblog "$LOG" \
    "$PBS_O_WORKDIR/do_shrink.$JOBID.sh" \
    "$SHRINK_EXE" {1} {2} "$DRYRUN" \
    :::: "$SHARD" \
    2> "$STDERR_LOG" || PAR_RC=$?

grep -E 'BAD_SUFFIX|MISSING_MASK|MISSING_INPUT|MISSING_OUTDIR|EMPTY_TMP|SHRINK_FAIL|REFUSING_SAME_IN_OUT|MKTEMP_FAIL|MOVE_CONFLICT' \
    "$STDERR_LOG" > "$FAILS" || true

exit "$PAR_RC"
EOF

chmod +x "node_runner.${PBS_JOBID}.sh"

###############################################################################
# LAUNCH ONE RUNNER PER NODE
###############################################################################
echo "Launching one node_runner per node..."
pids_file="${RUNDIR}/pbsdsh_pids.${PBS_JOBID}.txt"
: > "$pids_file"

i=0
while IFS='|' read -r slot _node; do
    pbsdsh -n "$slot" bash "$PBS_O_WORKDIR/node_runner.${PBS_JOBID}.sh" \
        "$SHRINK_EXE" "$RUNLIST" "$i" "$NNODES" "$JOBS_PER_NODE" "$PBS_JOBID" "$DRYRUN" "$RUNDIR" &
    echo $! >> "$pids_file"
    i=$((i+1))
done < "node_slots.${PBS_JOBID}.txt"

TOP_RC=0
while IFS= read -r pid; do
    if ! wait "$pid"; then
        TOP_RC=1
    fi
done < "$pids_file"

echo "All node runners finished."
echo

###############################################################################
# SUMMARY
###############################################################################
cat "${RUNDIR}"/failed."${PBS_JOBID}".*.txt 2>/dev/null | sort -u > "failures.${PBS_JOBID}.txt" || true

NFAIL=0
if [[ -f "failures.${PBS_JOBID}.txt" ]]; then
    NFAIL=$(grep -c . "failures.${PBS_JOBID}.txt" || true)
fi

echo "==== SUMMARY ===="
echo "End time       : $(date)"
echo "Input files    : $NFILES"
echo "Failures       : $NFAIL"
echo "Failure file   : failures.${PBS_JOBID}.txt"
echo

if [[ "$NFAIL" -gt 0 || "$TOP_RC" -ne 0 ]]; then
    echo "There were failures. Inspect failures.${PBS_JOBID}.txt"
    exit 2
fi
