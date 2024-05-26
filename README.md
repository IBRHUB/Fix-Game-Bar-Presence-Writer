# GameBarPresenceWriterManager

---

This is for people that recently switched to Windows 11 and suffer from frequent fps drops. I would frequently get drops from 360fps down to 130-140 fps, which would throw off my grind. Now my fps sits at a steady 340, and around 300-320 

### Also you can Disable GameBarPresenceWriter

#### Using Regedit
- Navigate to: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter`
- Double click on "ActivationType" and set the value to 0.

#### Using CMD
- To disable:
```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 0 /f
```
- for revert 
```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 1 /f
```

### PowerShell Script

#### GameBarPresenceWriterManager

This PowerShell script allows you to manage the `GameBarPresenceWriter.exe` file by taking ownership, renaming the file to solve frame throttling issues, and reverting the changes if needed.

#### Usage

1. **Download the Script:**
 - Go to the [Releases](../../releases) page.
 - Download the latest version of `GameBarPresenceWriterManager.ps1`.

2. **Run the Script:**
 - Open PowerShell as Administrator.
 - Navigate to the directory where the script is downloaded.
 - Run the script:
   ```powershell
   .\GameBarPresenceWriterManager.ps1
   ```

