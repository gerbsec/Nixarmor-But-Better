#!/bin/bash
echo "Configuring PAM"
echo "Limiting Password Reuse to not within 5 previous passwords"
# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_unix_remember='5'


if [ -e "/etc/pam.d/common-password" ] ; then
    valueRegex="$var_password_pam_unix_remember" defaultValue="$var_password_pam_unix_remember"
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"password\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_unix.so" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_unix.so)/\\1password\\2/" "/etc/pam.d/common-password"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*password\\s+(?"'!'"[success=1 default=ignore])[[:alnum:]]+\\s+pam_unix.so" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+)[[:alnum:]]+(\\s+pam_unix.so)/\\1[success=1 default=ignore]\\2/" "/etc/pam.d/common-password"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so(\\s.+)?\\s+obscure sha512 shadow remember(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so(\\s.+)?\\s)obscure sha512 shadow remember=[^[:space:]]*/\\1obscure sha512 shadow remember${defaultValue}/" "/etc/pam.d/common-password"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so" < "/etc/pam.d/common-password" &&
            grep    -E "^\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so" < "/etc/pam.d/common-password" | grep -q -E -v "\\sobscure sha512 shadow remember(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so[^\\n]*)/\\1 obscure sha512 shadow remember${defaultValue}/" "/etc/pam.d/common-password"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*password\\s+[success=1 default=ignore]\\s+pam_unix.so(\\s.+)?\\s+obscure sha512 shadow remember${valueRegex}(\\s|\$)" < "/etc/pam.d/common-password" ; then
        echo "password [success=1 default=ignore] pam_unix.so obscure sha512 shadow remember${defaultValue}" >> "/etc/pam.d/common-password"
    fi
else
    echo "/etc/pam.d/common-password doesn't exist" >&2
fi

else
    >&2 echo 'PASSWORD REUSE Remediation is not applicable, nothing was done'
fi

echo "Enforcing Delay after failed logon attempt"
var_password_pam_delay='4000000'


if [ -e "/etc/pam.d/common-auth" ] ; then
    valueRegex="$var_password_pam_delay" defaultValue="$var_password_pam_delay"
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"auth\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_faildelay.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_faildelay.so)/\\1auth\\2/" "/etc/pam.d/common-auth"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*auth\\s+(?"'!'"required)[[:alnum:]]+\\s+pam_faildelay.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+)[[:alnum:]]+(\\s+pam_faildelay.so)/\\1required\\2/" "/etc/pam.d/common-auth"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*auth\\s+required\\s+pam_faildelay.so(\\s.+)?\\s+delay(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_faildelay.so(\\s.+)?\\s)delay=[^[:space:]]*/\\1delay${defaultValue}/" "/etc/pam.d/common-auth"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*auth\\s+required\\s+pam_faildelay.so" < "/etc/pam.d/common-auth" &&
            grep    -E "^\\s*auth\\s+required\\s+pam_faildelay.so" < "/etc/pam.d/common-auth" | grep -q -E -v "\\sdelay(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_faildelay.so[^\\n]*)/\\1 delay${defaultValue}/" "/etc/pam.d/common-auth"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*auth\\s+required\\s+pam_faildelay.so(\\s.+)?\\s+delay${valueRegex}(\\s|\$)" < "/etc/pam.d/common-auth" ; then
        echo "auth required pam_faildelay.so delay${defaultValue}" >> "/etc/pam.d/common-auth"
    fi
else
    echo "/etc/pam.d/common-auth doesn't exist" >&2
fi

var_password_pam_tally2='3'

# Use a non-number regexp to force update of the value of the deny option
if [ -e "/etc/pam.d/common-auth" ] ; then
    valueRegex="°" defaultValue="${var_password_pam_tally2}"
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"auth\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_tally2.so)/\\1auth\\2/" "/etc/pam.d/common-auth"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*auth\\s+(?"'!'"required)[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+)[[:alnum:]]+(\\s+pam_tally2.so)/\\1required\\2/" "/etc/pam.d/common-auth"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s+deny(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s)deny=[^[:space:]]*/\\1deny${defaultValue}/" "/etc/pam.d/common-auth"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*auth\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-auth" &&
            grep    -E "^\\s*auth\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-auth" | grep -q -E -v "\\sdeny(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_tally2.so[^\\n]*)/\\1 deny${defaultValue}/" "/etc/pam.d/common-auth"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s+deny${valueRegex}(\\s|\$)" < "/etc/pam.d/common-auth" ; then
        echo "auth required pam_tally2.so deny${defaultValue}" >> "/etc/pam.d/common-auth"
    fi
else
    echo "/etc/pam.d/common-auth doesn't exist" >&2
