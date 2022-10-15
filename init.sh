#!/bin/bash
grep '^sudo:.*$' /etc/group | cut -d: -f4 >> sudoUsers.txt
systemctl list-units --all --type=service --no-pager | grep running >> current.services
diff current.services default.services >> check.services 
sudo apt list --installed >> current.apps
diff current.apps default.apps >> check.apps
rm current.services && rm current.apps
for str in "nmap" "zenmap" "apache2" "nginx" "lighttpd" "wireshark" "tcpdump" "netcat-traditional" "nikto" "ophcrack" "john" "ripper" "rainbow" "invicti" "fortify" "webinspect" "cain" "abel" "nessus" "kismet" "netstumbler" "acunetix" "netsparker" "intruder" "metsploit" "aircrack-ng" "wireshark" "openvas" "sqlmap" "ettercap" "maltego" "burp" "angry" "solarwinds" "traceroute" "tracert" "liveaction" "qualysguard" "hashcat" "l0phtcrack" "ikecrack" "sboxr" "medusa" "crack"; do
	find / -name $str >> bad.apps
done
for str in "*.aif" "*.flac" "*.m3u" "*.m4a" "*.mid" "*.mp3" "*.ogg" "*.wav" "*.wma" "*.aif" "*.m4b" "*.3gp" "*.asf" "*.avi" "*.flv" "*.m4v" "*.mov" "*.mp4" "*.mpg" "*.srt" "*.swf" "*.ts" "*.vob" "*.wmv" "*.mkv" "*.f4v" "*.avchd"; do
	find / -type f -name $str >> media.apps
done
rm /etc/apt/sources.list
sudo echo "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
# sudo echo "deb http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
# sudo echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
# sudo echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list
# sudo echo "deb http://security.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
sudo sed -i 's/APT::Periodic::Update-Package-Lists "0";/APT::Periodic::Update-Package-Lists "1";/g' /etc/apt/apt.conf.d/10periodic
sudo apt update
DEBIAN_FRONTEND=noninteractive apt-get install -y "vim"
DEBIAN_FRONTEND=noninteractive apt-get install -y "tmux"
DEBIAN_FRONTEND=noninteractive apt-get install -y "cron"
DEBIAN_FRONTEND=noninteractive apt-get install -y "aide"
DEBIAN_FRONTEND=noninteractive apt-get install -y "vlock"
DEBIAN_FRONTEND=noninteractive apt-get install -y "auditd"
DEBIAN_FRONTEND=noninteractive apt-get install -y "audispd-plugins"
DEBIAN_FRONTEND=noninteractive apt-get install -y "libpam-pwquality"
DEBIAN_FRONTEND=noninteractive apt-get remove -y "inetutils-telnetd"
DEBIAN_FRONTEND=noninteractive apt-get remove -y "nis"
DEBIAN_FRONTEND=noninteractive apt-get remove -y "telnetd-ssl"
DEBIAN_FRONTEND=noninteractive apt-get remove -y "telnetd"


sudo echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

## Enable Cron Service
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask 'cron.service'
"$SYSTEMCTL_EXEC" start 'cron.service'
"$SYSTEMCTL_EXEC" enable 'cron.service'

else
    >&2 echo 'Cron Service Could Not Be Enabled'
fi

## Set SSH Client Alive Count Max to Zero
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then

    LC_ALL=C sed -i "/^\s*ClientAliveCountMax\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/ssh/sshd_config"

cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "ClientAliveCountMax 0" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "ClientAliveCountMax 0" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Error: Could not set SSH Client Alive Count Max to Zero'
fi

## Set SSH Idle Timeout Interval to 300
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

sshd_idle_timeout_value='300'


if [ -e "/etc/ssh/sshd_config" ] ; then

    LC_ALL=C sed -i "/^\s*ClientAliveInterval\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/ssh/sshd_config"

cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "ClientAliveInterval $sshd_idle_timeout_value" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "ClientAliveInterval $sshd_idle_timeout_value" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Error: Could not set SSH Idle Timeout Interval to 300'
fi

## Disable SSH Access via Empty Passwords
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then

    LC_ALL=C sed -i "/^\s*PermitEmptyPasswords\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/ssh/sshd_config"

cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Error: Could not disable SSH Access via empty passwords'
fi

## Disable SSH Root Login
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then

    LC_ALL=C sed -i "/^\s*PermitRootLogin\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/ssh/sshd_config"

cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Error: Could not disable SSH Root Login'
fi


sudo utils/aideConfig.sh
sudo utils/gnomeConfig.sh
sudo utils/sudoConfig.sh
sudo utils/aptConfig.sh
sudo utils/passwordConfig.sh
sudo utils/sessionConfig.sh
sudo utils/auditConfig.sh
sudo utils/pamConfig.sh
uname -a | grep -i ubuntu && sudo utils/ubuntu_harden.sh
uname -a | grep -i debian && sudo utils/debian_harden.sh
sudo utils/permissionsConfig.sh