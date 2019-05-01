# Assumes a pre-existing vCenter connection
# Define environment & scope
$hosts = @(Get-VMHost | Where-Object{$_.ConnectionState -ne "Connected"} | Sort Name | `
Out-GridView -Title 'Select Hosts to Remove' -OutputMode Multiple)
$vdswitch = Get-VDSwitch | Where-Object{$_.Name -imatch "vds"}
$dc = Get-Datacenter

# Disconnect the host, move it to the root of the Datacenter,
# remove it from the VDS, and remove it from vCenter
foreach($h in $hosts){
if($h.ConnectionState -eq "Connected" -or $h.ConnectionState -imatch "maintenance"){
$h | Set-VMHost -State Disconnected | Out-Null}
$h | Move-VMHost -Destination $dc | Out-Null
$vdswitch | Remove-VDSwitchVMHost -VMHost $h.Name -Confirm:$false
$h | Remove-VMHost -Confirm:$false
}