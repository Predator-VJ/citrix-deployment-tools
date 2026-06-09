<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:ff512f,50:dd2476,100:ff512f&height=200&section=header&text=Citrix+Deployment+Tools&fontSize=60&fontColor=ffffff&fontAlign=70&animation=fadeIn&fontAlignY=45&desc=PowerShell+scripts+for+CVAD+deployment+and+automation&descAlign=50&descSize=20"/></div>

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Citrix](https://img.shields.io/badge/Citrix-E71E22?style=for-the-badge&logo=citrix&logoColor=white)
![CVAD](https://img.shields.io/badge/CVAD-FFA726?style=for-the-badge)
![Scripts](https://img.shields.io/badge/Scripts-5-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

</div>

<div align="center">
<a href="https://github.com/Predator-VJ/citrix-deployment-tools">
<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=20&pause=1000&color=FFA726&center=true&vCenter=true&multiline=false&width=435&lines=Deploy+Delivery+Groups;Deploy+VDIs+at+Scale;Health+Check+VDAs;StoreFront+Config"/>
</a>
</div>

<br/>

---

## Script Arsenal

| Script | Description | Category |
|---|---|---|
| `Get-CitrixDeliveryGroupStatus.ps1` | Delivery group status & VDA counts | Monitoring |
| `Get-CitrixStoreFrontStatus.ps1` | StoreFront health & configuration | Configuration |
| `Get-CitrixVDIHealth.ps1` | VDA health checks & resource usage | Health Check |
| `New-CitrixDeliveryGroup.ps1` | Create delivery groups | Deployment |
| `New-CitrixVDI.ps1` | Create new VDI machines | Provisioning |

---

## Requirements

- PowerShell 5.1 or later
- Citrix PowerShell SDK (installed with Citrix DDC)
- Permissions to manage Citrix DDC and VDA

## Installation

```powershell
# Ensure Citrix PowerShell SDK is installed
# Import the Citrix modules
Import-Module Citrix.AD.Administration
Import-Module Citrix.Broker.Admin.V2
Import-Module Citrix.StoreFront

# Clone the repository
git clone https://github.com/Predator-VJ/citrix-deployment-tools.git

# Navigate to the directory
cd citrix-deployment-tools
```

## Scripts

### 1. Get-CitrixDeliveryGroupStatus.ps1
Retrieves the status of all Citrix delivery groups in the site.

**Features:**
- Lists all delivery groups with name, UID, desktop type, and state
- Shows registered and total VDA counts
- Identifies delivery groups with unregistered VDAs
- Color-coded output

**Usage:**
```powershell
# Check all delivery groups
.\Get-CitrixDeliveryGroupStatus.ps1

# Check a specific delivery group
.\Get-CitrixDeliveryGroupStatus.ps1 -DeliveryGroupName "MyDeliveryGroup"
```

### 2. Get-CitrixStoreFrontStatus.ps1
Checks the health and configuration status of Citrix StoreFront servers.

**Features:**
- Verifies StoreFront stores are accessible
- Checks application groups and resources
- Reports authentication status
- Monitors enumeration and resource access

**Usage:**
```powershell
# Check StoreFront status
.\Get-CitrixStoreFrontStatus.ps1

# Check a specific Store
.\Get-CitrixStoreFrontStatus.ps1 -StoreName "MyStore"
```

### 3. Get-CitrixVDIHealth.ps1
Performs health checks on Citrix VDA machines.

**Features:**
- Checks VDA registration status
- Monitors CPU and memory usage
- Tracks session counts
- Identifies VDA communication issues
- Color-coded health assessment

**Usage:**
```powershell
# Check all VDAs
.\Get-CitrixVDIHealth.ps1

# Check a specific delivery group
.\Get-CitrixVDIHealth.ps1 -DeliveryGroupName "MyDeliveryGroup"
```

### 4. New-CitrixDeliveryGroup.ps1
Creates a new Citrix delivery group.

**Features:**
- Creates delivery groups with customizable settings
- Sets desktop type (shared, private, public)
- Configures delivery type (desktop, app)
- Assigns delivery group to machine catalog
- Handles existing delivery group conflicts

**Usage:**
```powershell
# Create a simple delivery group
.\New-CitrixDeliveryGroup.ps1 -Name "MyDeliveryGroup" -DesktopKind "Shared"

# Create with delivery type
.\New-CitrixDeliveryGroup.ps1 -Name "MyAppGroup" -DesktopKind "Shared" -DeliveryType "ApplicationsOnly"
```

### 5. New-CitrixVDI.ps1
Creates new Citrix VDA machines for a delivery group.

**Features:**
- Creates VDA machines with specified configuration
- Assigns machines to delivery groups
- Supports both shared and private desktop types
- Error handling for duplicate machines

**Usage:**
```powershell
# Create VDI machines
.\New-CitrixVDI.ps1 -MachineName "VDI" -MachineCount 5

# Create with delivery group assignment
.\New-CitrixVDI.ps1 -MachineName "VDI" -DeliveryGroupName "MyDeliveryGroup" -MachineCount 10
```

---

## Contributing

Contributions are welcome! Feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Maintained by Predator-VJ

---

<div align="center">
<img src="https://badges.pufler.dev/visits/Predator-VJ/citrix-deployment-tools"/>
</div>
