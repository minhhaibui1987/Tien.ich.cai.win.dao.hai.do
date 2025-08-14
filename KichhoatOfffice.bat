
@echo off 

title Tien ich cai Office dao v1.3
color 0F
::Get APIkey From https://khoatoantin.com/pidms
set "apikey=nVHBz3RIsHpXHofLv3B89iFK8"
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo  Run CMD as Administrator...
    goto goUAC 
) else (
 goto goADMIN )

:goUAC
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:goADMIN
    pushd "%CD%"
    CD /D "%~dp0"




for /f "tokens=2,*" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v ProductReleaseIds 2^>nul') do set OfficeVersion=%%J
if "%OfficeVersion%"=="" for /f "tokens=3*" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Office" /s /v "ProductName" 2^>nul ^| findstr /i "ProductName"') do set OfficeVersion=%%I %%J
For /f "tokens=3" %%b in ('cscript %windir%\system32\slmgr.vbs /dli ^| findstr /b /c:"License Status"') do set LicenseStatus=%%b
For /f "tokens=*" %%b in ('cscript %windir%\system32\slmgr.vbs /xpr') do set License=%%b
::+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


::------------------------------------------------------------------------------------------------------
:kichhoat
cls
mode con: cols=55 lines=26
echo                         *****
echo -------------- Tien ich cai Office dao ----------------
echo ------------     Minh Hai Computer     ----------------
echo -------------------------------------------------------
echo     Office: %OfficeVersion%
echo -------------------------------------------------------
echo. 
echo    [1] Kiem tra trang thai kich hoat Windows - Office
echo    [2] Go sach key Office cu
echo    [3] Go key Office tuy chon
echo    [4] Kich hoat ban quyen bang key online
echo    [5] Nhap key va kich hoat Office (lay IID - CID)
echo    [0] Thoat
echo -------------------------------------------------------
set /p choice=" Nhap lua chon cua ban: "
if "%choice%"=="1" Goto thong_tin
if "%choice%"=="2" Goto gokey
if "%choice%"=="3" Goto gokey_2
if "%choice%"=="4" Goto kich_key_copy
if "%choice%"=="5" Goto nhap_key
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

:home_to_pro
sc config LicenseManager start= auto & net start LicenseManager
sc config wuauserv start= auto & net start wuauserv
changepk.exe /productkey VK7JG-NPHTM-C97JM-9MPGT-3V66T
echo Can khoi dong lai may de nang cap Windows len Pro.
pause
shutdown /r /t 0


::==============================================================================================================


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



:thoat
del /f /q "%~f0"
exit
::-----------------------------------------------------------------------------------------------------------------------------------------------------------------

