#!/bin/bash
set -e

modprobe libcomposite
mountpoint -q /sys/kernel/config || mount -t configfs none /sys/kernel/config

GADGET_DIR="/sys/kernel/config/usb_gadget/w9ksb_satops"

if [ -d "$GADGET_DIR" ]; then
    echo "Cleaning up existing gadget..."
    [ -e "$GADGET_DIR/UDC" ] && echo "" > "$GADGET_DIR/UDC" 2>/dev/null || true
    rm -f "$GADGET_DIR/configs/c.1/acm.usb0" 2>/dev/null || true
    rm -f "$GADGET_DIR/configs/c.1/acm.usb1" 2>/dev/null || true
    rmdir "$GADGET_DIR/functions/acm.usb0" 2>/dev/null || true
    rmdir "$GADGET_DIR/functions/acm.usb1" 2>/dev/null || true
    rmdir "$GADGET_DIR/configs/c.1/strings/0x409" 2>/dev/null || true
    rmdir "$GADGET_DIR/configs/c.1" 2>/dev/null || true
    rmdir "$GADGET_DIR/strings/0x409" 2>/dev/null || true
    rmdir "$GADGET_DIR" 2>/dev/null || true
fi

mkdir -p "$GADGET_DIR"
cd "$GADGET_DIR"

echo 0x1d6b > idVendor
echo 0x0104 > idProduct
echo 0x0100 > bcdDevice
echo 0x0200 > bcdUSB

mkdir -p strings/0x409
echo "0123456789abcdef" > strings/0x409/serialnumber
echo "Open Source Satellite Operations Controller" > strings/0x409/manufacturer
echo "W9KSB SatOps Controller" > strings/0x409/product

mkdir -p configs/c.1
echo 250 > configs/c.1/MaxPower

mkdir -p configs/c.1/strings/0x409
echo "SatOps Serial Configuration" > configs/c.1/strings/0x409/configuration

mkdir -p functions/acm.usb0
ln -s functions/acm.usb0 configs/c.1/

mkdir -p functions/acm.usb1
ln -s functions/acm.usb1 configs/c.1/

UDC_NAME="$(ls /sys/class/udc | head -n 1)"
echo "$UDC_NAME" > UDC

echo "W9KSB SatOps Controller USB gadget started"
echo "Available ports:"
ls /dev/ttyGS*