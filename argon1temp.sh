# corresponding lines in raspi-config:
do_i2c() {
  DEFAULT=--defaultno
  if [ $(get_i2c) -eq 0 ]; then
    DEFAULT=
  fi
  if [ "$INTERACTIVE" = True ]; then
    whiptail --yesno "Would you like the ARM I2C interface to be enabled?" $DEFAULT 20 60 2
    RET=$?
  else
    RET=$1
  fi
  if [ $RET -eq 0 ]; then
    SETTING=on
    STATUS=enabled
  elif [ $RET -eq 1 ]; then
    SETTING=off
    STATUS=disabled
  else
    return $RET
  fi
#
# and
#
do_serial() {
  DEFAULTS=--defaultno
  DEFAULTH=--defaultno
  CURRENTS=0
  CURRENTH=0
  if [ $(get_serial) -eq 0 ]; then
      DEFAULTS=
      CURRENTS=1
  fi
  if [ $(get_serial_hw) -eq 0 ]; then
      DEFAULTH=
      CURRENTH=1
  fi
  if [ "$INTERACTIVE" = True ]; then
    whiptail --yesno "Would you like a login shell to be accessible over serial?" $DEFAULTS 20 60 2
    RET=$?
  else
    RET=$1
  fi
  if [ $RET -eq $CURRENTS ]; then
    ASK_TO_REBOOT=1
  fi
  if [ $RET -eq 0 ]; then
    if grep -q "console=ttyAMA0" $CMDLINE ; then
      if [ -e /proc/device-tree/aliases/serial0 ]; then
        sed -i $CMDLINE -e "s/console=ttyAMA0/console=serial0/"
      fi
    elif ! grep -q "console=ttyAMA0" $CMDLINE && ! grep -q "console=serial0" $CMDLINE ; then
      if [ -e /proc/device-tree/aliases/serial0 ]; then
        sed -i $CMDLINE -e "s/root=/console=serial0,115200 root=/"
      else
        sed -i $CMDLINE -e "s/root=/console=ttyAMA0,115200 root=/"
      fi
    fi
    set_config_var enable_uart 1 $CONFIG
    SSTATUS=enabled
    HSTATUS=enabled
  elif [ $RET -eq 1 ] || [ $RET -eq 2 ]; then
    sed -i $CMDLINE -e "s/console=ttyAMA0,[0-9]\+ //"
    sed -i $CMDLINE -e "s/console=serial0,[0-9]\+ //"
    SSTATUS=disabled
    if [ "$INTERACTIVE" = True ]; then
      whiptail --yesno "Would you like the serial port hardware to be enabled?" $DEFAULTH 20 60 2
      RET=$?
    else
      RET=$((2-$RET))
    fi
    if [ $RET -eq $CURRENTH ]; then
     ASK_TO_REBOOT=1
    fi
    if [ $RET -eq 0 ]; then
      set_config_var enable_uart 1 $CONFIG
      HSTATUS=enabled
    elif [ $RET -eq 1 ]; then
      set_config_var enable_uart 0 $CONFIG
      HSTATUS=disabled
    else
      return $RET
    fi
  else
    return $RET
  fi
  if [ "$INTERACTIVE" = True ]; then
      whiptail --msgbox "The serial login shell is $SSTATUS\nThe serial interface is $HSTATUS" 20 60 1
  fi
}
#
# idea: add to dietpi-config file and see what it does?
