set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%
rem copy ..\\..\\dart\\build\\ReleaseIA32\\oracledart_extension.dll
..\build\ReleaseIA32\dart oracledart_test.dart
