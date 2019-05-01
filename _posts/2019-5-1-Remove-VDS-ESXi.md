---
layout: post
title: Remove a VDS-connected ESXi host from vCenter
---

You may encounter an issue with decommissioning an ESXi host (removing from vCenter inventory) when said host is a member of a VDS (vSphere distributed switch).  Even after placing into maintenance mode the "Remove from Inventory" option will still be greyed out.  In these cases, ***the host must first be removed from the VDS***.  In addition, ***the host must be removed from any cluster and disconnected***.  

Of course, this can be done in PowerCLI which is easier for multiple hosts.  In my case, I wanted the scope to be all ESXi hosts which were not connected (Disconnected, Not Responding, or Maintenance Mode):
```ruby
$hosts = Get-VMHost | where{$_.ConnectionState -ne "Connected"}
```
&nbsp;
&nbsp;

Define your VDSwitch and Datacenter, make sure to specify a match criteria relevant to your environment:
```ruby
$vdswitch = Get-VDSwitch | where{$_.Name -imatch "vds"}
$dc = Get-Datacenter
```
&nbsp;
&nbsp;

For each host to be decommissioned, make sure it's disconnected, moved to the top-level Datacenter, and removed from the VDS:
```ruby
foreach($h in $hosts){
if($h.ConnectionState -eq "Connected" -or $h.ConnectionState -imatch "maintenance"){
$h | Set-VMHost -State Disconnected | Out-Null}
$h | Move-VMHost -Destination $dc | Out-Null
$vdswitch | Remove-VDSwitchVMHost -VMHost $h.Name -Confirm:$false
$h | Remove-VMHost -Confirm:$false
}
```
&nbsp;
&nbsp;

Full code below:
```ruby
$hosts = Get-VMHost | where{$_.ConnectionState -ne "Connected"}
$vdswitch = Get-VDSwitch | where{$_.Name -imatch "vds"}
$dc = Get-Datacenter

foreach($h in $hosts){
if($h.ConnectionState -eq "Connected" -or $h.ConnectionState -imatch "maintenance"){
$h | Set-VMHost -State Disconnected | Out-Null}
$h | Move-VMHost -Destination $dc | Out-Null
$vdswitch | Remove-VDSwitchVMHost -VMHost $h.Name -Confirm:$false
$h | Remove-VMHost -Confirm:$false
}
```
