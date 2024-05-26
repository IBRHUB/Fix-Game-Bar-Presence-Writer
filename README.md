# GameBarPresenceWriterManager

[English](#english) | [العربية](#العربية)

---

## <a name="english"></a>Disable GameBarPresenceWriter

This is for people that recently switched to Windows 11 and suffer from frequent fps drops. I would frequently get drops from 130fps down to 30-40 fps, which would throw off my grind. Now my fps sits at a steady 125, and around 90-100 when grinding in remastered.

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

---
---
## <a name="العربية"></a>تعطيل GameBarPresenceWriter

هذا موجه للأشخاص الذين انتقلوا مؤخرًا إلى Windows 11 ويعانون من انخفاضات متكررة في معدل الإطارات. كنت أحصل بشكل متكرر على انخفاضات من 350 إطارًا في الثانية إلى 130-140 حتى 70 إطارًا في الثانية، مما كان يعطل تجربتي. الآن معدل الإطارات ثابت عند 350، وحوالي 330-310 عند اللعب في 

### يمكنك أيضًا تعطيل GameBarPresenceWriter

#### باستخدام Regedit
- انتقل إلى: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter`
- انقر نقرًا مزدوجًا على "ActivationType" وقم بتعيين القيمة إلى 0.

#### باستخدام CMD
- لتعطيل:
```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 0 /f
```
- للتراجع:

```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" /v ActivationType /t REG_DWORD /d 1 /f
```

### برنامج PowerShell النصي

#### GameBarPresenceWriterManager

يسمح لك هذا البرنامج النصي في PowerShell بإدارة ملف `GameBarPresenceWriter.exe` من خلال تولي ملكيته، وإعادة تسمية الملف لحل مشكلات انخفاض معدل الإطارات، والتراجع عن التغييرات إذا لزم الأمر.

#### طريقة الاستخدام

1. **تنزيل البرنامج النصي:**
 - انتقل إلى صفحة [الإصدارات](../../releases).
 - قم بتنزيل أحدث إصدار من `GameBarPresenceWriterManager.ps1`.

2. **تشغيل البرنامج النصي:**
 - افتح PowerShell كمسؤول.
 - انتقل إلى الدليل حيث تم تنزيل البرنامج النصي.
 - قم بتشغيل البرنامج النصي:
   ```powershell
   .\GameBarPresenceWriterManager.ps1
   ```

