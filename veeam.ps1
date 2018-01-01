##################################################################
#         User Defined Variables
##################################################################

# Names of VMs to backup separated by comma (Mandatory). For instance, $VMNames = “VM1”,”VM2”
#$VMNames = "Open VPN Appliance"
$VMNames = "VM1", "VM2"

# Name of vCenter or standalone host VMs to backup reside on (Mandatory)
$HostName = "192.168.1.XX"

# Directory that VM backups should go to (Mandatory; for instance, C:\Backup)
$Directory = "C:\Veeam Backups"

# Desired compression level (Optional; Possible values: 0 - None, 4 - Dedupe-friendly, 5 - Optimal, 6 - High, 9 - Extreme) 
$CompressionLevel = "5"

# Quiesce VM when taking snapshot (Optional; VMware Tools are required; Possible values: $True/$False)
$EnableQuiescence = $False


# Retention settings (Optional; By default, VeeamZIP files are not removed and kept in the specified location for an indefinite period of time. 
# Possible values: Never , Tonight, TomorrowNight, In3days, In1Week, In2Weeks, In1Month)
$Retention = "Never"

$year = (Get-Date).Year
$month = (Get-Date).Month
$day = (Get-Date).Day

$path = $Directory+"\$year"

if (-not (Test-Path $path))
{
    New-Item $path -type directory 
}

$path = $Directory+"\$year"+"\$month"

if (-not (Test-Path $path))
{
    New-Item $path -type directory 
}

$path = $Directory+"\$year"+"\$month"+"\$day"

if (-not (Test-Path $path))
{
    New-Item $path -type directory 
}

$newPath = $Directory+"\$year"+"\$month"+"\$day"


##################################################################
#                   End User Defined Variables
##################################################################

#################### DO NOT MODIFY PAST THIS LINE ################
Asnp VeeamPSSnapin

$Server = Get-VBRServer -name $HostName

foreach ($VMName in $VMNames)
{
  $VM = Find-VBRHvEntity -Name $VMName -Server $Server
  
  
  $ZIPSession = Start-VBRZip -Entity $VM -Folder $newPath -Compression $CompressionLevel -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $Retention
  
}


$limit = (Get-Date).AddDays(-1)

Write-Output "Deleting Old Backups"



# Delete files older than the $limit.
Get-ChildItem -Path $Directory -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

# Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $Directory -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
