@echo off
title 今日热点 App 构建工具
color 0A

echo.
echo ================================================
echo         今日热点 App - APK 构建工具
echo ================================================
echo.

REM 设置环境变量
set ANDROID_HOME=C:\Users\zhang\AppData\Local\Android\Sdk
set ANDROID_SDK_ROOT=C:\Users\zhang\AppData\Local\Android\Sdk

REM 检查环境
echo [1/3] 检查环境...
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 Java
    pause
    exit /b 1
)
echo       Java 已就绪

REM 构建
echo.
echo [2/3] 正在构建 APK...
echo       这可能需要 5-15 分钟，请耐心等待...
echo.

cd /d "%~dp0app\android"
call gradlew.bat assembleDebug

if %errorlevel% neq 0 (
    echo.
    echo 错误: 构建失败
    pause
    exit /b 1
)

REM 复制 APK
echo.
echo [3/3] 构建完成!
echo.

REM 查找 APK
for /r "%~dp0app\android" %%f in (*.apk) do (
    echo 发现 APK: %%f
    copy "%%f" "%~dp0DailyHot.apk" >nul
    echo 已复制到: %~dp0DailyHot.apk
)

echo.
echo ================================================
echo              构建成功！
echo ================================================
echo.
echo APK 文件位置:
echo   %~dp0DailyHot.apk
echo.
echo 下一步:
echo   1. 将 DailyHot.apk 传到手机
echo   2. 在手机上安装
echo   3. 打开 App 即可使用
echo.
pause
