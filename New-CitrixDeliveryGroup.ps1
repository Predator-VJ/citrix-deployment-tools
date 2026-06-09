# New-CitrixDeliveryGroup.ps1
# Create a new Citrix Delivery Group in a XenApp/XenDesktop site

param (
    [Parameter(Mandatory=$true)]
    [string]$DeliveryGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$MachineCatalogName,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Desktops", "Applications")]
    [string]$DeliveryType,
    
    [Parameter(Mandatory=$false)]
    [string]$AdminAddress = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$DeliveryGroupDescription = "",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxTotalSessions = 100
)

Write-Host "Creating Citrix Delivery Group" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "Delivery Group Name: $DeliveryGroupName"
Write-Host "Machine Catalog: $MachineCatalogName"
Write-Host "Delivery Type: $DeliveryType"
Write-Host "Admin Address: $AdminAddress"
Write-Host ""

# Load Citrix Broker PowerShell SDK
try {
    Add-PSSnapin Citrix*Broker -ErrorAction Stop
    Write-Host "Citrix Broker snap-in loaded." -ForegroundColor Green
} catch {
    Write-Error "Broker snap-in not available. Ensure this script runs on a Delivery Controller."
    exit 1
}

# Verify the machine catalog exists
try {
    $catalog = Get-BrokerCatalog -AdminAddress $AdminAddress -Name $MachineCatalogName -ErrorAction Stop
    Write-Host "Machine catalog '$MachineCatalogName' found." -ForegroundColor Green
    Write-Host "  Catalog UID: $($catalog.Uid)"
    Write-Host "  Catalog Type: $($catalog.AllocationType)"
    Write-Host "  Assigned Desktops: $($catalog.AssignedCount)"
} catch {
    Write-Error "Machine catalog '$MachineCatalogName' not found. Cannot create delivery group."
    exit 1
}

Write-Host ""

# Prepare delivery group parameters
$newDeliveryGroupParams = @{
    AdminAddress = $AdminAddress
    Name = $DeliveryGroupName
    Catalog = $MachineCatalogName
    MaxTotalSessions = $MaxTotalSessions
    DeliveryType = $DeliveryType
}

if ($DeliveryGroupDescription) {
    $newDeliveryGroupParams.Description = $DeliveryGroupDescription
}

# Create the delivery group
try {
    Write-Host "Creating delivery group '$DeliveryGroupName'..." -ForegroundColor Yellow
    $newDeliveryGroup = New-BrokerDeliveryGroup @newDeliveryGroupParams
    Write-Host "Delivery group created successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Delivery Group Details:" -ForegroundColor Cyan
    Write-Host "  UID: $($newDeliveryGroup.Uid)"
    Write-Host "  Name: $($newDeliveryGroup.Name)"
    Write-Host "  Type: $($newDeliveryGroup.DeliveryType)"
    Write-Host "  Max Sessions: $($newDeliveryGroup.MaxTotalSessions)"
    Write-Host "  Created: $($newDeliveryGroup.CreationTime)"
} catch {
    Write-Error "Failed to create delivery group: $_"
    exit 1
}

Write-Host ""
Write-Host "Delivery group creation complete." -ForegroundColor Green
