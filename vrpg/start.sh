#!/bin/sh

# Pull in config
source ./vrpg.cfg


# Enter VENV
source "$VRPG_VENVDIR/bin/activate"


# Start iproc and save PID
$VRPG_IPROCINIT &
iproc_pid=$!
echo $iproc_pid > "$VRPG_EXTERN/icproc.pid"


# Start web and save PID
$VRPG_WEBINIT &
web_pid=$!
echo $web_pid > "$VRPG_EXTERN/web.pid"


while [ -d "/proc/$iproc_pid" -a -d "/proc/$web_pid" ]; do
  sleep 10
done
