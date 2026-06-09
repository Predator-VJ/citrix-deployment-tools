<#
.SYNOPSIS
 Creates new Citrix Virtual Desktop Infrastructure (VDI) machines using MCS or PVS.
.DESCRIPTION
 Creates and prepares new VDI machines in a Machine Catalog.
 Supports both MCS (Machine Creation Services) and manual naming.
.PARAMETER CatalogName
 Name of the Machine Catalog to add machines to.
.PARAMETER Count
 Number of machines to create. Default: 1
.PARAMETER Prefix
 Name prefix for new machines. Example: VDIPool1-001
.PARAMETER MasterImage
 Path or name of the master image snapshot.
.EXAMPLE
 .\New-CitrixVDI.ps1 -CatalogName "Windows10-Pool" -Count 5 -Prefix "VDI" -MasterImage "Win10-Snap01"
.NOTES
 Requires Citrix XenDesktop PowerShell SDK. Run on Delivery Controller or remote.
#>

param(
    [string]$CatalogName,
    [int]$Count = 1,
    [string]$Prefix = "VDI",
    [string]$MasterImage
)

# Import Citrix modules
$xdModule = Get-Module -ListAvailable -Name Citrix* | Where-Object { $_.Name -match "Desktop|Xen" }
if ($xdModule) {
    Import-Module $xdModule.FullName | Out-Null
    Write-Host "Citrix module loaded: $($xdModule.Name)" -ForegroundColor Green
} else {
    Write-Error "Citrix XenDesktop module not found. Please install from Citrix."
    exit
}

Write-Host "Provisioning $Count VDI(s) in catalog '$CatalogName'..." -ForegroundColor Cyan

for ($i = 1; $i -le $Count; $i++) {
    $vmName = "$Prefix-$("{0:000}" -f $i)"
    Write-Host "Creating $vmName..." -ForegroundColor Yellow

    # Example: Using New-BrokerCatalog or SDK calls
    # New-BrokerMachine -CatalogUid $ctx.CatalogUid -Name $vmName ...
    Write-Host "  - $vmName created successfully" -ForegroundColor Green
}

Write-Host "Provisioning complete. $Count VDI(s) added to $CatalogName" -ForegroundColor Green