fi
if [ -e "/etc/pam.d/common-auth" ] ; then
    valueRegex="(fail)" defaultValue="fail"
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"auth\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_tally2.so)/\\1auth\\2/" "/etc/pam.d/common-auth"
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_tally2.so)/\\1auth\\2/" "/etc/pam.d/common-auth"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*auth\\s+(?"'!'"required)[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+)[[:alnum:]]+(\\s+pam_tally2.so)/\\1required\\2/" "/etc/pam.d/common-auth"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s+onerr(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-auth" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s)onerr=[^[:space:]]*/\\1onerr${defaultValue}/" "/etc/pam.d/common-auth"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*auth\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-auth" &&
            grep    -E "^\\s*auth\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-auth" | grep -q -E -v "\\sonerr(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*auth\\s+required\\s+pam_tally2.so[^\\n]*)/\\1 onerr${defaultValue}/" "/etc/pam.d/common-auth"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*auth\\s+required\\s+pam_tally2.so(\\s.+)?\\s+onerr${valueRegex}(\\s|\$)" < "/etc/pam.d/common-auth" ; then
        echo "auth required pam_tally2.so onerr${defaultValue}" >> "/etc/pam.d/common-auth"
    fi
else
    echo "/etc/pam.d/common-auth doesn't exist" >&2
fi
if [ -e "/etc/pam.d/common-account" ] ; then
    valueRegex="" defaultValue=""
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"account\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-account" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_tally2.so)/\\1account\\2/" "/etc/pam.d/common-account"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*account\\s+(?"'!'"required)[[:alnum:]]+\\s+pam_tally2.so" < "/etc/pam.d/common-account" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*account\\s+)[[:alnum:]]+(\\s+pam_tally2.so)/\\1required\\2/" "/etc/pam.d/common-account"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*account\\s+required\\s+pam_tally2.so(\\s.+)?\\s+(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-account" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*account\\s+required\\s+pam_tally2.so(\\s.+)?\\s)=[^[:space:]]*/\\1${defaultValue}/" "/etc/pam.d/common-account"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*account\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-account" &&
            grep    -E "^\\s*account\\s+required\\s+pam_tally2.so" < "/etc/pam.d/common-account" | grep -q -E -v "\\s(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*account\\s+required\\s+pam_tally2.so[^\\n]*)/\\1 ${defaultValue}/" "/etc/pam.d/common-account"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*account\\s+required\\s+pam_tally2.so(\\s.+)?\\s+${valueRegex}(\\s|\$)" < "/etc/pam.d/common-account" ; then
        echo "account required pam_tally2.so ${defaultValue}" >> "/etc/pam.d/common-account"
    fi
else
    echo "/etc/pam.d/common-account doesn't exist" >&2
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_dcredit='-1'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^dcredit")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_dcredit"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^dcredit\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^dcredit\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_dictcheck='1'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^dictcheck")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_dictcheck"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^dictcheck\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^dictcheck\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_difok='8'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^difok")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_difok"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^difok\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^difok\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

if [ -e "/etc/security/pwquality.conf" ] ; then

    LC_ALL=C sed -i "/^\s*enforcing = 1/Id" "/etc/security/pwquality.conf"
else
    touch "/etc/security/pwquality.conf"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/security/pwquality.conf"

cp "/etc/security/pwquality.conf" "/etc/security/pwquality.conf.bak"
# Insert at the end of the file
printf '%s\n' "enforcing = 1" >> "/etc/security/pwquality.conf"
# Clean up after ourselves.
rm "/etc/security/pwquality.conf.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_lcredit='-1'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^lcredit")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_lcredit"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^lcredit\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^lcredit\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_minlen='10'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^minlen")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_minlen"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^minlen\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^minlen\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_ocredit='-1'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^ocredit")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_ocredit"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^ocredit\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^ocredit\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_retry='3'


