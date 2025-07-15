# BlueBirdHub Complete Setup Script
# This script will:
# 1. Create desktop shortcut
# 2. Install to Program Files
# 3. Set up file associations

Write-Host "BlueBirdHub Setup - Comprehensive Management Tool" -ForegroundColor Cyan

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "Then navigate to: C:\Users\pasca\BlueBirdHub-Build" -ForegroundColor Yellow
    Write-Host "And run: .\complete_setup_fixed.ps1" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Starting BlueBirdHub installation..." -ForegroundColor Green
Write-Host ""

# Step 1: Install to Program Files
Write-Host "Step 1: Installing to Program Files..." -ForegroundColor Yellow
try {
    Copy-Item -Path "C:\Users\pasca\BlueBirdHub-Build" -Destination "C:\Program Files\BlueBirdHub" -Recurse -Force
    Write-Host "SUCCESS: BlueBirdHub installed to C:\Program Files\BlueBirdHub\" -ForegroundColor Green
    $BlueBirdHubPath = "C:\Program Files\BlueBirdHub\BlueBirdHub.exe"
} catch {
    Write-Host "WARNING: Could not install to Program Files, using current location" -ForegroundColor Yellow
    $BlueBirdHubPath = "C:\Users\pasca\BlueBirdHub-Build\BlueBirdHub.exe"
}

# Step 2: Create desktop shortcut
Write-Host "Step 2: Creating desktop shortcut..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\BlueBirdHub.lnk")
    $Shortcut.TargetPath = $BlueBirdHubPath
    $Shortcut.WorkingDirectory = Split-Path $BlueBirdHubPath
    $Shortcut.Description = "BlueBirdHub - Comprehensive Management Tool"
    $Shortcut.Save()
    Write-Host "SUCCESS: Desktop shortcut created" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create desktop shortcut: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Add to PATH
Write-Host "Step 3: Adding to system PATH..." -ForegroundColor Yellow
try {
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    $BlueBirdHubDir = Split-Path $BlueBirdHubPath
    if ($currentPath -notlike "*$BlueBirdHubDir*") {
        $newPath = "$currentPath;$BlueBirdHubDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "SUCCESS: Added BlueBirdHub to system PATH" -ForegroundColor Green
    } else {
        Write-Host "INFO: BlueBirdHub already in system PATH" -ForegroundColor Cyan
    }
} catch {
    Write-Host "WARNING: Could not add to PATH: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 4: Set up file associations
Write-Host "Step 4: Setting up file associations..." -ForegroundColor Yellow

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
        $openCommand = "`"$BlueBirdHubPath`" `"%1`""
        Set-ItemProperty -Path "HKCR:\$ProgId\shell\open\command" -Name "(Default)" -Value $openCommand -Force
    }
    
    Write-Host "SUCCESS: File associations configured" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to set up file associations: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Create sample files
Write-Host "Step 5: Creating sample files..." -ForegroundColor Yellow
try {
    $SamplePath = "$env:USERPROFILE\Desktop\BlueBirdHub Samples"
    New-Item -Path $SamplePath -ItemType Directory -Force | Out-Null
    
    # Create sample files with simple content
    $CurrentDate = Get-Date -Format 'yyyy-MM-dd HH:mm'
    
    $ProjectContent = @"
BlueBirdHub Project File
========================
Project Name: Team Management System
Description: Streamline team workflows and communication
Created: $CurrentDate
Priority: High
Team Size: 5 members
"@

    $TeamContent = @"
BlueBirdHub Team Configuration
==============================
Team Name: Development Team
Department: Engineering
Manager: Project Lead
Members: 5 active
Meeting Schedule: Daily standup at 9:00 AM
"@

    $TaskContent = @"
BlueBirdHub Task List
====================
Date: $CurrentDate
Priority: High

Tasks:
- Review project requirements
- Update team documentation
- Schedule client meeting
- Prepare sprint planning
"@

    $DocContent = @"
BlueBirdHub Document
===================
Document: Weekly Team Meeting
Date: $CurrentDate
Attendees: Development Team

Agenda:
1. Project status update
2. Resource allocation
3. Next week priorities
4. Action items
"@

    $TemplateContent = @"
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

    # Write the files
    Set-Content -Path "$SamplePath\My Project.bbproject" -Value $ProjectContent -Encoding UTF8
    Set-Content -Path "$SamplePath\Development Team.bbteam" -Value $TeamContent -Encoding UTF8
    Set-Content -Path "$SamplePath\Daily Tasks.bbtask" -Value $TaskContent -Encoding UTF8
    Set-Content -Path "$SamplePath\Meeting Notes.bbdoc" -Value $DocContent -Encoding UTF8
    Set-Content -Path "$SamplePath\Project Workflow.bbtemplate" -Value $TemplateContent -Encoding UTF8
    
    Write-Host "SUCCESS: Sample files created at: $SamplePath" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create sample files: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Refresh shell associations
Write-Host "Step 6: Refreshing shell associations..." -ForegroundColor Yellow
try {
    $signature = @'
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern void SHChangeNotify(uint wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
'@
    Add-Type -MemberDefinition $signature -Name Shell32 -Namespace Win32
    [Win32.Shell32]::SHChangeNotify(0x08000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
    Write-Host "SUCCESS: Shell associations refreshed" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Could not refresh associations: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Installation complete
Write-Host ""
Write-Host "BlueBirdHub installation complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installation Location: $(Split-Path $BlueBirdHubPath)" -ForegroundColor White
Write-Host "Desktop Shortcut: Created" -ForegroundColor White
Write-Host "System PATH: Added" -ForegroundColor White
Write-Host "File Associations: Configured" -ForegroundColor White
Write-Host ""
Write-Host "You can now:" -ForegroundColor Green
Write-Host "- Double-click the desktop shortcut to launch BlueBirdHub" -ForegroundColor Gray
Write-Host "- Double-click .bb* files to open them in BlueBirdHub" -ForegroundColor Gray
Write-Host "- Type 'BlueBirdHub' in any command prompt to launch" -ForegroundColor Gray
Write-Host "- Find sample files on your desktop to test functionality" -ForegroundColor Gray
Write-Host ""
Write-Host "File types that open with BlueBirdHub:" -ForegroundColor White

foreach ($ext in $FileAssociations.Keys) {
    Write-Host "  $ext - $($FileAssociations[$ext])" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Ready to streamline your management workflows!" -ForegroundColor Green
Write-Host ""

pause