#!/bin/sh

# Pull in config
source ./vrpg.cfg


# Get PIDs
web_pid="$(cat "$VRPG_EXTERN/web.pid")"
iproc_pid="$(cat "$VRPG_EXTERN/iproc.pid")"


# Kill the Web service
kill 15 $web_pid  # Do it nicely
sleep 3
if [ -d "/proc/$web_pid" ]; then
  kill 9 $web_pid  # Not so nicely
fi


# Kill the Image processing service
kill 15 $iproc_pid  # Do it nicely
sleep 3
if [ -d "/proc/$iproc_pid" ]; then
  kill 9 $iproc_pid  # Not so nicely
fi
