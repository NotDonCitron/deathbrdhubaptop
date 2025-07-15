# BlueBirdHub Installation Script
# Run this script as Administrator

Write-Host "Installing BlueBirdHub to Program Files..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Copy BlueBirdHub to Program Files
try {
    Copy-Item -Path "C:\Users\pasca\BlueBirdHub-Build" -Destination "C:\Program Files\BlueBirdHub" -Recurse -Force
    Write-Host "✅ BlueBirdHub installed to C:\Program Files\BlueBirdHub\" -ForegroundColor Green
    
    # Update desktop shortcut to point to Program Files
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\BlueBirdHub.lnk")
    $Shortcut.TargetPath = "C:\Program Files\BlueBirdHub\BlueBirdHub.exe"
    $Shortcut.WorkingDirectory = "C:\Program Files\BlueBirdHub"
    $Shortcut.Description = "BlueBirdHub - Comprehensive Management Tool"
    $Shortcut.Save()
    Write-Host "✅ Desktop shortcut updated" -ForegroundColor Green
    
    # Add to PATH (optional)
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*BlueBirdHub*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;C:\Program Files\BlueBirdHub", "Machine")
        Write-Host "✅ Added BlueBirdHub to system PATH" -ForegroundColor Green
    }
    
    Write-Host "`n🎉 BlueBirdHub installation complete!" -ForegroundColor Cyan
    Write-Host "You can now launch BlueBirdHub from:" -ForegroundColor White
    Write-Host "  • Desktop shortcut" -ForegroundColor Gray
    Write-Host "  • Start Menu (search 'BlueBirdHub')" -ForegroundColor Gray
    Write-Host "  • Command line: 'BlueBirdHub'" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

pause