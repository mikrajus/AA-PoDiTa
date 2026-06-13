@echo off
echo ===================================================
echo   Memulai Build APK AA-PoDiTa...
echo ===================================================
echo.

call flutter build apk --release

echo.
echo ===================================================
echo   Menyalin APK terbaru ke Website...
echo ===================================================
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "web_landing\AA-PoDiTa.apk"

echo.
echo ===================================================
echo   Selesai! APK di Web sudah diperbarui.
echo   Anda bisa mengupload folder web_landing ke Hosting.
echo ===================================================
pause
