#!/bin/bash

# Retreived from http://www.thinkwiki.org/wiki/How_to_hotswap_Ultrabay_devices, modified with another
# script to power the drive back on after undocking. Organized it a bit and bolted on a simple
# user CLI interface. The code could definitely use a bit more cleaning up.


# Change the following DEVPATH= to match your system, if you want to run this directly instead of having it called by the udev eject script
# To find the right value, insert the UltraBay optical drive and run:
# udevadm info --query=path --name=/dev/sr0 | perl -pe 's!/block/...$!!'

if [ "$DEVPATH" = "" ]
then
   # 16.11.09 - found it!
   DEVPATH="/devices/pci0000:00/0000:00:1f.2/ata2/host1/target1:0:0/1:0:0:0"
fi

shopt -s nullglob
export DISPLAY=:0.0 # required for notify-send
ULTRABAY_SYSDIR=/sys$DEVPATH

# Find generic DOCK interface for UltraBay
DOCK=$( /bin/grep -l ata_bay /sys/devices/platform/dock.?/type )
DOCK=${DOCK%%/type}
SCRIPTNAME=ultrabayman

undock() {
  if [ -n "$DOCK" -a -d "$DOCK" ]; then
          logger $SCRIPTNAME starting to undock $DOCK
  else
          logger $SCRIPTNAME cannot locate bay dock device
          notify-send -u critical -t 100000 "ThinkPad Ultrabay eject failed" "Cannot locate bay dock device"
  fi

  if [ $( cat $DOCK/docked ) == 0 ]; then
          logger $SCRIPTNAME dock reports empty
          notify-send -u normal -t 10000 "Dock reports empty" "No drive in ultrabay"
          exit 0;
  else 
    if [ -d $ULTRABAY_SYSDIR ]; then
      logger $SCRIPTNAME dock occupied, unmounting file systems and shutting down storage device $DEVPATH
      sync
      # Unmount filesystems backed by this device
      ## This seems to be very inelegant and prone to failure
      unmount_rdev `cat $ULTRABAY_SYSDIR/block/*/dev     \
            $ULTRABAY_SYSDIR/block/*/*/dev`  \
      || {
        logger $SCRIPTNAME umounting failed
        echo 2 > /proc/acpi/ibm/beep  # triple error tone
        notify-send -u critical -t 100000 "ThinkPad Ultrabay eject failed" "Please do not pull the device, doing so could cause file
          corruption and possibly hang the system. Unmounting of the filesystem on the ThinkPad Ultrabay device failed. Please put
          the eject leaver back in place, and try to unmount the filesystem manually. If this succeeds you can try the eject again"
        exit 1;
      }

      sync
      # Nicely power off the device
      logger $SCRIPTNAME Powering off the ultrabay drive using hdparm
      DEVNODE=`ultrabay_dev_node` && hdparm -Y $DEVNODE
      # Let HAL+KDE notice the unmount and let the disk spin down
      sleep 0.5
      # Unregister this SCSI device:
      sync
      logger $SCRIPTNAME Unregistering the SCSI device
      echo 1 > $ULTRABAY_SYSDIR/delete
    else
      logger $SCRIPTNAME bay occupied but incorrect device path $DEVPATH
      notify-send -u critical -t 100000 "ThinkPad Ultrabay eject failed" "Bay occupied but incorrect device path"
      echo 2 > /proc/acpi/ibm/beep  # triple error tone
      exit 1
    fi
  fi

  logger $SCRIPTNAME Ultrabay undocked successfully!
  echo 6 > /proc/acpi/ibm/beep
  notify-send -u normal -t 10000 "Ultrabay undocked successfully!" ""

}

dock() {
  if [ ! -n "$DOCK" -a -d "$DOCK" ]; then
      logger "$SCRIPTNAME": cannot locate ultrabay dock device
      notify-send -u critical -t 100000 "ThinkPad Ultrabay device docking failed" "Cannot locate bay dock device"
      exit 1
  fi

  if [ "$(cat $DOCK/docked)" = "1" ]; then
      sync
      SCSIHOST=$(echo $DEVPATH | sed 's/^.*\(host[0-9]\).*$/\1/');
      logger "$SCRIPTNAME": Scanning ThinkPad Ultrabay for new device on $SCSIHOST
      echo "- - -" > /sys/class/scsi_host/$SCSIHOST/scan
      logger "$SCRIPTNAME": Docking of ThinkPad Ultrabay device successfully completed.
      notify-send -u normal -t 10000 "Docking ThinkPad Ultrabay device completed" "The ThinkPad Ultrabay device is now available for use."
      exit 0
  else
      logger "$SCRIPTNAME": ThinkPad Ultrabay device docking failed
      notify-send -u normal -t 10000 "Docking ThinkPad Ultrabay device failed" "Docking the ThinkPad Ultrabay device failed. Please check what went wrong and fix it."
      exit 1
  fi
}

# Umount the filesystem(s) backed by the given major:minor device(s)
unmount_rdev() { perl - "$@" <<'EOPERL'  # let's do it in Perl
        for $major_minor (@ARGV) {
                $major_minor =~ m/^(\d+):(\d+)$/ or die;
                push(@tgt_rdevs, ($1<<8)|$2);
        }
        # Sort by reverse length of mount point, to unmount sub-directories first
        open MOUNTS,"</proc/mounts" or die "$!";
        @mounts=sort { length($b->[1]) <=> length($a->[1]) } map { [ split ] } <MOUNTS>;
        close MOUNTS;
        foreach $m (@mounts) {
                ($dev,$dir)=@$m;
                next unless -b $dev;  $rdev=(stat($dev))[6];
                next unless grep($_==$rdev, @tgt_rdevs);
                system("umount","-v","$dir")==0  or  $bad=1;
                if ($bad == 1) {
                        system("logger","$SCRIPTNAME","ERROR unmounting",$dev,$dir);
                        system("notify-send -u critical -t 100000 \"Error unmounting $dir\" \"Unmounting of $dir on $dev failed!\"");
                } else {
                        system("logger","$SCRIPTNAME","unmounted",$dev,$dir);
                        system("notify-send -u normal -t 5000 \"Unmounted $dir\"");
                };
        }
        exit 1 if $bad;
EOPERL
}

# Get the UltraBay's /dev/foo block device node
ultrabay_dev_node() {
        UDEV_PATH="`readlink -e "$ULTRABAY_SYSDIR/block/"*`" || return 1
        UDEV_NAME="`udevadm info --query=name --path=$UDEV_PATH`" || return 1
        echo /dev/$UDEV_NAME
}

usage() {
  echo "Usage: ultrabay.sh [-d|-u|-e|-h]
  -d - rescan scsi hosts, will power up the ultrabay.
  -u - unmount, put disk to sleep, then remove it from the scsi list.
  -e - eject: basically do -u but also power off the dock. Disk has to be re-inserted to get it up again.
  -h - help"
}

while getopts "dueh" opt; do
  case $opt in
    d)
      echo "Docking";
      dock;
      exit;;
    u)
      echo "Undocking"
      undock;
      exit;;
    e)
      echo "ejecting"
      undock;
      echo 1 > $DOCK/undock
      exit;;
    *)
      usage;
      exit;;
  esac
done;

shift $((OPTIND-1))
