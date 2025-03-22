#!/bin/bash

# Check if an argument was provided
if [ $# -eq 1 ]; then
    # Check if the provided argument is a directory
    if [ -d "$1" ]; then
        ROOTFS="$1"
    else
        echo "Error: '$1' is not a valid rootfs directory"
        exit 1
    fi
fi

# Check if DISTRO_FS is set and directory exists
if [ -z "$ROOTFS" ] || [ ! -d "$ROOTFS" ]; then
    echo "Error: Directory $ROOTFS does not exist or ROOTFS is not set"
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Check if directory is not empty
if [ -z "$(ls -A "$ROOTFS")" ]; then
    echo "Error: Directory $ROOTFS is empty"
    exit 1
fi


# Get current date in yyyy-mm-dd format
DATE=$(date +%Y-%m-%d)

FILE_NAME="${DISTRO_DIR:-distro}-${ARCH}-${DATE}.tar.gz"

# Initialize counter
COUNT=0

# Check for existing files and increment counter if needed
while [ -f "$FILE_NAME" ]; do
    COUNT=$((COUNT + 1))
    FILE_NAME="${DISTRO_DIR}-${ARCH}-${DATE}-${COUNT}.tar.gz"
done

# Create the tar file
echo "Creating ${FILE_NAME}"
sudo tar -cvjf "$FILE_NAME" -C "$ROOTFS" .

# Check if tar command was successful
if [ $? -eq 0 ]; then
    echo "Successfully created $FILE_NAME"
else
    echo "Error creating tar file"
    exit 1
fi