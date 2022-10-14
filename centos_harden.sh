#!/bin/bash

sys_upgrades() {
    yum -y update
    yum -y upgrade
    yum -y autoremove
}

unattended_upg() {
    yum -y install yum-cron
    chkconfig --level 345 yum-cron on
    service yum-cron start
}

disable_root() {
    passwd -l root
}

user_pass_expirations() {
    perl -npe 's/PASS_MAX_DAYS\s+99999/PASS_MAX_DAYS 180/' -i /etc/login.defs
    perl -npe 's/PASS_MIN_DAYS\s+0/PASS_MIN_DAYS 1/g' -i /etc/login.defs
    perl -npe 's/PASS_WARN_AGE\s+7/PASS_WARN_AGE 14/g' -i /etc/login.defs
}


remove_atd() {
    yum -y remove at
}

disable_ipv6() {
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
}

set_av() {
    yum -y install chkrootkit clamav
    chkrootkit
    freshclam
    clamscan -ir --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc /
}

permission_narrowing() {
    chmod 700 /root
    chmod 700 /var/log/audit
    chmod 740 /etc/rc.d/init.d/iptables
    chmod 740 /sbin/iptables
    chmod -R 700 /etc/skel
    chmod 600 /etc/rsyslog.conf
    chmod 640 /etc/security/access.conf
    chmod 600 /etc/sysctl.conf
}

disable_avahi(){
    systemctl stop avahi-daemon.socket avahi-daemon.service
    systemctl disable avahi-daemon.socket avahi-daemon.service
}

disable_postfix() {
    systemctl stop postfix
    systemctl disable postfix
}


fix_file_permissions() {
    cat fileperms.txt | bash 2>/dev/null
}

kernel_tuning() {
    sysctl kernel.randomize_va_space=1
    sysctl kernel.kptr_restrict=1
    sysctl -w fs.protected_hardlinks=1
    sysctl -w fs.protected_symlinks=1
    sysctl -w fs.suid_dumpable=0
    sysctl net.ipv6.conf.all.disable_ipv6=1
    sysctl net.ipv6.conf.default.disable_ipv6=1
    sysctl net.ipv6.conf.lo.disable_ipv6=1
    sysctl net.ipv6.conf.all.rp_filter=1
    sysctl net.ipv4.conf.all.rp_filter=1
    sysctl net.ipv4.conf.all.accept_source_route=0
    sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
    sysctl net.ipv4.conf.all.log_martians=1
    sysctl net.ipv4.conf.default.log_martians=1
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl kernel.sysrq=0
    sysctl net.ipv4.tcp_timestamps=0
    sysctl net.ipv4.tcp_syncookies=1
    sysctl net.ipv4.icmp_ignore_bogus_error_responses=1
    sysctl net.ipv4.tcp_syn_retries=2
    sysctl net.ipv4.tcp_synack_retries=2
    sysctl net.ipv4.tcp_max_syn_backlog=2048
    sysctl net.ipv4.tcp_rfc1337=1
    sysctl -p
}

main() {
    sys_upgrades
    unattended_upg
    disable_root
    user_pass_expirations
    remove_atd
    set_av
    disable_avahi
    disable_postfix
    kernel_tuning
    fix_file_permissions
    permission_narrowing
}

main "$@"
