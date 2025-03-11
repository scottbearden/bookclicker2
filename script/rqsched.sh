#!/bin/bash

#RAILS_ENV=production ./script/rqsched.sh

function pause_for_user () {
  for i in 1 2 3
  do
    sleep 0.3
    echo "."
  done
}

function ensure_process_has_died () {
  ps_name=$1
  ps_aux_regex="\w\{1,20\}\s\{1,20\}\d*"
  echo "Checking if $ps_name has died"
  pause_for_user
  ps_aux_count=`ps aux | grep -e "$ps_name" | wc -l`
  if [[ $ps_aux_count -ge 1 ]]
  then
    echo "Process $ps_name is currently running"
    exit 125
  else
    echo "Process $ps_name not running.  Restarting process..."
  fi
}

function execute_script () {
  ps_name=$1
  rails_env=$2
  
  cmd="rake environment resque:scheduler &"
  echo "Running:  $cmd"
  $cmd &
}

ps_name="[r]esque-scheduler"
pause_for_user
ensure_process_has_died $ps_name
pause_for_user
execute_script $ps_name $RAILS_ENV