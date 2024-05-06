#!/bin/ash


setup_if() {
    # Configure WireGuard interface
    uci set network.$vm_wg_if="interface"
    uci set network.$vm_wg_if.proto="wireguard"
    uci set network.$vm_wg_if.listen_port="$wg_port"
    uci set network.$vm_wg_if.addresses="$vm_wg_address"

    # Only generate a private key if there isn't any yet
    uci -q get network.$vm_wg_if.private_key > /dev/null
    if [ \$? -ne 0 ]; then
        # Generate the private key
        vm_wg_key=\$(wg genkey)
        uci set network.$vm_wg_if.private_key="\$vm_wg_key"
    else
        echo "$vm_wg_if already has a private key. Not regenerating" >&2
    fi
}

setup_peer() {
    # Configure WireGuard peer
    uci set network.$vm_wg_peer="wireguard_$vm_wg_if"
    uci set network.$vm_wg_peer.public_key="$local_wg_pub"
    uci set network.$vm_wg_peer.allowed_ips="$local_wg_address"
}

setup_fw() {
    # Configure firewall
    uci set firewall.$vm_wg_if="zone"
    uci set firewall.$vm_wg_if.name="$vm_wg_if"
    uci set firewall.$vm_wg_if.network="$vm_wg_if"
    uci set firewall.$vm_wg_if.input="ACCEPT"
    uci set firewall.$vm_wg_if.output="ACCEPT"
    uci set firewall.$vm_wg_if.forward="ACCEPT"
}

apply() {
    uci commit \$1
    service \$1 restart
}


setup_if
setup_peer
apply network

setup_fw
apply firewall

# Return the public key
wg show $vm_wg_if public-key
