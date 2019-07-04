#!/bin/sh

VNC_PASSWORD=${VNC_PASSWORD:-android}
VNC_PASSWORD_VIEW_ONLY=${VNC_PASSWORD_VIEW_ONLY:-docker}

echo "VNC_PASSWORD = $VNC_PASSWORD"
echo "VNC_PASSWORD_VIEW_ONLY = $VNC_PASSWORD_VIEW_ONLY"

/usr/bin/expect <<EOF
spawn vncpasswd
expect "Password:"
send "$VNC_PASSWORD\r"
expect "Verify:"
send "$VNC_PASSWORD\r"
expect "Would you like to enter a view-only password (y/n)?"
send "y\r"
expect "Password:"
send "$VNC_PASSWORD_VIEW_ONLY\r"
expect "Verify:"
send "$VNC_PASSWORD_VIEW_ONLY\r"
expect eof
exit
EOF
