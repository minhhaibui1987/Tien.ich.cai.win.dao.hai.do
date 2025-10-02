@echo off
setlocal EnableExtensions DisableDelayedExpansion
:: Fix Printer - Bach Tinh Phong Tool - All-in-one

:: ---------- Self-elevate to Admin (UAC) ----------
net session >nul 2>&1 || (powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"; exit /b)

:: ---------- Console ----------
mode con: cols=80 lines=26
title Fix Printer - Bach Tinh Phong Tool - All-in-one

:: Verbose: set QUIET to empty to see output
set "QUIET="

:: >>> Jump to MENU immediately <<<
goto MENU

:: ---------- Helpers ----------
:PAUSE_BACK
echo.
echo Bam phim bat ky de quay lai...
pause >nul
exit /b

:RESTART_SPOOLER
echo   - Stop Spooler...
sc stop spooler >nul 2>&1
taskkill /f /im spoolsv.exe >nul 2>&1
echo   - Start Spooler...
sc start spooler >nul 2>&1
exit /b

:COPY_MSCMS_IF_MISSING
set "SRC=%SystemRoot%\System32\mscms.dll"
set "DST64=%SystemRoot%\System32\spool\drivers\x64\3"
set "DST32=%SystemRoot%\System32\spool\drivers\w32x86\3"
if exist "%SRC%" (
  if exist "%DST64%" if not exist "%DST64%\mscms.dll" copy /y "%SRC%" "%DST64%\mscms.dll" >nul
  if exist "%DST32%" if not exist "%DST32%\mscms.dll" copy /y "%SRC%" "%DST32%\mscms.dll" >nul
)
exit /b

:ASK_YN
setlocal EnableDelayedExpansion
choice /C YN /N /M "%~1 [Y/N]: "
set "rc=!errorlevel!"
endlocal & set "YN=%rc%"
exit /b

:: ---------- MAIN MENU ----------
:MENU
cls
echo ===== Bach Tinh Phong Tool - All-in-one  =====
echo [1] Fix may in
echo [2] Mo Quan ly thiet bi
echo [3] Mo Quan ly may in
echo [4] Mo tab Trinh dieu khien Drivers
echo [5] Go driver Canon LBP (nang cao)
echo [0] Thoat
echo ============================
choice /C 123450 /N /M "Chon [1-5,0]: "
set "sel=%errorlevel%"
if "%sel%"=="1" goto FIX_MENU
if "%sel%"=="2" (start "" devmgmt.msc & goto MENU)
if "%sel%"=="3" (start "" printmanagement.msc & goto MENU)
if "%sel%"=="4" (start "" rundll32 printui.dll,PrintUIEntry ^/s ^/t2 & goto MENU)
if "%sel%"=="5" goto CLEAN_LBP
if "%sel%"=="6" goto END
goto MENU

:END
exit /b

:: ---------- SUBMENU: FIX PRINT ----------
:FIX_MENU
cls
echo --- FIX MAY IN ---
echo [1] Fix Communication Error (Canon LBP 2900/3300)
echo [2] Fix loi 0x0000007c  ^(chon Windows ver^)
echo [3] Fix loi 0x0000011b
echo [4] Fix loi 0x00000709  ^(Default printer - 7 buoc^)
echo [5] Fix loi 0x00000040 ^(chia se / ket noi may in mang^)
echo [6] Fix loi 0x00000bc4 ^(RPC printing - 3 cach^)
echo [7] Fix loi 0x000006d9 ^(Bat Windows Firewall - MpsSvc^)
echo [8] Printer Cannot Connect ^(Check Name/Connection - goi tong 7 buoc^)
echo [9] Xoa hang doi in ^(spool^)
echo [A] Khoi dong lai Print Spooler
echo [B] Reset USB Monitor ^(UsbPortList/Port^)
echo [0] Quay lai MENU chinh
echo -----------------------
choice /C 123456789AB0 /N /M "Chon: "
set "pick=%errorlevel%"
if "%pick%"=="1"  goto FIX_COMM
if "%pick%"=="2"  goto FIX_7C_VER
if "%pick%"=="3"  goto FIX_11B
if "%pick%"=="4"  goto FIX_709
if "%pick%"=="5"  goto FIX_40
if "%pick%"=="6"  goto FIX_BC4
if "%pick%"=="7"  goto FIX_6D9
if "%pick%"=="8"  goto FIX_CONNECT
if "%pick%"=="9"  goto CLEAR_SPOOL
if "%pick%"=="10" goto RST_SPOOLER   :: 'A'
if "%pick%"=="11" goto RESET_USB_MON :: 'B'
if "%pick%"=="12" goto MENU          :: '0'
goto FIX_MENU

:FIX_COMM
cls
echo [1/5] Dung Print Spooler...
net stop spooler
taskkill /f /im spoolsv.exe
echo [2/5] Xoa USB Monitor (UsbPortList/Port)...
for %%A in ("HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\UsbPortList" "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\Port") do reg delete "%%~A" /f
echo [3/5] Don thu muc spool queue...
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*"
echo [4/5] Xoa cong CNB/USB du neu co...
for /f "usebackq tokens=*" %%K in (`reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors" 2^>nul ^| findstr /I /C:"CNB" /C:"USB"`) do reg delete "%%K" /f
echo [5/5] Khoi dong lai Print Spooler...
call :RESTART_SPOOLER
echo [DONE] Rut USB may in ra ^& cam lai, roi thu in.
call :PAUSE_BACK
goto FIX_MENU

:FIX_7C_VER
cls
echo Fix 0x0000007c - Chon Windows ver:
echo [1] Windows 10 1809
echo [2] Windows 10 1909
echo [3] Windows 10/11 2004+
echo [0] Quay lai
choice /C 1230 /N /M "Chon: "
set "v=%errorlevel%"
if "%v%"=="4" goto FIX_MENU
set "BASE=HKLM\SYSTEM\CurrentControlSet\Control\Print"
reg add "%BASE%" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo [OK] Dat RpcAuthnLevelPrivacyEnabled=0 theo ver da chon.
call :RESTART_SPOOLER
call :PAUSE_BACK
goto FIX_MENU

:FIX_11B
cls
echo [1/3] Dat RpcAuthnLevelPrivacyEnabled=0...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo [2/3] Bat RPC NamedPipes & TCP...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f
echo [3/3] Restart Spooler...
call :RESTART_SPOOLER
echo [DONE] Hoan tat fix 0x0000011b.
call :PAUSE_BACK
goto FIX_MENU

:FIX_709
cls
echo [1/7] Stop Spooler...
net stop spooler
echo [2/7] Bat Internet Printing Client + LPR Port Monitor...
dism /Online /Enable-Feature /FeatureName:Printing-Foundation-InternetPrinting-Client /NoRestart
dism /Online /Enable-Feature /FeatureName:Printing-LPRPortMonitor /NoRestart
echo [3/7] Dat RpcAuthnLevelPrivacyEnabled=0...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo [4/7] Cap quyen FullControl (Everyone) cho HKCU...\Windows...
powershell -NoProfile -Command ^
 "$p='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows';$acl=Get-Acl $p;" ^
 "$rule=New-Object System.Security.AccessControl.RegistryAccessRule('Everyone','FullControl','ContainerInherit,ObjectInherit','None','Allow');" ^
 "$acl.SetAccessRule($rule);Set-Acl -Path $p -AclObject $acl"
echo [5/7] LegacyDefaultPrinterMode=1...
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v LegacyDefaultPrinterMode /t REG_DWORD /d 1 /f
echo [6/7] Xoa gia tri 'Device' neu co...
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Device /f
echo [7/7] Huong dan: xoa may in cu ^(chua default^), tat/bat may in de Windows nhan lai, dat default.
call :RESTART_SPOOLER
call :PAUSE_BACK
goto FIX_MENU

:FIX_40
cls
echo Bat rule Windows Firewall: File and Printer Sharing + Network Discovery...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
echo [OK] Da thuc thi.
call :PAUSE_BACK
goto FIX_MENU

:FIX_BC4
cls
echo Fix 0x00000bc4 (RPC printing) - chon cach:
echo [1] Registry (khuyen dung): RpcOverTcp=1 ^& RpcOverNamedPipes=1
echo [2] Enforce RPC over named pipes: RpcOverTcp=0 ^& RpcOverNamedPipes=1
echo [3] Mo GPEDIT den node cau hinh
echo [0] Quay lai
choice /C 1230 /N /M "Chon: "
set "bc=%errorlevel%"
if "%bc%"=="4" goto FIX_MENU
if "%bc%"=="1" (
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f
) else if "%bc%"=="2" (
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f
) else (
  start "" gpedit.msc
  echo Da mo: Computer Configuration ^> Administrative Templates ^> Printers ^> Configure RPC connection settings.
  call :PAUSE_BACK
  goto FIX_MENU
)
echo [OK] Da thiet lap xong.
call :PAUSE_BACK
goto FIX_MENU

:FIX_6D9
cls
echo Bat dich vu Windows Firewall (MpsSvc) va khoi dong...
sc config MpsSvc start= auto
sc start  MpsSvc
echo [OK] xong.
call :PAUSE_BACK
goto FIX_MENU

:FIX_CONNECT
cls
echo --- Printer Cannot Connect (Check Name/Connection) - 7 buoc ---
echo [1/7] Bat Firewall rules...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
echo [2/7] Dat RPC printing on dinh...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f
echo [3/7] Copy mscms.dll neu thieu...
call :COPY_MSCMS_IF_MISSING
echo [4/7] Bat cac dich vu lien quan (Spooler, FDResPub, SSDPSRV, upnphost)...
for %%S in (Spooler fdPHost FDResPub SSDPSRV upnphost) do (sc config %%S start= auto >nul 2>&1 & sc start %%S >nul 2>&1)
echo [5/7] Nhe tay policy PointAndPrint (chi khi can)...
call :ASK_YN "Dat 'RestrictDriverInstallationToAdministrators'=0 ?"
if "%YN%"=="1" (
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /f >nul
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f >nul
  echo    - Da dat ve 0.
) else (
  echo    - Bo qua thay doi nay.
)
echo [6/7] Khoi dong lai Print Spooler...
call :RESTART_SPOOLER
echo [7/7] Tuy chon: ket noi UNC ^(\^\\IP\Share^)...
set "SHARE=" & set "USR=" & set "PWD="
set /p SHARE="Nhap \\IP\Share (bo qua neu khong dung): "
if defined SHARE (
  set /p USR="User (VD: Guest): "
  set /p PWD="Password (co the de trong): "
  if defined PWD (net use %SHARE% /user:%USR% %PWD%) else (net use %SHARE% /user:%USR% "")
)
echo [DONE] Hoan tat goi tong 'Printer Cannot Connect'.
call :PAUSE_BACK
goto FIX_MENU

:CLEAR_SPOOL
cls
echo Dung Spooler va xoa hang doi...
net stop spooler
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*"
call :RESTART_SPOOLER
echo [OK] Da xoa hang doi ^& restart Spooler.
call :PAUSE_BACK
goto FIX_MENU

:RST_SPOOLER
cls
call :RESTART_SPOOLER
echo [OK] Spooler da khoi dong lai.
call :PAUSE_BACK
goto FIX_MENU

:RESET_USB_MON
cls
echo Xoa UsbPortList/Port neu co...
for %%A in ("HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\UsbPortList" "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\Port") do reg delete "%%~A" /f
echo [OK] Hay rut/cam lai USB may in.
call :PAUSE_BACK
goto FIX_MENU

:CLEAN_LBP
cls
echo [NANG CAO] Liet ke goi driver Canon LBP tren DriverStore:
pnputil /enum-drivers | findstr /I "Canon LBP 2900"
echo.
echo Neu muon go: pnputil /delete-driver oemXX.inf /uninstall /force
call :PAUSE_BACK
goto MENU
