#!/bin/bash
echo "Configuring Gnome"
## Enable GNOME3 Screensaver Lock After Idle Period
if dpkg-query --show --showformat='${db:Status-Status}\n' 'gdm3' 2>/dev/null | grep -q installed && { [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; }; then

# Check for setting in any of the DConf db directories
# If files contain ibus or distro, ignore them.
# The assignment assumes that individual filenames don't contain :
readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/desktop/screensaver\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
DBDIR="/etc/dconf/db/local.d"

mkdir -p "${DBDIR}"

if [ "${#SETTINGSFILES[@]}" -eq 0 ]
then
    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
    printf '%s\n' "[org/gnome/desktop/screensaver]" >> ${DCONFFILE}
    printf '%s=%s\n' "lock-enabled" "true" >> ${DCONFFILE}
else
    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "true")"
    if grep -q "^\\s*lock-enabled\\s*=" "${SETTINGSFILES[@]}"
    then

        sed -i "s/\\s*lock-enabled\\s*=\\s*.*/lock-enabled=${escaped_value}/g" "${SETTINGSFILES[@]}"
    else
        sed -i "\\|\\[org/gnome/desktop/screensaver\\]|a\\lock-enabled=${escaped_value}" "${SETTINGSFILES[@]}"
    fi
fi

