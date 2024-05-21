#!/bin/bash

# Pass
read -p "Введите пароль: " pass
echo

# Token
read -p "Введите токен (signalwire): " token
echo

# Path to config -> $config
config="/usr/src/fusionpbx-install.sh/debian/resources/config.sh"

# Change "system_password="
sed -i "s/^system_password=.*/system_password=\"$pass\"/" "$config"

# Change "switch_token="
sed -i "s/^switch_token=.*/switch_token=\"$token\"/" "$config"

# Change "database_password="
sed -i "s/^database_password=.*/database_password=\"$pass\"/" "$config"