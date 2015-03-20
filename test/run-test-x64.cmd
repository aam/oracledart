set path=%userprofile%\Downloads\instantclient-basic-windows.x64-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\Downloads\instantclient-basic-windows.x64-12.1.0.1.0\instantclient_12_1;%path%

copy packages\oracledart\src\oracledart_native_extension.dll packages\oracledart\src\oracledart_native_extension_ia32.dll

copy packages\oracledart\src\oracledart_native_extension_x64.dll packages\oracledart\src\oracledart_native_extension.dll

..\build\ReleaseX64\dart oracledart_test.dart
set buildexitcode=%ERRORLEVEL%

del packages\oracledart\src\oracledart_native_extension.dll

copy packages\oracledart\src\oracledart_native_extension_ia32.dll packages\oracledart\src\oracledart_native_extension.dll

del packages\oracledart\src\oracledart_native_extension_ia32.dll

exit /b %buildexitcode%