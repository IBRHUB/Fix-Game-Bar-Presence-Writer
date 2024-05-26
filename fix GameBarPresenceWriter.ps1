    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
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

Write-Host " Do you want to change the GameBarPresenceWriter file to .exe.old to solve the frame throttling problem?"
Write-Host
Write-Host " Select 'y' to modify the main file, 'n' to do nothing, or 'r' to revert the changes."
Write-Host
$choice = Read-Host " Enter your choice (y/n/r)"

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

# Pause the script to view the output
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
