
@echo off
title Kich hoat ban quyen Office
color 0F
set "apikey=nVHBz3RIsHpXHofLv3B89iFK8"

:: Kiểm tra quyền admin
>nul 2>&1 net session
if %errorlevel% NEQ 0 (
    echo Dang yeu cau quyen Quan tri vien...
    powershell -Command "Start-Process -Verb runas -FilePath '%~f0'"
    exit /b
)

:: Đã có quyền admin, tiếp tục
goto goADMIN

:goADMIN
pushd "%CD%"
cd /d "%~dp0"




::------------------------------------------------------------------------------------------------------
:kichhoat
cls
mode con: cols=55 lines=15
echo                         *****
echo ----------------- Kich hoat Ofice ---------------------
echo ------------     Minh Hai Computer     ----------------
echo -------------------------------------------------------
echo. 
echo    [1] Go sach key Office cu
echo    [2] Go key Office tuy chon
echo    [3] Kich hoat ban quyen bang key online
echo    [4] Nhap key va kich hoat Office (lay IID - CID)
echo    [0] Thoat
echo -------------------------------------------------------
set /p choice=" Nhap lua chon cua ban: "
if "%choice%"=="1" Goto gokey
if "%choice%"=="2" Goto gokey_2
if "%choice%"=="3" Goto kich_key_copy
if "%choice%"=="4" Goto nhap_key
if %ERRORLEVEL%==0 goto thoat


:kich_key_copy
cls
echo.
echo  Kich hoat ban quyen Windows - Office bang key Online
echo -------------------------------------------------------
echo.

for /f "tokens=*" %%b in ('powershell -Command "$k=Read-Host 'Nhap Product Key' -AsSecureString; $bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($k); [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)"') do set k1=%%b
cls
Echo ... Kiem tra Product Key ...
for /f tokens^=2* %%i in ('sc query^|find "Clipboard"')do >nul cd.|clip & net stop "%%i %%j" >nul 2>&1 && net start "%%i %%j" >nul 2>&1

