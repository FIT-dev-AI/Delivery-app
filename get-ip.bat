@echo off
echo ========================================
echo    DELIVERY APP - GET LOCAL IP
echo ========================================
echo.
echo 🔍 Đang tìm IP address của máy...
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set ip=%%a
    set ip=!ip: =!
    if not "!ip!"=="127.0.0.1" (
        echo ✅ IP Address tìm thấy: !ip!
        echo.
        echo 📋 HƯỚNG DẪN:
        echo    1. Copy IP này: !ip!
        echo    2. Mở file: frontend/lib/core/constants/api_constants.dart
        echo    3. Thay đổi dòng: static const String _localIP = '!ip!';
        echo    4. Save file và restart Flutter app
        echo.
        echo 🚀 Sau đó chạy backend: npm start
        echo.
        goto :end
    )
)

echo ❌ Không tìm thấy IP address hợp lệ
echo 💡 Hãy chạy 'ipconfig' thủ công và tìm IPv4 Address

:end
pause
