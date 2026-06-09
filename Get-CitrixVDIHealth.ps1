# Get-CitrixVDIHealth.ps1
# Citrix VDI Health Check Script
# Performs comprehensive health checks on Citrix VDI machines

param (
    [string]$SiteAddress = "localhost",
    [string]$DeliveryGroup = "",
    [string]$MachineName = ""
)

# Load Citrix Broker PowerShell SDK
try {
    Add-PSSnapin Citrix*Broker -ErrorAction Stop
    Write-Host "Citrix Broker snap-in loaded successfully." -ForegroundColor Green
} catch {
    Write-Warning "Broker snap-in not available. Ensure this script runs on a Delivery Controller."
    exit 0
}

Write-Host "Citrix VDI Health Check Script" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "Site Address: $SiteAddress"
Write-Host "Delivery Group Filter: $(if ($DeliveryGroup) { $DeliveryGroup } else { 'All' })"
Write-Host "Machine Name Filter: $(if ($MachineName) { $MachineName } else { 'All' })"
Write-Host ""

# Build filter
$filter = ""
if ($DeliveryGroup) { $filter += "DeliveryGroup -eq '$DeliveryGroup'" }
if ($MachineName) { $filter += if ($filter) { " and " } else { "" }; $filter += "MachineName -like '*$MachineName*'" }

# Get VDI machines
try {
    if ($filter) {
        $vdiMachines = Get-BrokerMachine -AdminAddress $SiteAddress -Filter $filter -ErrorAction SilentlyContinue
    } else {
        $vdiMachines = Get-BrokerMachine -AdminAddress $SiteAddress -ErrorAction SilentlyContinue
    }
} catch {
    Write-Warning "Failed to retrieve VDI machines: $_"
    exit 1
}

if (-not $vdiMachines) {
    Write-Warning "No VDI machines found matching the filter."
    exit 0
}

Write-Host "Found $($vdiMachines.Count) VDI machine(s)." -ForegroundColor Green
Write-Host ""

# Define health status categories
$totalMachines = $vdiMachines.Count
$healthy = 0
$unhealthy = 0
$unavailable = 0
$inMaintenance = 0
$disconnected = 0

foreach ($machine in $vdiMachines) {
    $status = "Unknown"
    
    # Determine health status
    if ($machine.InMaintenanceMode) {
        $status = "Maintenance"
        $inMaintenance++
    } elseif (-not $machine.Available) {
        $status = "Unavailable"
        $unavailable++
    } elseif (-not $machine.Registered) {
        $status = "Unregistered"
        $unhealthy++
    } elseif ($machine.SessionCount -eq 0) {
        $status = "Healthy (Idle)"
        $healthy++
    } elseif ($machine.SessionCount -gt 0) {
        $status = "Healthy (Active - $($machine.SessionCount) sessions)"
        $healthy++
    } else {
        $status = "Healthy"
        $healthy++
    }
    
    # Check connection state
    $connectionState = $machine.ConnectionState
    if ($connectionState -eq "Disconnected") {
        $disconnected++
    }
    
    # Color-code output based on status
    $color = switch -Wildcard ($status) {
        "Healthy*" { "Green" }
        "Maintenance" { "Gray" }
        "Unavailable" { "DarkYellow" }
        "Unregistered" { "Red" }
        default { "White" }
    }
    
    Write-Host "  $($machine.MachineName) - $status" -ForegroundColor $color
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total Machines: $totalMachines"
Write-Host "Healthy: $healthy" -ForegroundColor Green
Write-Host "Unhealthy: $unhealthy" -ForegroundColor Red
Write-Host "Unavailable: $unavailable" -ForegroundColor DarkYellow
Write-Host "In Maintenance: $inMaintenance" -ForegroundColor Gray
Write-Host "Disconnected Sessions: $disconnected"
Write-Host ""

# Calculate health percentage
if ($totalMachines -gt 0) {
    $healthPercentage = [math]::Round(($healthy / $totalMachines) * 100, 2)
    Write-Host "Overall Health: $healthPercentage%" -ForegroundColor $(if ($healthPercentage -ge 80) { "Green" } elseif ($healthPercentage -ge 60) { "DarkYellow" } else { "Red" })
}

Write-Host ""
Write-Host "Health check complete." -ForegroundColor Green
