#! /bin/bash

SPEED=255
SENSITIVITY=190

echo $SPEED > /sys/devices/platform/i8042/serio1/serio2/speed
echo $SENSITIVITY > /sys/devices/platform/i8042/serio1/serio2/sensitivity
echo "Set speed to $SPEED and sensitivity to $SENSITIVITY"
