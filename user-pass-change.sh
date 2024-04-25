#!/bin/bash

# Check file
if [ $# -eq 0 ]; then
    echo "File $0 used for login and password"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "File '$1' not found. Please, check your command (bash adduser.sh your_file)"
    exit 1
fi

# Set variables
while IFS='-' read -r username password; do
    username=$(echo "$username" | tr -d '[:space:]')  # Удаляем пробелы
    password=$(echo "$password" | tr -d '[:space:]')  # Удаляем пробелы

    # Меняем пароль для пользователя
    echo "$username:$password" | sudo chpasswd
    echo "Password for $username changed."
done < "$1"