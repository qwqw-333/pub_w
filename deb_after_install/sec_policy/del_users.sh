#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Loop through each line in users.txt
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comment lines and empty lines
    if [[ "$line" =~ ^\s*#.*$|^$ ]]; then
        continue
    fi

    # Extract username and password from the line
    username=$(echo "$line" | awk '{print $1}')

    # Delete user
    deluser --remove-home "$username"
done < "users.txt"