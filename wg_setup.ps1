$ErrorActionPreference = "Stop"

Write-Output "Parsing WireGuard parameters from wg_setup.conf ..."
$wg_setup = Get-Content wg_setup.conf -Raw

# PowerShell uses dollar signs when assigning variables
$wg_setup = $wg_setup -replace '(?m)(^\w+=)', '$$$1'
Invoke-Expression "$wg_setup"


Write-Output "Generating WireGuard keys ..."

# Generate keys
$local_wg_key = wg genkey
$local_wg_pub = Write-Output $local_wg_key | wg pubkey


Write-Output "Preparing OpenWrt WireGuard configuration ..."
$wg_openwrt_sh = Get-Content common/wg_openwrt.sh -Raw

# PowerShell uses backticks to escape dollar signs
$wg_openwrt_sh = $wg_openwrt_sh -replace '\\\$', '`$'
$wg_openwrt_sh = $ExecutionContext.InvokeCommand.ExpandString($wg_openwrt_sh)


Write-Output "Connecting with OpenWrt machine and applying configuration ..."

# Connect to VM
$vm_wg_pub = ssh $ssh_name "$wg_openwrt_sh"


Write-Output "Creating local WireGuard configuration file ..."

$wg_default = Get-Content common/wg_default.conf -Raw
$wg_default = $ExecutionContext.InvokeCommand.ExpandString($wg_default)
Write-Output "$wg_default" > "$local_wg_if.conf"


Write-Output ""
Write-Output "WireGuard configuration file successfully created at $pwd/$local_wg_if.conf"
Write-Output "You can import the file directly into your WireGuard GUI (Add Tunnel -> Import tunnel(s) from file...)"
Write-Output "Then you can test the connection to your VM: 'ping $(($vm_wg_address -split "/")[0])'"