For /F %%b in ('Powershell -Command $Env:k1.Length') do Set KeyLen=%%b
if "%KeyLen%" NEQ "29" goto InvalidKey
for /f "tokens=*" %%b in ('powershell -Command "$req = [System.Net.WebRequest]::Create('https://pidkey.com/ajax/pidms_api?keys=%k1%&justgetdescription=0&apikey=%apikey%');$resp = New-Object System.IO.StreamReader $req.GetResponse().GetResponseStream(); $resp.ReadToEnd()"') do set CheckKey=%%b
SET CheckKey1=%CheckKey:"=_%
for /f "tokens=12 delims=," %%b in ("%CheckKey1%") do set Keyerr=%%b
if "%Keyerr%" EQU "_errorcode_:_0xC004C060_" goto InvalidKey
if "%Keyerr%" EQU "_errorcode_:_0xC004C003_" goto InvalidKey
for /f "tokens=11 delims=," %%b in ("%CheckKey1%") do set Keyerr=%%b
if "%Keyerr%" EQU "_blocked_:1" goto InvalidKey
for /f "tokens=6 delims=," %%b in ("%CheckKey1%") do set CheckKey2=%%b
for /f "tokens=2 delims=:" %%b in ("%CheckKey2%") do set prd=%%b
for /f "tokens=2 delims=_" %%b in ("%prd%") do set Kind=%%b
set CheckOffVer=%prd:~7,2%
set "OffVer=Licenses16"
if "%CheckOffVer%" == "14" set "OffVer=Licenses"
if "%CheckOffVer%" == "15" set "OffVer=Licenses15"
set prd1=%prd:~1,3%
set prd2=%prd:~1,6%
set prd3=%prd:~1,4%
Echo ... Type: %prd% ...
if "%prd3%" == "null" goto UndefinedKey
if "%WmicActivation%"=="1" goto Wmic_Activation
if "%prd1%" == "Win" goto ActivateWindows
if "%prd2%" == "Office" goto ActivateOffice
Goto kichhoat


:ActivateWindows
cd /d "%windir%\system32"
cscript slmgr.vbs /ipk %k1%
cls
Echo ... Activating Windows %prd% ...
for /f "tokens=3" %%b in ('cscript slmgr.vbs /dti ^| findstr /b /c:"Installation"') do set IID=%%b
for /f "tokens=9 delims=," %%b in ('powershell -Command "$req = [System.Net.WebRequest]::Create('https://pidkey.com/ajax/cidms_api?iids=%IID%&justforcheck=0&apikey=%apikey%');$resp = New-Object System.IO.StreamReader $req.GetResponse().GetResponseStream(); $resp.ReadToEnd()"') do set ACID=%%b
set CID=%ACID:~27,48%
cscript slmgr.vbs /atp %CID%
cscript slmgr.vbs /ato
Echo %prd%>k2.txt & echo IID:%IID% >>k2.txt & echo CID:%CID% >>k2.txt & echo %DATE%_%TIME% >> k2.txt  & ver>>k2.txt & cscript slmgr.vbs /dli >>k2.txt & cscript slmgr.vbs /xpr >>k2.txt & start k2.txt 
start ms-settings:activation          
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:ActivateOffice
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
cls
Echo ... Activating %prd% ...
for /f "tokens=3" %%b in ('cscript ospp.vbs /inpkey:%k1% ^| findstr /b /c:"ERROR CODE"') do set err=%%b
if "%err%" == "0xC004F069" for /f %%x in ('dir /b ..\root\%OffVer%\%Kind%*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\%OffVer%\%%x"
if "%err%" == "0xC004F069" cscript ospp.vbs /inpkey:%k1%
for /f "tokens=8" %%b in ('cscript ospp.vbs /dinstid ^| findstr /c:"%kind%"') do set IID=%%b
for /f "tokens=9 delims=," %%b in ('powershell -Command "$req = [System.Net.WebRequest]::Create('https://pidkey.com/ajax/cidms_api?iids=%IID%&justforcheck=0&apikey=%apikey%');$resp = New-Object System.IO.StreamReader $req.GetResponse().GetResponseStream(); $resp.ReadToEnd()"') do set ACID=%%b
set CID=%ACID:~27,48%
cscript ospp.vbs /actcid:%CID%
cscript ospp.vbs /act
Echo %prd%>k1.txt & echo IID:%IID%>>k1.txt & echo CID:%CID%>>k1.txt & echo %DATE%_%TIME% >> k1.txt & cscript ospp.vbs /dstatus >>k1.txt & start k1.txt
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:InvalidKey
echo Key khong hop le
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:UndefinedKey
echo Key khong xac dinh
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:thong_tin
mode con: cols=65 lines=35
cls
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
cls
cscript %windir%\system32\slmgr.vbs /dli & cscript %windir%\system32\slmgr.vbs /xpr & cscript ospp.vbs /dstatus
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:gokey
cls
echo Dang xoa key Office...
for %%a in (4,5,6) do (
    if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (
        cd /d "%ProgramFiles%\Microsoft Office\Office1%%a"
    )
    if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (
        cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a"
    )
    for /f "tokens=8" %%b in ('cscript //nologo OSPP.VBS /dstatus ^| findstr /b /c:"Last 5"') do (
        cscript //nologo ospp.vbs /unpkey:%%b
    )
)
echo "Nhan phim bat ki de quay tro lai"
pause
goto kichhoat
echo.

:gokey_2
mode con: cols=70 lines=50
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
cls
cscript ospp.vbs /dstatus 
Goto go_key


:go_key
set "uninstallkey="
echo.
set /p "uninstallkey=Nhap 5 ki tu cuoi key can xoa:"
if "%uninstallkey%" EQU "" Goto 6_ActivateMicrosoftLicense
cscript ospp.vbs /unpkey:%uninstallkey%
pause
goto kichhoat

::=======================================================================

:nhap_key
for %%a in (4,5,6) do (
    if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
    if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
echo.
set "install="
for /f "delims=" %%A in ('powershell -Command "$k=Read-Host 'Nhap key' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($k))"') do set "install=%%A"
if "%install%"=="" Goto 6_ActivateMicrosoftLicense
for /f tokens^=2* %%i in ('sc query^|find "Clipboard"')do >nul cd.|clip & net stop "%%i %%j" >nul 2>&1 && net start "%%i %%j" >nul 2>&1
cscript ospp.vbs /inpkey:%install%
cscript ospp.vbs /dinstid

SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
goto get_iid

:get_iid
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
cls
cscript ospp.vbs /dinstid
cscript ospp.vbs /dinstid>"%~dp0iid.txt"
start %~dp0iid.txt
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
goto get_cid

:get_cid
set "iid="
echo.
set /p "iid=Nhap IID:"
if "%iid%" EQU "" Goto 6_ActivateMicrosoftLicense
for /f "tokens=9 delims=," %%b in ('powershell -Command "$req = [System.Net.WebRequest]::Create('https://pidkey.com/ajax/cidms_api?iids=%iid%&justforcheck=0&apikey=%apikey%');$resp = New-Object System.IO.StreamReader $req.GetResponse().GetResponseStream(); $resp.ReadToEnd()"') do set ACID=%%b
set CID=%ACID:~27,48%
Echo Confirmation ID: %CID%
Echo %CID%|clip
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
goto nhap_cid

:nhap_cid
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
echo. set /p "CID=Nhap CID:"
cscript ospp.vbs /actcid:%CID%
cscript ospp.vbs /act 
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
echo Da kich hoat thanh cong ban quyen! Hay sao luu lai!
pause
goto kichhoat


:sao_luu
cd /d "%~dp0"
cls
echo --- Da tao thu muc Sao luu ban quyen ---
if not exist "%~dp0Backup" md "%~dp0Backup"
xcopy "%windir%\System32\spp\store" "%~dp0Backup" /e /h /q
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:khoi_phuc
cd /d "%~dp0"
cls
set OutDir=Backup
if not exist "%OutDir%" goto restore0
echo --- STOPPING SOME SERVICES FOR RESTORE ACTIVATION ---
net stop sppsvc>nul 2>nul 
net stop osppsvc>nul 2>nul
for /f "tokens=6 delims=[.] " %%a in ('ver') do set ver1=%%a
echo --- RESTORING WINDOWS AND OFFICE LICENSE FILES ---	
if %ver1% LEQ 7601 (
	XCOPY %OutDir%\SoftwareProtectionPlatform\* %Windir%\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform /s /i /y
	goto restore1
)
if %ver1% LEQ 4 (
	XCOPY %OutDir%\* %Windir%\System32\spp\store /s /i /y
	XCOPY %OutDir%\OfficeSoftwareProtectionPlatform\* %ProgramData%\Microsoft\OfficeSoftwareProtectionPlatform  /s /i /y 
	goto restore1
) 
XCOPY %OutDir%\* %Windir%\System32\spp\store /s /i /y
goto restore1

:restore0
Echo Khong tim thay thu muc sao luu ban quyen!
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat

:restore1
echo --- Restoring Microsoft License ---
echo Do not close this windows. Please Wait ...
sc config sppsvc start= auto >nul 2>nul& net start sppsvc >nul 2>nul
sc config osppsvc  start= auto >nul 2>nul& net start osppsvc >nul 2>nul
sc config wuauserv start= auto >nul 2>nul& net start wuauserv >nul 2>nul
sc config LicenseManager start= auto >nul 2>nul& net start LicenseManager >nul 2>nul
cscript %windir%\system32\slmgr.vbs -rilc >nul 2>nul
cscript %windir%\system32\slmgr.vbs -dli >nul 2>nul
cscript %windir%\system32\slmgr.vbs -ato 
for %%a in (4,5,6) do (
if exist "%ProgramFiles%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles%\Microsoft Office\Office1%%a")
if exist "%ProgramFiles(x86)%\Microsoft Office\Office1%%a\ospp.vbs" (cd /d "%ProgramFiles(x86)%\Microsoft Office\Office1%%a")
)
echo --- Get Microsoft License Status ---
cscript %windir%\system32\slmgr.vbs /dli & cscript %windir%\system32\slmgr.vbs /xpr & cscript ospp.vbs /dstatus
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a")
pause
goto kichhoat



:thoat
del /f /q "%~f0"

exit
::-----------------------------------------------------------------------------------------------------------------------------------------------------------------
