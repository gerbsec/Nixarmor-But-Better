#!/bin/bash
echo "Session Configuration\n"

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_accounts_max_concurrent_login_sessions='10'


if grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.conf; then
	sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.conf
else
	echo "*	hard	maxlogins	$var_accounts_max_concurrent_login_sessions" >> /etc/security/limits.conf
fi

else
    >&2 echo 'MAX SESSIONS Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

var_accounts_tmout='600'


# if 0, no occurence of tmout found, if 1, occurence found
tmout_found=0

for f in /etc/profile /etc/profile.d/*.sh; do
    if grep --silent '^\s*TMOUT' $f; then
        sed -i -E "s/^(\s*)TMOUT\s*=\s*(\w|\$)*(.*)$/declare -xr TMOUT=$var_accounts_tmout\3/g" $f
        tmout_found=1
    fi
done

if [ $tmout_found -eq 0 ]; then
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile.d/tmout.sh
        echo "declare -xr TMOUT=$var_accounts_tmout" >> /etc/profile.d/tmout.sh
fi

else
    >&2 echo 'SESSION TIMEOUT Remediation is not applicable, nothing was done'
fi


