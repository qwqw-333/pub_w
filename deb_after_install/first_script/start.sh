#!/bin/bash

# Update & upgrade packages
apt update && apt upgrade -y

# Set timezone
timedatectl set-timezone Europe/Kyiv

# Disable IPv6 and confirm changes
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
/sbin/sysctl -p

# Install necessary packages
apt install curl wget git lsb-release tmux sudo mc -y

# Create user "konoval" without password
adduser --disabled-password --gecos "" konoval

# Add authorization method by TouchID
mkdir -p /home/konoval/.ssh
echo 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO2pz6jd5V4QPRuECNg6Aqfy9RnULFvRaPvIayyyNEcF89t7BmmJZhNlvLjT/jt894SU0vNZhLjwLo8wilD7ZsE=' | tee /home/konoval/.ssh/authorized_keys
chown -R konoval:konoval /home/konoval/.ssh
chmod 700 /home/konoval/.ssh
chmod 600 /home/konoval/.ssh/authorized_keys

# Add root privileges to "konoval" using sudo with root password 
touch /etc/sudoers.d/konoval
echo "Defaults:konoval rootpw" | tee -a /etc/sudoers.d/konoval
echo "konoval ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/konoval

# Welcome script
cat << 'EOF' > /home/konoval/.system_info.sh
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

chmod +x /home/konoval/.system_info.sh
echo "/home/konoval/.system_info.sh" >> /home/konoval/.bashrc
source /home/konoval/.bashrc

sed -i 's/^.*PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config
/etc/init.d/ssh restart
cat /dev/null > /etc/motd
rm /etc/update-motd.d/* 

# Docker installation
echo "Скачивание и установка Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
usermod -aG docker konoval

# System clean
apt autoremove -y
apt clean

# Remove script
rm start.sh