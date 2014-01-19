ORACLE_OCI_HOME=~/Downloads/instantclient-sdk-macos.x32-11.2.0.3.0/sdk
ORACLE_OCCI_LIB_HOME=~/Downloads/instantclient_11_2-2
ln $ORACLE_OCCI_LIB_HOME/libocci.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libocci.dylib
ln $ORACLE_OCCI_LIB_HOME/libclntsh.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libclntsh.dylib
xcodebuild -project oracledart.xcodeproj -configuration ReleaseIA32 SYMROOT=`pwd`/../dart/xcodebuild
