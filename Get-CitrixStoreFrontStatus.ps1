# Get-CitrixStoreFrontStatus.ps1
# Citrix StoreFront Health and Status Check Script
# Checks StoreFront server status, certificate status, and store availability

param (
    [string]$ServerAddress = "localhost",
    [string]$StoreName = "",n    [int]$Port = 443,
    [string]$CertificateThumbprint = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Citrix StoreFront Status Check Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Server Address: $ServerAddress"
Write-Host "Port: $Port"
Write-Host "Store Name: $(if ($StoreName) { $StoreName } else { 'All' })"
Write-Host ""

# Check if StoreFront IIS web sites are running
Write-Host "=== IIS Web Sites Status ===" -ForegroundColor Yellow
try {
    $sites = Get-Website | Where-Object { $_.Name -like "*Store*" -or $_.Name -like "*Citrix*" }
    foreach ($site in $sites) {
        $status = if ($site.State -eq "Started") { "Running" } else { "Stopped" }
        $color = if ($status -eq "Running") { "Green" } else { "Red" }
        Write-Host "  $($site.Name) - $status" -ForegroundColor $color
    }
    if (-not $sites) {
        Write-Host "  No StoreFront-related web sites found." -ForegroundColor DarkYellow
    }
} catch {
    Write-Warning "Unable to check IIS web sites: $_"
}
Write-Host ""

# Check Citrix StoreFront services
Write-Host "=== Citrix StoreFront Services ===" -ForegroundColor Yellow
$svcNames = @(
    "CitrixAppServer",
    "CitrixDeliveryGroupUsage",
    "CitrixSubscriptionStore",
    "CitrixDesktopRestrictionTable",
    "CitrixSubscriptionSync"
)

foreach ($svc in $svcNames) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        $status = $service.Status
        $color = if ($status -eq "Running") { "Green" } else { "Red" }
        Write-Host "  $svc - $status" -ForegroundColor $color
    } else {
        Write-Host "  $svc - Service not found" -ForegroundColor Gray
    }
}
Write-Host ""

# Test StoreFront URL availability
Write-Host "=== StoreFront URL Availability ===" -ForegroundColor Yellow
$storePaths = "/Citrix/Store", "/Citrix/StoreWeb", "/Citrix/StoreAuthService"
foreach ($path in $storePaths) {
    $url = "https://$ServerAddress$Path"
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing -SkipCertificateCheck -ErrorAction Stop
        $statusCode = $response.StatusCode
        $color = if ($statusCode -eq 200) { "Green" } else { "DarkYellow" }
        Write-Host "  $url - HTTP $statusCode" -ForegroundColor $color
    } catch {
        Write-Host "  $url - UNREACHABLE" -ForegroundColor Red
    }
}
Write-Host ""

# Check SSL certificate
Write-Host "=== SSL Certificate Status ===" -ForegroundColor Yellow
try {
    $cert = Get-Item -Path "HKLM:\SOFTWARE\Citrix\SecureICA\SSLCertThumbprint" -ErrorAction SilentlyContinue
    if ($cert) {
        if ($CertificateThumbprint) {
            $certFound = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -replace " ", "" -eq $CertificateThumbprint -replace " ", "" }
            if ($certFound) {
                Write-Host "  Certificate found: $($certFound.Subject)" -ForegroundColor Green
                Write-Host "  Valid until: $($certFound.NotAfter)" -ForegroundColor Green
                if ($certFound.NotAfter -lt (Get-Date)) {
                    Write-Host "  WARNING: Certificate has EXPIRED!" -ForegroundColor Red
                }
            } else {
                Write-Host "  Certificate not found in certificate store" -ForegroundColor Red
            }
        } else {
            $allCerts = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -like "*$ServerAddress*" }
            foreach ($certItem in $allCerts) {
                $expired = if ($certItem.NotAfter -lt (Get-Date)) { " EXPIRED" } else { ""
                Write-Host "  $($certItem.Subject) - Valid until: $($certItem.NotAfter)$($expired)" -ForegroundColor $(if ($expired) { "Red" } else { "Green" })
            }
        }
    } else {
        Write-Host "  No SSL thumbprint configured in Citrix StoreFront" -ForegroundColor DarkYellow
    }
} catch {
    Write-Warning "Unable to check SSL certificate: $_"
}
Write-Host ""

# Check application and desktop enumeration
Write-Host "=== Store Enumeration Status ===" -ForegroundColor Yellow
try {
    Import-Module Citrix.StoreFront
    $stores = Get-STFStoreService
    foreach ($store in $stores) {
        if (-not $StoreName -or $store.Name -like "*$StoreName*") {
            $status = if ($store.Enabled) { "Enabled" } else { "Disabled" }
            $color = if ($status -eq "Enabled") { "Green" } else { "Red" }
            Write-Host "  $($store.Name) - $status (BaseURL: $($store.VirtualPath))" -ForegroundColor $color
        }
    }
} catch {
    Write-Warning "Unable to enumerate stores: $_"
}
Write-Host ""

Write-Host "Status check complete." -ForegroundColor Green
