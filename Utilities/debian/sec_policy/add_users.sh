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
    password=$(echo "$line" | awk '{print $3}')

    # Create the user with the specified password
    useradd -m -s /bin/bash -p $(openssl passwd -1 "$password") "$username"

    # Check if user creation was successful
    if [ $? -eq 0 ]; then
        echo "User '$username' created successfully"
    else
        echo "Failed to create user '$username'"
    fi
done < "users.txt"
