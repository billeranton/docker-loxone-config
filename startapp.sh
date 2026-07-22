#!/bin/sh

if [ ! -d "/config/wine/drive_c/Program Files (x86)/Loxone" ] || [ "$REINSTALL" = "1" ]; then
  SKIP_PROMPT=1 REINSTALL=$REINSTALL /init-install.sh
fi

export WINEDEBUG=-all
export QT_XCB_NO_XI2=1
export QT_WEBENGINE_DISABLE_CRASH_REPORTER=1
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-software-rasterizer --disable-extensions"
setxkbmap $XLANG

# Suppress crash dialogs and dumps on every start
WINEPREFIX=$WINEPREFIX wine reg add "HKCU\\Software\\Wine\\WineDbg" /v ShowCrashDialog /d N /f 2>/dev/null
WINEPREFIX=$WINEPREFIX wine reg add "HKLM\\Software\\Microsoft\\Windows\\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f 2>/dev/null
WINEPREFIX=$WINEPREFIX wine reg add "HKLM\\Software\\Microsoft\\Windows\\Windows Error Reporting" /v DontShowUI /t REG_DWORD /d 1 /f 2>/dev/null
WINEPREFIX=$WINEPREFIX wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Auto /t REG_SZ /d 0 /f 2>/dev/null
WINEPREFIX=$WINEPREFIX wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Debugger /t REG_SZ /d "" /f 2>/dev/null

exec wine "/config/wine/drive_c/Program Files (x86)/Loxone/LoxoneConfig/LoxoneConfig.exe"
