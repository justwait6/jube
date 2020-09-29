@echo off
python encryptSrc.py
cd frameworks\runtime-src\proj.android
python build_native.py
python build_native.py -a arm64-v8a
call .\gradlew.bat assembleRelease --warning-mode=all

cd ../../../
python copyApkDirHere.py
pause