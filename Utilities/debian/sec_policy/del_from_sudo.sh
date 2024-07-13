#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Get current users in the sudo group
sudo_users=$(getent group sudo | cut -d: -f4)

# Check if there are any users in the sudo group
if [ -z "$sudo_users" ]; then
    echo "There are no users in the sudo group."
    exit 1
fi

# Convert sudo_users string to array
IFS=',' read -r -a sudo_users_array <<< "$sudo_users"

# Display current users in the sudo group with numbers
echo "Current users in the sudo group:"
for i in "${!sudo_users_array[@]}"; do
    echo "$((i+1)). ${sudo_users_array[$i]}"
done

# Prompt user to select users to remove
read -p "Enter the numbers corresponding to the usernames to remove (separated by spaces): " numbers

# Loop through each selected number
for number in $numbers; do
    # Ensure the number is valid
    if ! [[ "$number" =~ ^[0-9]+$ ]]; then
        echo "Invalid input: '$number' is not a number." 1>&2
        continue
    fi

    # Convert number to array index
    index=$((number-1))

    # Check if the index is within range
    if [ $index -ge 0 ] && [ $index -lt ${#sudo_users_array[@]} ]; then
        # Get the corresponding username
        user=${sudo_users_array[$index]}
        
        # Remove the user from the sudo group
        deluser "$user" sudo
        if [ $? -eq 0 ]; then
            echo "User '$user' successfully removed from the sudo group."
        else
            echo "Failed to remove user '$user' from the sudo group." 1>&2
        fi
    else
        echo "Invalid number: '$number' does not correspond to a user." 1>&2
    fi
done