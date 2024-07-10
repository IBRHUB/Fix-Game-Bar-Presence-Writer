If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

function TakeOwnershipAndRename {
    Write-Host "Define the file path and new file name"
    $filePath = "C:\Windows\System32\GameBarPresenceWriter.exe"
    $newFileName = "C:\Windows\System32\GameBarPresenceWriter.exe.old"

    Write-Host "Take ownership of the file"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f $filePath" -Wait -NoNewWindow

    Write-Host "Grant full control to the current user"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $filePath /grant %USERDOMAIN%\%USERNAME%:F" -Wait -NoNewWindow

    Write-Host "Rename the file"
    Rename-Item -Path $filePath -NewName $newFileName

    Write-Output "Ownership taken and file renamed to $newFileName"
}

function RevertChanges {
    Write-Host "Define the file paths"
    $newFileName = "C:\Windows\System32\GameBarPresenceWriter.exe.old"
    $originalFileName = "C:\Windows\System32\GameBarPresenceWriter.exe"

    Write-Host "Rename the file back to its original name"
    Rename-Item -Path $newFileName -NewName $originalFileName

    Write-Host "Restore ownership to TrustedInstaller"
    $owner = "NT SERVICE\TrustedInstaller"
    $acl = Get-Acl $originalFileName
    $acl.SetOwner([System.Security.Principal.NTAccount] $owner)
    Set-Acl $originalFileName $acl

    Write-Host "Grant full control to TrustedInstaller"
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $originalFileName /setowner `"NT SERVICE\TrustedInstaller`"" -Wait -NoNewWindow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls $originalFileName /grant `"NT SERVICE\TrustedInstaller`":(F)" -Wait -NoNewWindow

    Write-Output "File ownership and permissions reverted to TrustedInstaller and renamed back to original."
}

function DisableFSOAndGameBarSupport {
    Write-Host "Disabling FSO and Game Bar Support..."

    $regCommands = @(
        "HKCU:\System\GameConfigStore\GameDVR_DSEBehavior=2",
        "HKCU:\System\GameConfigStore\GameDVR_DXGIHonorFSEWindowsCompatible=1",
        "HKCU:\System\GameConfigStore\GameDVR_EFSEFeatureFlags=0",
        "HKCU:\System\GameConfigStore\GameDVR_FSEBehavior=2",
        "HKCU:\System\GameConfigStore\GameDVR_FSEBehaviorMode=2",
        "HKCU:\System\GameConfigStore\GameDVR_HonorUserFSEBehaviorMode=1",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\__COMPAT_LAYER=~ DISABLEDXMAXIMIZEDWINDOWEDMODE",
        "HKCU:\System\GameBar\GamePanelStartupTipIndex=3",
        "HKCU:\System\GameBar\ShowStartupPanel=0",
        "HKCU:\System\GameBar\UseNexusForGameBarEnabled=0",
        "HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter\ActivationType=0",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR=0",
        "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR\value=0",
        "HKCU:\System\GameConfigStore\GameDVR_Enabled=0",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled=0"
    )

    foreach ($command in $regCommands) {
        $null = New-ItemProperty -Path $($command.Split('=')[0]) -Name $($command.Split('=')[1].Split('=')[0]) -Value $($command.Split('=')[1].Split('=')[1]) -PropertyType DWORD -Force
    }

    Write-Output "FSO and Game Bar Support disabled."
}

function EnableFSOAndGameBarSupport {
    Write-Host "Enabling FSO and Game Bar Support..."

    $regCommands = @(
        "HKCU:\System\GameConfigStore\GameDVR_DSEBehavior=0",
        "HKCU:\System\GameConfigStore\GameDVR_DXGIHonorFSEWindowsCompatible=0",
        "HKCU:\System\GameConfigStore\GameDVR_EFSEFeatureFlags=0",
        "HKCU:\System\GameConfigStore\GameDVR_FSEBehavior=0",
        "HKCU:\System\GameConfigStore\GameDVR_FSEBehaviorMode=2",
        "HKCU:\System\GameConfigStore\GameDVR_HonorUserFSEBehaviorMode=0",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\__COMPAT_LAYER",
        "HKCU:\System\GameBar\GamePanelStartupTipIndex",
        "HKCU:\System\GameBar\ShowStartupPanel",
        "HKCU:\System\GameBar\UseNexusForGameBarEnabled",
        "HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter\ActivationType=1",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR",
        "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR\value=1",
        "HKCU:\System\GameConfigStore\GameDVR_Enabled=1",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled"
    )

    foreach ($command in $regCommands) {
        if ($command -match "=") {
            $regPath = $command.Split('=')[0]
            $valueName = $command.Split('=')[1]
            $null = Remove-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
        } else {
            $null = Remove-Item -Path $command -ErrorAction SilentlyContinue
        }
    }

    Write-Output "FSO and Game Bar Support enabled."
}

Write-Host "Do you want to modify FSO and Game Bar support settings?"
Write-Host
Write-Host "Select 'd' to disable, 'e' to enable, or 'r' to revert changes."
Write-Host
$choice = Read-Host "Enter your choice (d/e/r)"

switch ($choice.ToLower()) {
    "d" {
        DisableFSOAndGameBarSupport
    }
    "e" {
        EnableFSOAndGameBarSupport
    }
    "r" {
        RevertChanges
    }
    default {
        Write-Host "Invalid choice. No action taken."
    }
}

# Pause the script to view the output
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
