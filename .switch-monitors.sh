#!/bin/bash
PID=""
CONFIG_FILE=~/.monitors-enabled

function get_enabled_monitors {
   MONITORS=`cat $CONFIG_FILE`
}


function dvi_only {
	echo  "Enabling DVI only"
	xrandr --output eDP1 --off --output DP1 --primary
	echo "DVI_ONLY" > $CONFIG_FILE
}

function hdmi_only {
	echo  "Enabling HDMI only"
 	xrandr --output DP1 --off --output eDP1 --primary
	echo "HDMI_ONLY" > $CONFIG_FILE
}

function both {
	echo  "Enabling BOTH MONITORS"
	xrandr --output DP1 --auto --left-of eDP1 --output eDP1 --primary
	echo "BOTH" > $CONFIG_FILE
}

function switch {
  get_enabled_monitors
   if [ -z $MONITORS ]
	then
	dvi_only
   elif [ "$MONITORS" = "DVI_ONLY" ]
	then
      	both
   elif [ "$MONITORS" = "BOTH" ]
	then
      	dvi_only 
   else
   	echo "never configured"
   fi

}



function status {
   get_enabled_monitors
   if [ -z  $MONITORS ]; then
      echo "never configured"
      exit 1
   else
      echo "Monitors configured are  $MONITORS"
   fi
}


case "$1" in
   switch)
      switch
   ;;
   both)
      both
   ;;
   dvi-only)
      dvi_only
   ;;
   hdmi-only)
      hdmi_only
   ;;
   status)
      status
   ;;
   *)
      echo "Usage: $0 {switch|dvi-only|hdmi-only|both|status}"
esac
