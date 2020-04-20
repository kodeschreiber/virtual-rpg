#!./vrpg/busybox/busybox-x86_64 ash

# Check for help
case $2 in
  -h|--help|help)
$VRPG_BB cat <<EOF
 -- Virtual RPG Setup --
If you are reading this, you chose the correct
setup file for your architecture. There are a
couple of options available to you in this
setup script. Simply rerun this file with one
of the following:

 help - Which you found...it's this print-out

 systemd - This will install the VRPG service
 and enable it.

 clean - If you have issues with your setup
 you may use this option to clean the
 program of its setup files. You must use
 this when the setup fails. Otherwise, it
 will fail.
EOF
  ;;
esac


# Pull in config
source ./vrpg.cfg


# Check if root user
if [ $USER -ne 0 ]; then
  $VRPG_BB echo "User is not root! Cannot proceed with install" >&2
  exit 1


# Check/handle "rebuild" argument
if [ -d "$VRPG_EXTERN" ]; then
  if [ "x$2" == "clean" ]; then
    $VRPG_BB rm -rf "$VRPG_EXTERN"
    exit 0
  else
    $VRPG_BB echo "The data directory was already built. To rebuild that" >&2
    $VRPG_BB echo "directory, rerun this script with the argument 'rebuild'." >&2
    exit 2
  fi
fi


# Set up external directory
$VRPG_BB mkdir "$VRPG_EXTERN"


# Expand the needed busybox commands
$VRPG_BB mkdir "$VRPG_BBDIR"
$VRPG_BB cp $VRPG_BB "$VRPG_BBDIR/busybox"
$VRPG_BB echo "$VRPG_BBCMDS" | $VRPG_BB sed 's/ /\n/g' | \
while read cmd; do
  $VRPG_BB ln -s busybox "$VRPG_BBDIR/$cmd"
done


# Add commands to path
PATH="$VRPG_BBDIR:$PATH"


# Create venv for python
mkdir "$VRPG_VENVDIR"
if [ ! -x /usr/bin/python3 -o ! -x /usr/bin/pip3 ]; then
  echo "Could not locate a Python3 installation. Please ensure that" >&2
  echo "Python3, Pip3 and VENV are installed on your system." >&2
  exit 3
fi
/usr/bin/python3 -m venv "$VRPG_VENVDIR"


# Enter VENV
source "$VRPG_VENVDIR/bin/activate"


# Check for python modules
pip3 install $VRPG_PYREQS


# Check if systemd install applied
if [ "x$2" != "xsystemd" ]; then
  echo "Build complete"
  exit 0
fi


# Copy out service file
cat "$VRPG_ROOT/vrpg/vrpg.service" | \
sed "s@%S@$VRPG_ROOT/vrpg/start.sh@;s@%E@$VRPG_ROOT/vrpg/stop.sh@" > /lib/systemd/system/vrpg.service


# Reload system daemons
systemctl daemon-reload


# Enable module
systemctl enable vrpg.service


# Start module
systemctl start vrpg.service


# End message
echo "SystemD unit installed; build complete"
