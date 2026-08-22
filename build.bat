@echo off
set ANDROID_HOME=C:\Users\zhang\AppData\Local\Android\Sdk
set ANDROID_SDK_ROOT=C:\Users\zhang\AppData\Local\Android\Sdk
cd /d D:\dsh\闹钟\app\android
call gradlew.bat assembleDebug
echo.
echo =====================================
echo BUILD COMPLETE
echo =====================================
pause
