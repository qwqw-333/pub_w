#!/bin/bash

# Check sudo installation
if ! dpkg -s sudo &> /dev/null; then
    apt-get update
    apt-get install sudo -y
fi

# Display the list of users with their corresponding numbers
echo "List of users:"
count=0
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comment lines and empty lines
    if [[ "$line" =~ ^\s*#.*$|^$ ]]; then
        continue
    fi
    # Extract username from the line
    username=$(echo "$line" | awk '{print $1}')
    # Increment the count and display the username with its number
    echo "$((++count)). $username"
done < users.txt

# Prompt the user to input the numbers of users they want to add to the sudo group
echo "Enter the numbers of users you want to add to the sudo group (separated by spaces):"
read -r selections

# Split the input into an array
IFS=' ' read -r -a selected_numbers <<< "$selections"

# Loop through the selected numbers and add the corresponding users to the sudo group
for selection in "${selected_numbers[@]}"
do
    # Extract the username based on the selected number
    selected_user=$(awk -v sel="$selection" 'NR==sel {print $1}' users.txt)

    # Check if the user exists
    if id "$selected_user" &>/dev/null; then
        # Add the user to the sudo group
        sudo usermod -aG sudo "$selected_user"
        echo "User '$selected_user' added to the sudo group."
    else
        echo "Error: User with the selected number does not exist."
    fi
done