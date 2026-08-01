@echo off
echo 🚀 Cleaning old builds...
fvm flutter clean

echo 📊 Analyzing size for ARM64...
fvm flutter build apk --release --target-platform android-arm64 --tree-shake-icons --analyze-size

rem echo 📦 Building split APKs...
rem fvm flutter build apk --release --split-per-abi --tree-shake-icons

echo 📦 Building optimized AAB for Play Store...
fvm flutter build appbundle --release --tree-shake-icons

echo ✅ Build complete!
echo 🔍 APKs are in: build\app\outputs\flutter-apk\
echo 📦 AAB is in: build\app\outputs\bundle\release\
pause
