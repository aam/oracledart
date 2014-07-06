set oracle_oci_home=%userprofile%\Downloads\instantclient-sdk-nt-12.1.0.1.0\instantclient_12_1\sdk
set include=%include%;%oracle_oci_home%\include
cl testocci.cpp /link oci.lib oraocci12.lib /libpath:%oracle_oci_home%\lib\msvc\vc11 /libpath:%oracle_oci_home%\lib\msvc

setlocal

set path=%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1\vc11;%userprofile%\downloads\instantclient-basic-nt-12.1.0.1.0\instantclient_12_1;%path%

testocci.exe scott1 tiger (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))

endlocal