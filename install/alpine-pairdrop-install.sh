#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: cobalt (cobaltgit)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://pairdrop.net/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
init_error_traps
setting_up_container
network_check
update_os

$STD apk add --no-cache nodejs npm
fetch_and_deploy_gh_release "pairdrop" "schlagmichdoch/PairDrop" "tarball"

msg_info "Configuring PairDrop"
cd /opt/pairdrop
$STD npm install
msg_ok "Installed PairDrop"

msg_info "Creating Service"
cat <<EOF >/etc/init.d/pairdrop
#!/sbin/openrc-run

description="PairDrop Service"
command="npm"
command_args="start"
directory="/opt/pairdrop"
pidfile="/var/run/\${RC_SVCNAME}.pid"
command_background="yes"

depend() {
    need net
    after firewall
}

start_pre() {
    checkpath --directory --owner root:root --mode 0755 \$(dirname "\$pidfile")
}
EOF
chmod +x /etc/init.d/pairdrop
rc-update add pairdrop default
service pairdrop start
msg_ok "Created Service"

motd_ssh
customize


