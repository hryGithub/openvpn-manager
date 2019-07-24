#!/bin/bash
. /etc/openvpn/scripts/config.sh
. /etc/openvpn/scripts/functions.sh

username=$(echap "$username")
password=$(echap "$password")

# Authentication
user_pass=$(sqlite3 $DB "SELECT user_pass FROM user WHERE user_id = '$username' AND user_enable=1 AND (strftime('%s','now') >= strftime('%s',user_start_date) OR user_start_date IS NULL AND (strftime('%s','now') <= strftime('%s',user_end_date)) OR user_end_date IS NULL)")

# Check the user
if [ "$user_pass" == '' ]; then
  echo "$username: bad account."
  exit 1
fi

result=$(php -r "if(password_verify('$password', '$user_pass') == true) { echo 'ok'; } else { echo 'ko'; }")

if [ "$result" == "ok" ]; then
  echo "$username: authentication ok."
  exit 0
else
  echo "$username: authentication failed."
  exit 1
fi
