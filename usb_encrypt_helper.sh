#!/bin/bash
MOUNT_POINT="/media/usb"
PUBKEY="/usr/local/bin/usb_public.pem"
LOG="/tmp/usb_encrypt.log"

if mount | grep -q "$MOUNT_POINT"; then
    echo "$(date): USB mounted" >> "$LOG"
else
    exit 0
fi

inotifywait -m -e close_write "$MOUNT_POINT" | while read path action file; do

    if [[ ! "$file" =~ \.enc$ ]]; then
        openssl rand -hex 16 > /tmp/usb_key.bin
        openssl enc -aes-256-cbc -salt -in "$MOUNT_POINT/$file" -out "$MOUNT_POINT/$file.enc" -pass file:/tmp/usb_key.bin
        openssl rsautl -encrypt -inkey "$PUBKEY" -pubin -in /tmp/usb_key.bin -out "$MOUNT_POINT/$file.key"
        shred -u "$MOUNT_POINT/$file"
    fi

    if [[ "$file" =~ \.enc$ ]]; then
        echo "Insert private key file path:"
        read PRIVATE
        openssl rsautl -decrypt -inkey "$PRIVATE" -in "$MOUNT_POINT/$file.key" -out /tmp/usb_key.bin
        openssl enc -d -aes-256-cbc -in "$MOUNT_POINT/$file" -out "$MOUNT_POINT/${file%.enc}" -pass file:/tmp/usb_key.bin
    fi
done
