<#
.SYNOPSIS
 Checks the health status of Citrix delivery groups and catalogs.
.DESCRIPTION
 Retrieves delivery group details including machine registration status,
 session capacity, and overall health metrics.
.PARAMETER SiteAddress
 Address of the Citrix Broker Service. Default: localhost
.PARAMETER DeliveryGroup
 Name of a specific delivery group to check. Omit to check all.
.EXAMPLE
 .\Get-CitrixDeliveryGroupStatus.ps1
.EXAMPLE
 .\Get-CitrixDeliveryGroupStatus.ps1 -DeliveryGroup "Finance-Desktops"
.NOTES
 Requires Citrix XenDesktop PowerShell SDK.
#>

param(
    [string]$SiteAddress = "localhost",
    [string]$DeliveryGroup
)

# Load Citrix SDK
try {
    $citrixModule = Get-Module -ListAvailable Citrix* | Where-Object { $_.Name -match "Desktop|Xen" }
    if ($citrixModule) {
        Import-Module $citrixModule.FullName -ErrorAction Stop
    }
} catch {
    Write-Error "Failed to load Citrix SDK: $_"
    exit 1
}

Write-Host "Connecting to Citrix Broker Service at $SiteAddress..." -ForegroundColor Cyan

try {
    $ctxBroker = asnp Citrix*Broker -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Broker snap-in not available. Ensure this script runs on a Delivery Controller."
}

# Get delivery groups
$filter = "*"
if ($DeliveryGroup) { $filter = $DeliveryGroup }

deliveryGroups = Get-BrokerDeliveryGroup -AdminAddress $SiteAddress -Filter $filter -ErrorAction SilentlyContinue
if (-not $deliveryGroups) {
    Write-Warning "No delivery groups found matching filter: $filter"
    exit 0
}

Write-Host "Found $($deliveryGroups.Count) delivery group(s)." -ForegroundColor Green
Write-Host ""

foreach ($dg in $deliveryGroups) {
    Write-Host "=== $($dg.Name) ===" -ForegroundColor Yellow
    $total = $dg.TotalCount
    $registered = $dg.RegisteredCount
    $available = $dg.AvailableCount
    $inUse = $dg.InUseCount
    $unregistered = $dg.UnregisteredCount

    Write-Host "  Total Desktops: $total"
    Write-Host "  Registered: $registered | Available: $available | In Use: $inUse | Unregistered: $unregistered"

    if ($dg.RegisteredCount -lt 1) {
        Write-Host "  [!] WARNING: No registered desktops in this group!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Status check complete." -ForegroundColor Green
