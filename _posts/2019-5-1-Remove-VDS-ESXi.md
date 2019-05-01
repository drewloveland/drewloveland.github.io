---
layout: post
title: Remove a VDS-connected ESXi host from vCenter
---

You may encounter an issue when decommissioning an ESXi host (removing from vCenter inventory) if said host is a member of a VDS (vSphere distributed switch).  Even after placing into maintenance mode the "Remove from Inventory" option will still be greyed out.  Attempting to remove the host via PowerCLI will generate one of the following errors:
```ruby
This method is disabled by 'com.vmware.vcIntegrity'
```
That message is particularly inscrutable.  Or, you may see...
```ruby
Cannot remove the host 'hostname' because it's part of VDS 'VDSwitchname'
```
&nbsp;  
In these cases, ***the host must first be removed from the VDS***. In addition, ***the host must be removed from any cluster and in a Disconnected state***. Of course, this can be done in PowerCLI which is easier for multiple hosts.  
&nbsp;  
First, define the scope: in my case, I wanted to remove all ESXi hosts which were not Connected (Disconnected, Not Responding, or Maintenance Mode):
```ruby
$hosts = Get-VMHost | where{$_.ConnectionState -ne "Connected"}
```
&nbsp;  
Define your VDSwitch and Datacenter, make sure to specify a match criteria relevant to your environment:
```ruby
$vdswitch = Get-VDSwitch | where{$_.Name -imatch "vds"}
$dc = Get-Datacenter
```
&nbsp;  
For each host to be decommissioned, set it to disconnected, move it to the top-level Datacenter, and remove it from the VDS.  After that, issue the `Remove-Host` cmdlet to remove the host from vCenter:
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
Full code below:
[Remove-VMHost-VDS-vCenter.ps1](/scripts/Remove-VMHost-VDS-vCenter.ps1)
&nbsp;  
