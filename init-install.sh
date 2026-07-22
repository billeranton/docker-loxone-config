#!/bin/sh
echo
echo
echo
echo
echo
echo "Installing CLEAN LoxoneConfig into ./config/wine directory"
echo
if [ "$SKIP_PROMPT" != "1" ]; then
  printf "Press enter to continue"
  read -r _dummy
  echo
fi

if [ ! -f "/config/LoxoneConfigSetup.exe" ]; then
  cd /config
  echo "Try to auto download loxone config installer.."
  # urgh, loxone doesn't provide a direct link to latest installer, lets parse out the download link while we cry a little
  wget -O i.zip $(wget -O - https://www.loxone.com/enen/support/downloads/ | sed -r 's~(href="|src=")([^"]+).*~\n\1\2~g' | awk -F"=\"" '{print $2}' | grep LoxoneConfigSetup_ |head -1)
  unzip i.zip && rm i.zip

  if [ ! -f "/config/LoxoneConfigSetup.exe" ]; then
    echo "ERROR: ./config/LoxoneConfigSetup.exe missing! auto download failed too! please put installer file there.."
    exit 1
  fi
fi

export WINEDEBUG=-all
export QT_XCB_NO_XI2=1
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-software-rasterizer --disable-extensions"
export QT_WEBENGINE_DISABLE_CRASH_REPORTER=1

# Set env vars in Windows registry so Qt WebEngine under Wine picks them up
wine reg add "HKEY_CURRENT_USER\\Environment" /v QTWEBENGINE_CHROMIUM_FLAGS /d "$QTWEBENGINE_CHROMIUM_FLAGS" /f 2>/dev/null || true
wine reg add "HKEY_CURRENT_USER\\Environment" /v QT_WEBENGINE_DISABLE_CRASH_REPORTER /d 1 /f 2>/dev/null || true

# Disable all crash/error dialogs and dumps
wine reg add "HKCU\\Software\\Wine\\WineDbg" /v ShowCrashDialog /d N /f 2>/dev/null || true
wine reg add "HKCU\\Software\\Wine\\WineDbg" /v JitDebugger /d "" /f 2>/dev/null || true
wine reg add "HKLM\\Software\\Microsoft\\Windows\\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f 2>/dev/null || true
wine reg add "HKLM\\Software\\Microsoft\\Windows\\Windows Error Reporting" /v DontShowUI /t REG_DWORD /d 1 /f 2>/dev/null || true
wine reg add "HKLM\\Software\\Microsoft\\Windows\\Windows Error Reporting\\Dumps" /v DumpCount /t REG_DWORD /d 0 /f 2>/dev/null || true
wine reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" /v DisableErrorReporting /t REG_DWORD /d 1 /f 2>/dev/null || true
wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Auto /t REG_SZ /d 0 /f 2>/dev/null || true
wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v Debugger /t REG_SZ /d "" /f 2>/dev/null || true
# Dr. Watson - disable
wine reg add "HKLM\\Software\\Microsoft\\DrWatson" /v CreateCrashDump /t REG_DWORD /d 0 /f 2>/dev/null || true

if [ "$REINSTALL" = "1" ]; then
  echo "Removing old Loxone Config installation..."
  rm -rf "/config/wine/drive_c/Program Files (x86)/Loxone"
fi

echo Installing LoxoneConfig..
wine "/config/LoxoneConfigSetup.exe" /SILENT /SUPPRESSMSGBOXES



echo Installing Visual C++ 2022 runtime..
/usr/bin/winetricks -q vcrun2022
echo Install finished. yay!
exit 0
