#!/bin/bash

usermod -u $UID cloud
groupmod -g $GID cloud

chown $UID:$GID -R /var/log/aria2c /var/local/aria2c

# Start the first process
sudo -u cloud aria2c --enable-rpc --rpc-allow-origin-all -c -D --log=/var/log/aria2c/aria2c.log --check-certificate=false --save-session=/var/local/aria2c/aria2c.sess --save-session-interval=2 --continue=true --input-file=/var/local/aria2c/aria2c.sess --rpc-save-upload-metadata=true --force-save=true --log-level=warn -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start aria2c: $status"
  exit $status
fi

# Start the second process
run.sh
if [ $status -ne 0 ]; then
  echo "Failed to start nextcloud: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep aria2c |grep -q -v grep
  PROCESS_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  if [ $PROCESS_STATUS -ne 0 ]; then
    echo "aria2c has exited."
    exit 1
  fi
done
