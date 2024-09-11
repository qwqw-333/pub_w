#!/bin/bash

# Set variables
user='konoval'
enc_pass='$6$NxLMK6nUAdll6AGO$Q95LWeyo4zwfM4Jfcz7aMr5kaRZmYQhk6QIcvCBtXXZWSJl2JKjmXv6kyQkFA9DCOINs0OSX05lNtJUKMVYL9/'
location='Europe/Kyiv'

# Update & upgrade packages
apt update && apt upgrade -y

# Set timezone
timedatectl set-timezone $location

# Disable IPv6 and confirm changes
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
/sbin/sysctl -p

# Install necessary packages
apt install curl wget git lsb-release build-essential tmux sudo mc -y

# Create user "$user" and set encrypted pass
adduser --disabled-password --gecos "" $user
echo "${user}:${enc_pass}" | sudo chpasswd -e

# Add authorization method by TouchID
mkdir -p /home/$user/.ssh
echo 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO2pz6jd5V4QPRuECNg6Aqfy9RnULFvRaPvIayyyNEcF89t7BmmJZhNlvLjT/jt894SU0vNZhLjwLo8wilD7ZsE=' | tee /home/$user/.ssh/authorized_keys
chown -R $user:$user /home/$user/.ssh
chmod 700 /home/$user/.ssh
chmod 600 /home/$user/.ssh/authorized_keys

# Add root privileges to "$user" using sudo
touch /etc/sudoers.d/$user
echo "$user ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/$user

# Welcome script
cat << 'EOF' > /home/$user/.system_info.sh
#!/bin/bash

print_system_info() {
    # System status
    hostname=$(hostname)
    system_load=$(uptime | awk '{print $(NF-2)}' | sed 's/,$//')
    uptime=$(uptime -p | awk '{$1=""; gsub(",", ""); print $0}' | xargs)
    processes=$(ps -A --no-headers | wc -l)
    timezone=$(timedatectl | grep "Time zone" | awk '{$1=$2=$4=$5="";print $0}' | xargs)

    # Resource usage
    disk_usage=$(df -h / | awk 'NR==2{print $5}')
    disk_size=$(df -h / | awk 'NR==2{print $2}')
    memory_usage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
    swap_usage=$(free -m | awk 'NR==4{printf "%.2f%%", $3*100/$2}')

    # Network information
    interfaces=$(ip -o -4 address show | awk '{printf "- %-10s %-15s\n", $2 ":", $4}')

    # Updates information
    apt_updates=$(apt-get --simulate dist-upgrade | grep ^Inst | wc -l)
    security_updates=$(apt-get --simulate dist-upgrade | grep ^Inst | grep -c security)

    # Output information
    echo
    echo -e "Welcome to \e[1;32m${hostname}\e[0m server"
    echo "System information as of $(date +'%a %d %B %Y %H:%M:%S') $timezone"
    echo
    echo "--- General System Status ---"
    echo "System load:    ${system_load}"
    echo "Uptime:         ${uptime}"
    echo "Processes:      ${processes}"
    echo
    echo "--- Resource Usage ---"
    echo "Disk usage:     ${disk_usage} of ${disk_size}"
    echo "Memory usage:   ${memory_usage}"
    echo "Swap usage:     ${swap_usage}"
    echo
    echo "--- Network Information ---"
    echo "$interfaces"
    echo
    echo "--- Update Information ---"
    echo "${apt_updates} packages can be updated."
    echo "${security_updates} updates are security updates."
    echo
}

print_system_info
EOF

chmod +x /home/$user/.system_info.sh
echo "/home/$user/.system_info.sh" >> /home/$user/.bashrc
source /home/$user/.bashrc

sed -i 's/^.*PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config
cat /dev/null > /etc/motd
rm /etc/update-motd.d/* 

# System clean
apt autoremove -y
apt clean

# Restart ssh
/etc/init.d/ssh restart