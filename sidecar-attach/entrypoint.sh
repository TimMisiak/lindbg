#!/bin/bash

# Find PIDs whose executable lives under /app/
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    exe="/proc/$pid/exe"
    if [ -L "$exe" ]; then
        path=$(readlink "$exe" || true)
        if [[ "$path" == /app/* ]]; then
            if [ ! -f "$path" ]; then
                echo "Copying target binary for PID $pid from $path"
                nsenter --target "$pid" --mount cat $path > $path
            fi
        fi
    fi
done
gdbserver --multi localhost:1234
