# BlueBirdHub File Associations Setup
# Run this script as Administrator

Write-Host "Setting up BlueBirdHub file associations..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Define BlueBirdHub executable path
$BlueBirdHubPath = "C:\Program Files\BlueBirdHub\BlueBirdHub.exe"
if (-not (Test-Path $BlueBirdHubPath)) {
    $BlueBirdHubPath = "C:\Users\pasca\BlueBirdHub-Build\BlueBirdHub.exe"
}

# File associations for BlueBirdHub management workflows
$FileAssociations = @{
    ".bbdoc" = @{
        "Description" = "BlueBirdHub Document"
        "FriendlyName" = "BlueBirdHub Document"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbproject" = @{
        "Description" = "BlueBirdHub Project"
        "FriendlyName" = "BlueBirdHub Project File"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbtemplate" = @{
        "Description" = "BlueBirdHub Template"
        "FriendlyName" = "BlueBirdHub Template"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbworkflow" = @{
        "Description" = "BlueBirdHub Workflow"
        "FriendlyName" = "BlueBirdHub Workflow"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbteam" = @{
        "Description" = "BlueBirdHub Team"
        "FriendlyName" = "BlueBirdHub Team Configuration"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbtask" = @{
        "Description" = "BlueBirdHub Task"
        "FriendlyName" = "BlueBirdHub Task File"
        "Icon" = "$BlueBirdHubPath,0"
    }
    ".bbmember" = @{
        "Description" = "BlueBirdHub Member"
        "FriendlyName" = "BlueBirdHub Member Profile"
        "Icon" = "$BlueBirdHubPath,0"
    }
}

try {
    foreach ($Extension in $FileAssociations.Keys) {
        $FileInfo = $FileAssociations[$Extension]
        $ProgId = "BlueBirdHub$($Extension.Replace('.', ''))"
        
        Write-Host "Setting up $Extension files..." -ForegroundColor Yellow
        
        # Create file extension registry entry
        Set-ItemProperty -Path "HKCR:\$Extension" -Name "(Default)" -Value $ProgId -Force
        
        # Create ProgID registry entries
        New-Item -Path "HKCR:\$ProgId" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId" -Name "(Default)" -Value $FileInfo.Description -Force
        Set-ItemProperty -Path "HKCR:\$ProgId" -Name "FriendlyTypeName" -Value $FileInfo.FriendlyName -Force
        
        # Set default icon
        New-Item -Path "HKCR:\$ProgId\DefaultIcon" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId\DefaultIcon" -Name "(Default)" -Value $FileInfo.Icon -Force
        
        # Set open command
        New-Item -Path "HKCR:\$ProgId\shell\open\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCR:\$ProgId\shell\open\command" -Name "(Default)" -Value "`"$BlueBirdHubPath`" `"%1`"" -Force
        
        Write-Host "✅ $Extension files will now open with BlueBirdHub" -ForegroundColor Green
    }
    
    # Create sample files for testing
    Write-Host "`nCreating sample files..." -ForegroundColor Yellow
    $SamplePath = "$env:USERPROFILE\Desktop\BlueBirdHub Samples"
    New-Item -Path $SamplePath -ItemType Directory -Force | Out-Null
    
    @{
        "Project Plan.bbproject" = "BlueBirdHub Project File`nProject: Team Management System`nCreated: $(Get-Date)"
        "Team Setup.bbteam" = "BlueBirdHub Team Configuration`nTeam: Development Team`nMembers: 5"
        "Daily Tasks.bbtask" = "BlueBirdHub Task List`nPriority: High`nDue Date: $(Get-Date -Format 'yyyy-MM-dd')"
        "Meeting Notes.bbdoc" = "BlueBirdHub Document`nMeeting: Weekly Standup`nDate: $(Get-Date -Format 'yyyy-MM-dd')"
        "Workflow Template.bbtemplate" = "BlueBirdHub Template`nTemplate: Project Workflow`nVersion: 1.0"
    } | ForEach-Object {
        $_.GetEnumerator() | ForEach-Object {
            Set-Content -Path "$SamplePath\$($_.Key)" -Value $_.Value
        }
    }
    
    Write-Host "✅ Sample files created at: $SamplePath" -ForegroundColor Green
    
    # Refresh shell associations
    $signature = @'
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern void SHChangeNotify(uint wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
'@
    Add-Type -MemberDefinition $signature -Name Shell32 -Namespace Win32
    [Win32.Shell32]::SHChangeNotify(0x08000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
    
    Write-Host "`n🎉 File associations setup complete!" -ForegroundColor Cyan
    Write-Host "You can now double-click these file types to open them in BlueBirdHub:" -ForegroundColor White
    $FileAssociations.Keys | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
    Write-Host "`nSample files have been created on your desktop for testing." -ForegroundColor White
    
} catch {
    Write-Host "❌ File association setup failed: $($_.Exception.Message)" -ForegroundColor Red
}

pause