dconf update
# Check for setting in any of the DConf db directories
LOCKFILES=$(grep -r "^/org/gnome/desktop/screensaver/lock-enabled$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
LOCKSFOLDER="/etc/dconf/db/local.d/locks"

mkdir -p "${LOCKSFOLDER}"

if [[ -z "${LOCKFILES}" ]]
then
    echo "/org/gnome/desktop/screensaver/lock-enabled" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
fi

dconf update

else
    >&2 echo 'Error: Could not Enable GNOME3 Screensaver Lock After Idle Period'
fi


## Disable Ctrl-Alt-Del Reboot Key Sequence in GNOME3
if dpkg-query --show --showformat='${db:Status-Status}\n' 'gdm3' 2>/dev/null | grep -q installed && { [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; }; then

# Check for setting in any of the DConf db directories
# If files contain ibus or distro, ignore them.
# The assignment assumes that individual filenames don't contain :
readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/settings-daemon/plugins/media-keys\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
DCONFFILE="/etc/dconf/db/local.d/00-security-settings"
DBDIR="/etc/dconf/db/local.d"

mkdir -p "${DBDIR}"

if [ "${#SETTINGSFILES[@]}" -eq 0 ]
then
    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
    printf '%s\n' "[org/gnome/settings-daemon/plugins/media-keys]" >> ${DCONFFILE}
    printf '%s=%s\n' "logout" "''" >> ${DCONFFILE}
else
    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "''")"
    if grep -q "^\\s*logout\\s*=" "${SETTINGSFILES[@]}"
    then

        sed -i "s/\\s*logout\\s*=\\s*.*/logout=${escaped_value}/g" "${SETTINGSFILES[@]}"
    else
        sed -i "\\|\\[org/gnome/settings-daemon/plugins/media-keys\\]|a\\logout=${escaped_value}" "${SETTINGSFILES[@]}"
    fi
fi

dconf update
# Check for setting in any of the DConf db directories
LOCKFILES=$(grep -r "^/org/gnome/settings-daemon/plugins/media-keys/logout$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
LOCKSFOLDER="/etc/dconf/db/local.d/locks"

mkdir -p "${LOCKSFOLDER}"

if [[ -z "${LOCKFILES}" ]]
then
    echo "/org/gnome/settings-daemon/plugins/media-keys/logout" >> "/etc/dconf/db/local.d/locks/00-security-settings-lock"
fi

dconf update

else
    >&2 echo 'Error: Could not Disable Ctrl-Alt-Del Reboot Key Sequence in GNOME3'
fi


## Enable GNOME3 Login Warning Banner
if dpkg-query --show --showformat='${db:Status-Status}\n' 'gdm3' 2>/dev/null | grep -q installed; then

login_banner_text='^(You[\s\n]+are[\s\n]+accessing[\s\n]+a[\s\n]+Death[\s\n]+Star[\s\n]+Development[\s\n]+\(DSD\)[\s\n]+Information[\s\n]+System[\s\n]+\(IS\)[\s\n]+that[\s\n]+is[\s\n]+provided[\s\n]+for[\s\n]+DSD\-authorized[\s\n]+use[\s\n]+only\.[\s\n]+By[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+\(which[\s\n]+includes[\s\n]+any[\s\n]+device[\s\n]+attached[\s\n]+to[\s\n]+this[\s\n]+IS\)\,[\s\n]+you[\s\n]+consent[\s\n]+to[\s\n]+the[\s\n]+following[\s\n]+conditions\:(?:[\n]+|(?:\\n)+)\-The[\s\n]+DSD[\s\n]+routinely[\s\n]+intercepts[\s\n]+and[\s\n]+monitors[\s\n]+communications[\s\n]+on[\s\n]+this[\s\n]+IS[\s\n]+for[\s\n]+purposes[\s\n]+including\,[\s\n]+but[\s\n]+not[\s\n]+limited[\s\n]+to\,[\s\n]+penetration[\s\n]+testing\,[\s\n]+COMSEC[\s\n]+monitoring\,[\s\n]+network[\s\n]+operations[\s\n]+and[\s\n]+defense\,[\s\n]+personnel[\s\n]+misconduct[\s\n]+\(PM\)\,[\s\n]+law[\s\n]+enforcement[\s\n]+\(LE\)\,[\s\n]+and[\s\n]+counterintelligence[\s\n]+\(CI\)[\s\n]+investigations\.(?:[\n]+|(?:\\n)+)\-At[\s\n]+any[\s\n]+time\,[\s\n]+the[\s\n]+USG[\s\n]+may[\s\n]+inspect[\s\n]+and[\s\n]+seize[\s\n]+data[\s\n]+stored[\s\n]+on[\s\n]+this[\s\n]+IS\.(?:[\n]+|(?:\\n)+)\-Communications[\s\n]+using\,[\s\n]+or[\s\n]+data[\s\n]+stored[\s\n]+on\,[\s\n]+this[\s\n]+IS[\s\n]+are[\s\n]+not[\s\n]+private\,[\s\n]+are[\s\n]+subject[\s\n]+to[\s\n]+routine[\s\n]+monitoring\,[\s\n]+interception\,[\s\n]+and[\s\n]+search\,[\s\n]+and[\s\n]+may[\s\n]+be[\s\n]+disclosed[\s\n]+or[\s\n]+used[\s\n]+for[\s\n]+any[\s\n]+DSD\-authorized[\s\n]+purpose\.(?:[\n]+|(?:\\n)+)\-This[\s\n]+IS[\s\n]+includes[\s\n]+security[\s\n]+measures[\s\n]+\(e\.g\.\,[\s\n]+authentication[\s\n]+and[\s\n]+access[\s\n]+controls\)[\s\n]+to[\s\n]+protect[\s\n]+DSD[\s\n]+interests\-\-not[\s\n]+for[\s\n]+your[\s\n]+personal[\s\n]+benefit[\s\n]+or[\s\n]+privacy\.(?:[\n]+|(?:\\n)+)\-Notwithstanding[\s\n]+the[\s\n]+above\,[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+does[\s\n]+not[\s\n]+constitute[\s\n]+consent[\s\n]+to[\s\n]+PM\,[\s\n]+LE[\s\n]+or[\s\n]+CI[\s\n]+investigative[\s\n]+searching[\s\n]+or[\s\n]+monitoring[\s\n]+of[\s\n]+the[\s\n]+content[\s\n]+of[\s\n]+privileged[\s\n]+communications\,[\s\n]+or[\s\n]+work[\s\n]+product\,[\s\n]+related[\s\n]+to[\s\n]+personal[\s\n]+representation[\s\n]+or[\s\n]+services[\s\n]+by[\s\n]+attorneys\,[\s\n]+psychotherapists\,[\s\n]+or[\s\n]+clergy\,[\s\n]+and[\s\n]+their[\s\n]+assistants\.[\s\n]+Such[\s\n]+communications[\s\n]+and[\s\n]+work[\s\n]+product[\s\n]+are[\s\n]+private[\s\n]+and[\s\n]+confidential\.[\s\n]+See[\s\n]+User[\s\n]+Agreement[\s\n]+for[\s\n]+details\.|I've[\s\n]+read[\s\n]+\and[\s\n]+consent[\s\n]+to[\s\n]+terms[\s\n]+in[\s\n]+IS[\s\n]+user[\s\n]+agreem't\.)$'


# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
login_banner_text=$(echo "$login_banner_text" | sed 's/^\^\(.*\)\$$/\1/g')
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
login_banner_text=$(echo "$login_banner_text" | sed 's/^(\(.*\.\)|.*)$/\1/g')
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
login_banner_text=$(echo "$login_banner_text" | sed 's/\[\\s\\n\]+/ /g')
# 3 - Adds newline "tokens". (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "(n)*")
login_banner_text=$(echo "$login_banner_text" | sed 's/(?:\[\\n\]+|(?:\\\\n)+)/(n)*/g')
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
login_banner_text=$(echo "$login_banner_text" | sed 's/\\//g')
# 5 - Removes the newline "token." (Transforms them into newline escape sequences "\n").
#    ( Needs to be done after 4, otherwise the escapce sequence will become just "n".
login_banner_text=$(echo "$login_banner_text" | sed 's/(n)\*/\\n/g')

# Will do both approach, since we plan to migrate to checks over dconf db. That way, future updates of the tool
# will pass the check even if we decide to check only for the dconf db path.
	
if [ -e "/etc/gdm3/greeter.dconf-defaults" ] ; then    
    LC_ALL=C sed -i "/^\s*banner\-message\-text/Id" "/etc/gdm3/greeter.dconf-defaults"
else
    sudo touch "/etc/gdm3/greeter.dconf-defaults"
fi
# make sure file has newline at the end
sudo sed -i -e '$a\' "/etc/gdm3/greeter.dconf-defaults"

sudo cp "/etc/gdm3/greeter.dconf-defaults" "/etc/gdm3/greeter.dconf-defaults.bak"
# Insert after the line matching the regex '\[org/gnome/login-screen\]'
line_number="$(LC_ALL=C grep -n "\[org/gnome/login-screen\]" "/etc/gdm3/greeter.dconf-defaults.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '\[org/gnome/login-screen\]', insert at
    # the end of the file.
    printf '%s\n' "banner-message-text='${login_banner_text}'" >> "/etc/gdm3/greeter.dconf-defaults"
else
    head -n "$(( line_number ))" "/etc/gdm3/greeter.dconf-defaults.bak" > "/etc/gdm3/greeter.dconf-defaults"
    printf '%s\n' "banner-message-text='${login_banner_text}'" >> "/etc/gdm3/greeter.dconf-defaults"
    tail -n "+$(( line_number + 1 ))" "/etc/gdm3/greeter.dconf-defaults.bak" >> "/etc/gdm3/greeter.dconf-defaults"
fi
# Clean up after ourselves.
sudo rm "/etc/gdm3/greeter.dconf-defaults.bak"


# Check for setting in any of the DConf db directories
# If files contain ibus or distro, ignore them.
# The assignment assumes that individual filenames don't contain :
readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/login-screen\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
DCONFFILE="/etc/dconf/db/gdm.d/00-security-settings"
DBDIR="/etc/dconf/db/gdm.d"

mkdir -p "${DBDIR}"

if [ "${#SETTINGSFILES[@]}" -eq 0 ]
then
    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
    printf '%s\n' "[org/gnome/login-screen]" >> ${DCONFFILE}
    printf '%s=%s\n' "banner-message-text" "'${login_banner_text}'" >> ${DCONFFILE}
else
    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "'${login_banner_text}'")"
    if grep -q "^\\s*banner-message-text\\s*=" "${SETTINGSFILES[@]}"
    then
        
        sed -i "s/\\s*banner-message-text\\s*=\\s*.*/banner-message-text=${escaped_value}/g" "${SETTINGSFILES[@]}"
    else
        sed -i "\\|\\[org/gnome/login-screen\\]|a\\banner-message-text=${escaped_value}" "${SETTINGSFILES[@]}"
    fi
fi

dconf update
# No need to use dconf update, since bash_dconf_settings does that already

else
    >&2 echo 'Error: Could not Enable GNOME3 Login Warning Banner'
fi


### Set the GNOME3 Login Warning Banner Text
#if dpkg-query --show --showformat='${db:Status-Status}\n' 'gdm3' 2>/dev/null | grep -q installed; then
#
## Check for setting in any of the DConf db directories
## If files contain ibus or distro, ignore them.
## The assignment assumes that individual filenames don't contain :
#readarray -t SETTINGSFILES < <(grep -r "\\[org/gnome/login-screen\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
#DCONFFILE="/etc/dconf/db/gdm.d/00-security-settings"
#DBDIR="/etc/dconf/db/gdm.d"
#
#mkdir -p "${DBDIR}"
#
#if [ "${#SETTINGSFILES[@]}" -eq 0 ]
#then
#    [ ! -z ${DCONFFILE} ] || echo "" >> ${DCONFFILE}
#    printf '%s\n' "[org/gnome/login-screen]" >> ${DCONFFILE}
#    printf '%s=%s\n' "banner-message-enable" "true" >> ${DCONFFILE}
#else
#    escaped_value="$(sed -e 's/\\/\\\\/g' <<< "true")"
#    if grep -q "^\\s*banner-message-enable\\s*=" "${SETTINGSFILES[@]}"
#    then
#
#        sed -i "s/\\s*banner-message-enable\\s*=\\s*.*/banner-message-enable=${escaped_value}/g" "${SETTINGSFILES[@]}"
#    else
#        sed -i "\\|\\[org/gnome/login-screen\\]|a\\banner-message-enable=${escaped_value}" "${SETTINGSFILES[@]}"
#    fi
#fi
#
#dconf update
## Check for setting in any of the DConf db directories
#LOCKFILES=$(grep -r "^/org/gnome/login-screen/banner-message-enable$" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d":" -f1)
#LOCKSFOLDER="/etc/dconf/db/gdm.d/locks"
#
#mkdir -p "${LOCKSFOLDER}"
#
#if [[ -z "${LOCKFILES}" ]]
#then
#    echo "/org/gnome/login-screen/banner-message-enable" >> "/etc/dconf/db/gdm.d/locks/00-security-settings-lock"
#fi
#
#dconf update
#
#else
#    >&2 echo 'Error: Cannot Set the GNOME3 Login Warning Banner Text'
#fi


## Modify the System Login Banner
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

login_banner_text='^(You[\s\n]+are[\s\n]+accessing[\s\n]+a[\s\n]+Death[\s\n]+Star[\s\n]+Development[\s\n]+\(DSD\)[\s\n]+Information[\s\n]+System[\s\n]+\(IS\)[\s\n]+that[\s\n]+is[\s\n]+provided[\s\n]+for[\s\n]+DSD\-authorized[\s\n]+use[\s\n]+only\.[\s\n]+By[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+\(which[\s\n]+includes[\s\n]+any[\s\n]+device[\s\n]+attached[\s\n]+to[\s\n]+this[\s\n]+IS\)\,[\s\n]+you[\s\n]+consent[\s\n]+to[\s\n]+the[\s\n]+following[\s\n]+conditions\:(?:[\n]+|(?:\\n)+)\-The[\s\n]+DSD[\s\n]+routinely[\s\n]+intercepts[\s\n]+and[\s\n]+monitors[\s\n]+communications[\s\n]+on[\s\n]+this[\s\n]+IS[\s\n]+for[\s\n]+purposes[\s\n]+including\,[\s\n]+but[\s\n]+not[\s\n]+limited[\s\n]+to\,[\s\n]+penetration[\s\n]+testing\,[\s\n]+COMSEC[\s\n]+monitoring\,[\s\n]+network[\s\n]+operations[\s\n]+and[\s\n]+defense\,[\s\n]+personnel[\s\n]+misconduct[\s\n]+\(PM\)\,[\s\n]+law[\s\n]+enforcement[\s\n]+\(LE\)\,[\s\n]+and[\s\n]+counterintelligence[\s\n]+\(CI\)[\s\n]+investigations\.(?:[\n]+|(?:\\n)+)\-At[\s\n]+any[\s\n]+time\,[\s\n]+the[\s\n]+USG[\s\n]+may[\s\n]+inspect[\s\n]+and[\s\n]+seize[\s\n]+data[\s\n]+stored[\s\n]+on[\s\n]+this[\s\n]+IS\.(?:[\n]+|(?:\\n)+)\-Communications[\s\n]+using\,[\s\n]+or[\s\n]+data[\s\n]+stored[\s\n]+on\,[\s\n]+this[\s\n]+IS[\s\n]+are[\s\n]+not[\s\n]+private\,[\s\n]+are[\s\n]+subject[\s\n]+to[\s\n]+routine[\s\n]+monitoring\,[\s\n]+interception\,[\s\n]+and[\s\n]+search\,[\s\n]+and[\s\n]+may[\s\n]+be[\s\n]+disclosed[\s\n]+or[\s\n]+used[\s\n]+for[\s\n]+any[\s\n]+DSD\-authorized[\s\n]+purpose\.(?:[\n]+|(?:\\n)+)\-This[\s\n]+IS[\s\n]+includes[\s\n]+security[\s\n]+measures[\s\n]+\(e\.g\.\,[\s\n]+authentication[\s\n]+and[\s\n]+access[\s\n]+controls\)[\s\n]+to[\s\n]+protect[\s\n]+DSD[\s\n]+interests\-\-not[\s\n]+for[\s\n]+your[\s\n]+personal[\s\n]+benefit[\s\n]+or[\s\n]+privacy\.(?:[\n]+|(?:\\n)+)\-Notwithstanding[\s\n]+the[\s\n]+above\,[\s\n]+using[\s\n]+this[\s\n]+IS[\s\n]+does[\s\n]+not[\s\n]+constitute[\s\n]+consent[\s\n]+to[\s\n]+PM\,[\s\n]+LE[\s\n]+or[\s\n]+CI[\s\n]+investigative[\s\n]+searching[\s\n]+or[\s\n]+monitoring[\s\n]+of[\s\n]+the[\s\n]+content[\s\n]+of[\s\n]+privileged[\s\n]+communications\,[\s\n]+or[\s\n]+work[\s\n]+product\,[\s\n]+related[\s\n]+to[\s\n]+personal[\s\n]+representation[\s\n]+or[\s\n]+services[\s\n]+by[\s\n]+attorneys\,[\s\n]+psychotherapists\,[\s\n]+or[\s\n]+clergy\,[\s\n]+and[\s\n]+their[\s\n]+assistants\.[\s\n]+Such[\s\n]+communications[\s\n]+and[\s\n]+work[\s\n]+product[\s\n]+are[\s\n]+private[\s\n]+and[\s\n]+confidential\.[\s\n]+See[\s\n]+User[\s\n]+Agreement[\s\n]+for[\s\n]+details\.|I've[\s\n]+read[\s\n]+\and[\s\n]+consent[\s\n]+to[\s\n]+terms[\s\n]+in[\s\n]+IS[\s\n]+user[\s\n]+agreem't\.)$'

# Multiple regexes transform the banner regex into a usable banner
# 0 - Remove anchors around the banner text
login_banner_text=$(echo "$login_banner_text" | sed 's/^\^\(.*\)\$$/\1/g')
# 1 - Keep only the first banners if there are multiple
#    (dod_banners contains the long and short banner)
login_banner_text=$(echo "$login_banner_text" | sed 's/^(\(.*\.\)|.*)$/\1/g')
# 2 - Add spaces ' '. (Transforms regex for "space or newline" into a " ")
login_banner_text=$(echo "$login_banner_text" | sed 's/\[\\s\\n\]+/ /g')
# 3 - Adds newlines. (Transforms "(?:\[\\n\]+|(?:\\n)+)" into "\n")
login_banner_text=$(echo "$login_banner_text" | sed 's/(?:\[\\n\]+|(?:\\\\n)+)/\n/g')
# 4 - Remove any leftover backslash. (From any parethesis in the banner, for example).
login_banner_text=$(echo "$login_banner_text" | sed 's/\\//g')
formatted=$(echo "$login_banner_text" | fold -sw 80)

cat <<EOF >/etc/issue.net
$login_banner_text
EOF

else
    >&2 echo 'Error: Cannot Modify the System Login Banner'
fi

## Disable Ctrl-Alt-Del Burst Action
if dpkg-query --show --showformat='${db:Status-Status}\n' 'systemd' 2>/dev/null | grep -q installed; then

# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/systemd/system.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^CtrlAltDelBurstAction=")

# shellcheck disable=SC2059
printf -v formatted_output "%s=%s" "$stripped_key" "none"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^CtrlAltDelBurstAction=\\>" "/etc/systemd/system.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^CtrlAltDelBurstAction=\\>.*/$escaped_formatted_output/gi" "/etc/systemd/system.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/systemd/system.conf"
fi

else
    >&2 echo 'Error: Cannot Disable Ctrl-Alt-Del Burst Action'
fi


## Disable Ctrl-Alt-Del Reboot Activation
if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

systemctl disable --now ctrl-alt-del.target
systemctl mask --now ctrl-alt-del.target

else
    >&2 echo 'Error: Cannot Disable Ctrl-Alt-Del Reboot Activation'
fi

