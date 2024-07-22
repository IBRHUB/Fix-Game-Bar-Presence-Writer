<#
.SYNOPSIS
Disables SvcHostSplit for services not related to Xbox, Xbl, or BITS.

.DESCRIPTION
This script iterates through all services in the HKLM\SYSTEM\CurrentControlSet\Services registry path
Excluding those related to Xbox, Xbl, or BITS, and sets the SvcHostSplitDisable value to 1 for each.

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: July 2024
#>

# Check if running as administrator; if not, restart as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Restarting script with elevated privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Set console colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Function to handle registry commands
function Invoke-RegistryCommand {
    param(
        [string]$Command,
        [string]$Path,
        [string]$Name,
        [string]$Type,
        [string]$Data,
        [string]$AdditionalArgs = ""
    )

    $fullCommand = "{0} {1}\{2} /v ""{3}"" /t {4} /d ""{5}"" /f {6}" -f $Command, $Path, $Name, $Type, $Data, $AdditionalArgs

    try {
        Write-Host "Running command:" -ForegroundColor Cyan
        Write-Host $fullCommand
        Invoke-Expression $fullCommand | Out-Null
        Write-Host "Command completed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error executing command: $_" -ForegroundColor Red
    }
}

# Function to take ownership and rename file
function TakeOwnershipAndRename {
    Write-Host "Taking ownership of the file and renaming..." -ForegroundColor Cyan
    $filePath = "C:\Windows\System32\GameBarPresenceWriter.exe"
    $newFileName = "C:\Windows\System32\GameBarPresenceWriter.exe.old"

    # Take ownership
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f $filePath" -Wait -NoNewWindow

    # Grant full control
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $filePath /grant %USERDOMAIN%\%USERNAME%:F" -Wait -NoNewWindow

    # Rename file
    Rename-Item -Path $filePath -NewName $newFileName -ErrorAction Stop

    Write-Output "Ownership taken and file renamed to $newFileName"
}

# Function to revert changes
function RevertChanges {
    Write-Host "Reverting changes..." -ForegroundColor Cyan
    $newFileName = "C:\Windows\System32\GameBarPresenceWriter.exe.old"
    $originalFileName = "C:\Windows\System32\GameBarPresenceWriter.exe"

    # Rename file back to original
    Rename-Item -Path $newFileName -NewName $originalFileName -ErrorAction Stop

    # Restore ownership to TrustedInstaller
    $acl = Get-Acl $originalFileName
    $owner = New-Object System.Security.Principal.NTAccount("NT SERVICE\TrustedInstaller")
    $acl.SetOwner($owner)
    Set-Acl $originalFileName $acl

    # Grant full control to TrustedInstaller
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $originalFileName /setowner `"NT SERVICE\TrustedInstaller`"" -Wait -NoNewWindow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $originalFileName /grant `"NT SERVICE\TrustedInstaller`":(F)" -Wait -NoNewWindow

    Write-Output "File ownership and permissions reverted to TrustedInstaller and renamed back to original."
}

# Function to disable FSO and Game Bar support
function DisableFSOAndGameBarSupport {
    Write-Host "Disabling FSO and Game Bar Support..." -ForegroundColor Cyan

    $commands = @(
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_DSEBehavior"; Type = "REG_DWORD"; Data = "2"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_DXGIHonorFSEWindowsCompatible"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_EFSEFeatureFlags"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_FSEBehavior"; Type = "REG_DWORD"; Data = "2"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_FSEBehaviorMode"; Type = "REG_DWORD"; Data = "2"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_HonorUserFSEBehaviorMode"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; Name = "__COMPAT_LAYER"; Type = "REG_SZ"; Data = "~ DISABLEDXMAXIMIZEDWINDOWEDMODE"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "GamePanelStartupTipIndex"; Type = "REG_DWORD"; Data = "3"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "ShowStartupPanel"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "UseNexusForGameBarEnabled"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter"; Name = "ActivationType"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; Name = "AllowGameDVR"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"; Name = "value"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_Enabled"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"; Name = "AppCaptureEnabled"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" }
    )

    foreach ($cmd in $commands) {
        Invoke-RegistryCommand @cmd
    }

    Write-Output "FSO and Game Bar Support disabled."
}

# Function to enable FSO and Game Bar support
function EnableFSOAndGameBarSupport {
    Write-Host "Enabling FSO and Game Bar Support..." -ForegroundColor Cyan

    $commands = @(
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_DSEBehavior"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_DXGIHonorFSEWindowsCompatible"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_EFSEFeatureFlags"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_FSEBehavior"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_FSEBehaviorMode"; Type = "REG_DWORD"; Data = "2"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_HonorUserFSEBehaviorMode"; Type = "REG_DWORD"; Data = "0"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; Name = "__COMPAT_LAYER"; Type = "REG_SZ"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "GamePanelStartupTipIndex"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "ShowStartupPanel"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameBar"; Name = "UseNexusForGameBarEnabled"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter"; Name = "ActivationType"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; Name = "AllowGameDVR"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"; Name = "value"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_Enabled"; Type = "REG_DWORD"; Data = "1"; AdditionalArgs = "/f" },
        @{ Command = "Reg.exe"; Path = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"; Name = "AppCaptureEnabled"; Type = "REG_DWORD"; Data = ""; AdditionalArgs = "/v /f" }
    )

    foreach ($cmd in $commands) {
        Invoke-RegistryCommand @cmd
    }

    Write-Output "FSO and Game Bar Support enabled."
}

# Main script logic
Write-Host "Do you want to modify the GameBarPresenceWriter file to solve the frame throttling problem?" -ForegroundColor Yellow
Write-Host "Enter 'y' to modify the main file, 'n' to do nothing, or 'r' to revert the changes." -ForegroundColor Yellow
$choice = Read-Host "Enter your choice (y/n/r)"

switch ($choice.ToLower()) {
    "y" {
        TakeOwnershipAndRename
    }
    "n" {
        Write-Host "No modifications made."
    }
    "r" {
        RevertChanges
    }
    default {
        Write-Host "Invalid choice. No action taken."
    }
}

Write-Host "Do you want to disable (d) or enable (e) FSO and Game Bar support, or revert (r) to previous settings?" -ForegroundColor Yellow
$choice = Read-Host "Enter your choice (d/e/r)"

switch ($choice.ToLower()) {
    "d" {
        DisableFSOAndGameBarSupport
    }
    "e" {
        EnableFSOAndGameBarSupport
    }
    "r" {
        Write-Host "No changes made."
    }
    default {
        Write-Host "Invalid choice. No action taken."
    }
}

# Pause the script to view the output
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
