# Disable GameBarPresenceWriter
This is for people that recently switched to windows 11 and suffer from frequent fps drops . I would frequently get drops from 130fps down to 30-40 fps, which would throw off my grind. Now my fps sits at a steady 125, and around 90-100 when grinding in remastered

# Also you can Disable GameBarPresenceWriter 
-regedit 
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter
Double click on "ActivationType" and set the value to 0.

for cmd you can run this
-add
```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 0 /f
```
for revert 
```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 1 /f
```

and alow i make powershell script for all this to
## Usage

1. **Open PowerShell as Administrator**.
2. **Run the script**:

```powershell
.\GameBarPresenceWriterManager.ps1
