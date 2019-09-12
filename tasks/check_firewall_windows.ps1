# check firewall status

$FirewallStatus = 0

$SysFirewallReg1 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg1 -eq 1) {
    $FirewallStatus = 1
}

$SysFirewallReg2 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg2 -eq 1) {
    $FirewallStatus = ($FirewallStatus + 1)
}

$SysFirewallReg3 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg3 -eq 1) {
    $FirewallStatus = ($FirewallStatus + 1)
}

if ($FirewallStatus -ne 0) {
    $status = "enabled"
} else {
    $status = "disabled"
}

$result = @{ "firewall" = $status }

ConvertTo-Json -InputObject $result -Compress
