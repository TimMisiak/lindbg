#!/bin/sh
set -eu

# Path to the program you want to run
CRASHME_CMD="${CRASHME_CMD:-/app/crashme}"

# Where to put core dumps (root directory)
CORES_DIR="${CORES_DIR:-/cores}"

# Per-run timestamped directory for cores + artifacts
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
RUN_DIR="${CORES_DIR}/${TS}"
mkdir -p "$RUN_DIR"

# Best-effort extraction of the binary path from CRASHME_CMD (first word)
CRASHME_BIN=$(printf '%s\n' "$CRASHME_CMD" | awk '{print $1}')

echo "Using run directory: $RUN_DIR"

# Signal handling
term_handler() {
    # Forward termination to children if they exist
    if [ "${CRASHME_PID-}" != "" ]; then
        kill "$CRASHME_PID" 2>/dev/null || true
    fi
    if [ "${PROCDUMP_PID-}" != "" ]; then
        kill "$PROCDUMP_PID" 2>/dev/null || true
    fi
}
trap term_handler TERM INT

# Start crashme in the background (it waits for SIGUSR1)
$CRASHME_CMD &
CRASHME_PID=$!
echo "Started crashme with pid=$CRASHME_PID"

# Start procdump attached to crashme, writing into the per-run directory
procdump -sig 4,5,6,7,8,11 -mc F "$CRASHME_PID" "$RUN_DIR" &
PROCDUMP_PID=$!
echo "Started procdump with pid=$PROCDUMP_PID"

# Wait a bit to make sure procdump is attached before we let crashme run
sleep 2

# Tell crashme to proceed (and crash)
echo "Sending SIGUSR1 to crashme (pid=$CRASHME_PID)"
kill -USR1 "$CRASHME_PID"

# Wait for procdump first, then resume crashme if it's stopped
set +e
wait "$PROCDUMP_PID"
PROCDUMP_EXIT=$?
set -e
echo "procdump exited with status=$PROCDUMP_EXIT"

# If crashme is still around (likely stopped after procdump handled SIGSEGV),
# resume it so it can finish and we can get a proper exit status.
if kill -0 "$CRASHME_PID" 2>/dev/null; then
    echo "Sending SIGCONT to crashme (pid=$CRASHME_PID) after procdump finished"
    kill -CONT "$CRASHME_PID" 2>/dev/null || true
fi

# Now wait for crashme to actually exit, then copy binary on crash
set +e
wait "$CRASHME_PID"
CRASHME_EXIT=$?
set -e
echo "crashme exited with status=$CRASHME_EXIT"

# If crashme exited due to SIGSEGV (11), status is usually 128+11 = 139. We'll copy the binary
# for any error cases

if [ "$CRASHME_EXIT" -ne 0 ]; then
    echo "Detected error (status=$CRASHME_EXIT); copying binary to $RUN_DIR"
    if [ -n "$CRASHME_BIN" ] && [ -r "$CRASHME_BIN" ]; then
        cp "$CRASHME_BIN" "$RUN_DIR"/ 2>/dev/null || \
            echo "Warning: failed to copy $CRASHME_BIN into $RUN_DIR"
    else
        echo "Warning: crashme binary '$CRASHME_BIN' not readable; not copying"
    fi
else
    echo "crashme exited with status=$CRASHME_EXIT; not copying binary"
fi

exit "$CRASHME_EXIT"