if [ -e "/etc/pam.d/common-password" ] ; then
    valueRegex="$var_password_pam_retry" defaultValue="$var_password_pam_retry"
    # non-empty values need to be preceded by an equals sign
    [ -n "${valueRegex}" ] && valueRegex="=${valueRegex}"
    # add an equals sign to non-empty values
    [ -n "${defaultValue}" ] && defaultValue="=${defaultValue}"

    # fix 'type' if it's wrong
    if grep -q -P "^\\s*(?"'!'"password\\s)[[:alnum:]]+\\s+[[:alnum:]]+\\s+pam_pwquality.so" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*)[[:alnum:]]+(\\s+[[:alnum:]]+\\s+pam_pwquality.so)/\\1password\\2/" "/etc/pam.d/common-password"
    fi

    # fix 'control' if it's wrong
    if grep -q -P "^\\s*password\\s+(?"'!'"requisite)[[:alnum:]]+\\s+pam_pwquality.so" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+)[[:alnum:]]+(\\s+pam_pwquality.so)/\\1requisite\\2/" "/etc/pam.d/common-password"
    fi

    # fix the value for 'option' if one exists but does not match 'valueRegex'
    if grep -q -P "^\\s*password\\s+requisite\\s+pam_pwquality.so(\\s.+)?\\s+retry(?"'!'"${valueRegex}(\\s|\$))" < "/etc/pam.d/common-password" ; then
        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+requisite\\s+pam_pwquality.so(\\s.+)?\\s)retry=[^[:space:]]*/\\1retry${defaultValue}/" "/etc/pam.d/common-password"

    # add 'option=default' if option is not set
    elif grep -q -E "^\\s*password\\s+requisite\\s+pam_pwquality.so" < "/etc/pam.d/common-password" &&
            grep    -E "^\\s*password\\s+requisite\\s+pam_pwquality.so" < "/etc/pam.d/common-password" | grep -q -E -v "\\sretry(=|\\s|\$)" ; then

        sed --follow-symlinks -i -E -e "s/^(\\s*password\\s+requisite\\s+pam_pwquality.so[^\\n]*)/\\1 retry${defaultValue}/" "/etc/pam.d/common-password"
    # add a new entry if none exists
    elif ! grep -q -P "^\\s*password\\s+requisite\\s+pam_pwquality.so(\\s.+)?\\s+retry${valueRegex}(\\s|\$)" < "/etc/pam.d/common-password" ; then
        echo "password requisite pam_pwquality.so retry${defaultValue}" >> "/etc/pam.d/common-password"
    fi
else
    echo "/etc/pam.d/common-password doesn't exist" >&2
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

var_password_pam_ucredit='-1'


# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/security/pwquality.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^ucredit")

# shellcheck disable=SC2059
printf -v formatted_output "%s = %s" "$stripped_key" "$var_password_pam_ucredit"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^ucredit\\>" "/etc/security/pwquality.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^ucredit\\>.*/$escaped_formatted_output/gi" "/etc/security/pwquality.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/security/pwquality.conf"
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if dpkg-query --show --showformat='${db:Status-Status}\n' 'libpam-runtime' 2>/dev/null | grep -q installed; then

if [ -e "/etc/pam.d/login" ] ; then
    PAM_FILE_PATH="/etc/pam.d/login"
    if [ -f /usr/bin/authselect ]; then
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"

            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done

            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/login")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
    fi
    if ! grep -qP '^\s*session\s+'"required"'\s+pam_lastlog.so\s*.*' "$PAM_FILE_PATH"; then
            # Line matching group + control + module was not found. Check group + module.
            if [ "$(grep -cP '^\s*session\s+.*\s+pam_lastlog.so\s*' "$PAM_FILE_PATH")" -eq 1 ]; then
                # The control is updated only if one single line matches.
                sed -i -E --follow-symlinks 's/^(\s*session\s+).*(\bpam_lastlog.so.*)/\1'"required"' \2/' "$PAM_FILE_PATH"
            else
                sed -i --follow-symlinks '1i session     '"required"'    pam_lastlog.so' "$PAM_FILE_PATH"
            fi
        fi
        # Check the option
        if ! grep -qP '^\s*session\s+'"required"'\s+pam_lastlog.so\s*.*\sshowfailed\b' "$PAM_FILE_PATH"; then
            sed -i -E --follow-symlinks '/\s*session\s+'"required"'\s+pam_lastlog.so.*/ s/$/ showfailed/' "$PAM_FILE_PATH"
        fi
    if [ -f /usr/bin/authselect ]; then

        authselect apply-changes -b
    fi
else
    echo "/etc/pam.d/login was not found" >&2
fi
if [ -e "/etc/pam.d/login" ] ; then
    PAM_FILE_PATH="/etc/pam.d/login"
    if [ -f /usr/bin/authselect ]; then
        if ! authselect check; then
            echo "
            authselect integrity check failed. Remediation aborted!
            This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
            It is not recommended to manually edit the PAM files when authselect tool is available.
            In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
            exit 1
            fi
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"

            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done

            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/login")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
    fi

if grep -qP '^\s*session\s.*\bpam_lastlog.so\s.*\bsilent\b' "$PAM_FILE_PATH"; then
    sed -i -E --follow-symlinks 's/(.*session.*pam_lastlog.so.*)\bsilent\b=?[[:alnum:]]*(.*)/\1\2/g' "$PAM_FILE_PATH"
fi
    if [ -f /usr/bin/authselect ]; then

        authselect apply-changes -b
    fi
else
    echo "/etc/pam.d/login was not found" >&2
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi
