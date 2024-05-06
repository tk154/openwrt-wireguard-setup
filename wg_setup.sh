#!/bin/bash

set -e

echo "Parsing WireGuard parameters from wg_setup.conf ..."

wg_setup=$(cat wg_setup.conf)
eval "$wg_setup"


echo "Generating WireGuard keys ..."

# Generate keys
local_wg_key=$(wg genkey)
local_wg_pub=$(echo $local_wg_key | wg pubkey)


echo "Preparing OpenWrt WireGuard configuration ..."

wg_openwrt_sh=$(cat common/wg_openwrt.sh)
wg_openwrt_sh=$(eval "echo \"$wg_openwrt_sh\"")


echo "Connecting with OpenWrt machine and applying configuration ..."

# Connect to VM
vm_wg_pub=$(ssh $ssh_name "$wg_openwrt_sh")


echo "Creating local WireGuard configuration file ..."

wg_default=$(cat common/wg_default.conf)
wg_default=$(eval "echo \"$wg_default\"")
echo "$wg_default" > "$local_wg_if.conf"


echo "WireGuard configuration file successfully created at $PWD/$local_wg_if.conf"
echo "With privileged rights, run:"
echo -e "\t'cp $PWD/$local_wg_if.conf /etc/wireguard/' to copy it"
echo -e "\t'wg-quick up $local_wg_if' to activate the connection\n"
echo "Then you can test the connection to your VM: 'ping ${vm_wg_address%/*}'"
