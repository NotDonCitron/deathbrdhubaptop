# BlueBirdHub Complete Setup Script
# This script will:
# 1. Create desktop shortcut
# 2. Install to Program Files
# 3. Set up file associations

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                    BlueBirdHub Setup                         ║
║              Comprehensive Management Tool                   ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "Then navigate to: C:\Users\pasca\BlueBirdHub-Build" -ForegroundColor Yellow
    Write-Host "And run: .\complete_setup.ps1" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "🚀 Starting BlueBirdHub installation..." -ForegroundColor Green
Write-Host ""

# Step 1: Install to Program Files
Write-Host "📁 Step 1: Installing to Program Files..." -ForegroundColor Yellow
try {
    Copy-Item -Path "C:\Users\pasca\BlueBirdHub-Build" -Destination "C:\Program Files\BlueBirdHub" -Recurse -Force
    Write-Host "✅ BlueBirdHub installed to C:\Program Files\BlueBirdHub\" -ForegroundColor Green
    $BlueBirdHubPath = "C:\Program Files\BlueBirdHub\BlueBirdHub.exe"
} catch {
    Write-Host "⚠️  Could not install to Program Files, using current location" -ForegroundColor Yellow
    $BlueBirdHubPath = "C:\Users\pasca\BlueBirdHub-Build\BlueBirdHub.exe"
}

# Step 2: Create desktop shortcut
Write-Host "🖥️  Step 2: Creating desktop shortcut..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\BlueBirdHub.lnk")
    $Shortcut.TargetPath = $BlueBirdHubPath
    $Shortcut.WorkingDirectory = Split-Path $BlueBirdHubPath
    $Shortcut.Description = "BlueBirdHub - Comprehensive Management Tool"
    $Shortcut.Save()
    Write-Host "✅ Desktop shortcut created" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create desktop shortcut: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Add to PATH
Write-Host "🛣️  Step 3: Adding to system PATH..." -ForegroundColor Yellow
try {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    $BlueBirdHubDir = Split-Path $BlueBirdHubPath
    if ($currentPath -notlike "*$BlueBirdHubDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$BlueBirdHubDir", "Machine")
        Write-Host "✅ Added BlueBirdHub to system PATH" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  BlueBirdHub already in system PATH" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️  Could not add to PATH: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 4: Set up file associations
Write-Host "📄 Step 4: Setting up file associations..." -ForegroundColor Yellow

# File associations for BlueBirdHub
$FileAssociations = @{
    ".bbdoc" = "BlueBirdHub Document"
    ".bbproject" = "BlueBirdHub Project"
    ".bbtemplate" = "BlueBirdHub Template"
    ".bbworkflow" = "BlueBirdHub Workflow"
    ".bbteam" = "BlueBirdHub Team Configuration"
    ".bbtask" = "BlueBirdHub Task File"
    ".bbmember" = "BlueBirdHub Member Profile"
}

try {
    foreach ($Extension in $FileAssociations.Keys) {
        $Description = $FileAssociations[$Extension]
        $ProgId = "BlueBirdHub$($Extension.Replace('.', ''))"
        
        # Create file extension registry entry
        New-Item -Path "HKCR:\$Extension" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$Extension" -Name "(Default)" -Value $ProgId -Force
        
        # Create ProgID registry entries
        New-Item -Path "HKCR:\$ProgId" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId" -Name "(Default)" -Value $Description -Force
        
        # Set default icon
        New-Item -Path "HKCR:\$ProgId\DefaultIcon" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId\DefaultIcon" -Name "(Default)" -Value "$BlueBirdHubPath,0" -Force
        
        # Set open command
        New-Item -Path "HKCR:\$ProgId\shell\open\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId\shell\open\command" -Name "(Default)" -Value "`"$BlueBirdHubPath`" `"%1`"" -Force
    }
    
    Write-Host "✅ File associations configured" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set up file associations: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Create sample files
Write-Host "📋 Step 5: Creating sample files..." -ForegroundColor Yellow
try {
    $SamplePath = "$env:USERPROFILE\Desktop\BlueBirdHub Samples"
    New-Item -Path $SamplePath -ItemType Directory -Force | Out-Null
    
    $SampleFiles = @{
        "My Project.bbproject" = @"
BlueBirdHub Project File
========================
Project Name: Team Management System
Description: Streamline team workflows and communication
Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
Priority: High
Team Size: 5 members
"@
        "Development Team.bbteam" = @"
BlueBirdHub Team Configuration
==============================
Team Name: Development Team
Department: Engineering
Manager: Project Lead
Members: 5 active
Meeting Schedule: Daily standup at 9:00 AM
"@
        "Daily Tasks.bbtask" = @"
BlueBirdHub Task List
====================
Date: $(Get-Date -Format 'yyyy-MM-dd')
Priority: High

Tasks:
☐ Review project requirements
☐ Update team documentation
☐ Schedule client meeting
☐ Prepare sprint planning
"@
        "Meeting Notes.bbdoc" = @"
BlueBirdHub Document
===================
Document: Weekly Team Meeting
Date: $(Get-Date -Format 'yyyy-MM-dd')
Attendees: Development Team

Agenda:
1. Project status update
2. Resource allocation
3. Next week's priorities
4. Action items
"@
        "Project Workflow.bbtemplate" = @"
BlueBirdHub Template
===================
Template: Standard Project Workflow
Version: 1.0
Category: Project Management

Workflow Steps:
1. Requirements gathering
2. Planning and design
3. Implementation
4. Testing and review
5. Deployment
6. Post-project review
"@
    }
    
    foreach ($File in $SampleFiles.GetEnumerator()) {
        Set-Content -Path "$SamplePath\$($File.Key)" -Value $File.Value -Encoding UTF8
    }
    
    Write-Host "✅ Sample files created at: $SamplePath" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create sample files: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Refresh shell associations
Write-Host "🔄 Step 6: Refreshing shell associations..." -ForegroundColor Yellow
try {
    $signature = @'
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern void SHChangeNotify(uint wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
'@
    Add-Type -MemberDefinition $signature -Name Shell32 -Namespace Win32
    [Win32.Shell32]::SHChangeNotify(0x08000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
    Write-Host "✅ Shell associations refreshed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not refresh associations: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Installation complete
Write-Host ""
Write-Host @"
🎉 BlueBirdHub installation complete!

Your BlueBirdHub application is ready to use:

📍 Installation Location: $(Split-Path $BlueBirdHubPath)
🖥️  Desktop Shortcut: Created
🛣️  System PATH: Added
📄 File Associations: Configured

You can now:
• Double-click the desktop shortcut to launch BlueBirdHub
• Double-click .bb* files to open them in BlueBirdHub
• Type 'BlueBirdHub' in any command prompt to launch
• Find sample files on your desktop to test functionality

File types that open with BlueBirdHub:
"@ -ForegroundColor Cyan

$FileAssociations.Keys | ForEach-Object { 
    Write-Host "  • $_ - $($FileAssociations[$_])" -ForegroundColor Gray 
}

Write-Host ""
Write-Host "🚀 Ready to streamline your management workflows!" -ForegroundColor Green
Write-Host ""

pause