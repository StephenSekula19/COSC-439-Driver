#!/bin/bash
MOUNT_POINT="/media/stephen/F17E-0AEE"
PUBKEY="/usr/local/bin/usb_public.pem"
LOG="/tmp/usb_encrypt.log"

# Check if USB is mounted
if mount | grep -q "$MOUNT_POINT"; then
    echo "$(date): USB mounted" >> "$LOG"
else
    exit 0
fi

# Watch for newly written files
inotifywait -m -e close_write --format '%f' "$MOUNT_POINT" | while read file; do

    # Skip already encrypted or key files
    if [[ ! "$file" =~ \.enc$ ]] && [[ ! "$file" =~ \.key$ ]]; then
        # Generate random AES key
        openssl rand -hex 16 > /tmp/usb_key.bin

        # Encrypt the file
        openssl enc -aes-256-cbc -salt \
            -in "$MOUNT_POINT/$file" \
            -out "$MOUNT_POINT/$file.enc" \
            -pass file:/tmp/usb_key.bin

        # Encrypt the AES key with public key
        openssl pkeyutl -encrypt -pubin -inkey "$PUBKEY" \
            -in /tmp/usb_key.bin \
            -out "$MOUNT_POINT/$file.key"

        # Remove original file securely
        shred -u "$MOUNT_POINT/$file"
    fi

    # Decryption section
    if [[ "$file" =~ \.enc$ ]]; then
        echo "Insert private key file path:"
        read PRIVATE

        openssl pkeyutl -decrypt -inkey "$PRIVATE" \
            -in "$MOUNT_POINT/$file.key" \
            -out /tmp/usb_key.bin

        openssl enc -d -aes-256-cbc \
            -in "$MOUNT_POINT/$file" \
            -out "$MOUNT_POINT/${file%.enc}" \
            -pass file:/tmp/usb_key.bin
    fi
done
