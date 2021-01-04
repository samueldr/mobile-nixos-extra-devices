#!/bin/bash
#
# Shell script to install Bluetooth firmware and attach BT part of
# RTL8723BS
#
# Modified for better packaging.
#

PATH="@@path@@:$PATH"

set -e
set -u
PS4=" $ "
set -x

TTY="/dev/$(grep DEVNAME /sys/devices/pci0000:00/8086228A:00/tty/*/uevent | cut -d'=' -f2)"
RFKILL="$(rfkill list | grep OBDA8723 | cut -d':' -f1)"

if ! [ -e "$TTY" ]; then
	echo
	echo "No BT TTY device has been found"
	echo "Either this computer has no BT device that uses hciattach, or"
	echo "Your kernel does not have module 8250_dw configured."
	echo "Note: The configuration variable is CONFIG_SERIAL_8250_DW."
	echo
	exit 1
fi

echo "Using device $TTY for Bluetooth"

# Reaps any leftover.
pkill rtk_hciattach || :

# Turn it off and on again...
# Then attach.
(rfkill block "$RFKILL" && rfkill unblock "$RFKILL") || :
@@out@@/lib/rtk_hciattach -n -s 115200 "$TTY" rtk_h5
