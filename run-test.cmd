set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%
rem copy ..\\dart\\build\\ReleaseIA32\\oracledart_extension.dll
..\dart\build\ReleaseIA32\dart test_oracledart_sync_extension.dart
