ln $ORACLE_OCCI_LIB_HOME/libocci.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libocci.dylib
ln $ORACLE_OCCI_LIB_HOME/libclntsh.dylib.11.1 $ORACLE_OCCI_LIB_HOME/libclntsh.dylib
ORACLE_OCI_HOME=~/Downloads/instantclient_11_2/sdk ORACLE_OCCI_LIB_HOME=~/Downloads/instantclient_11_2-2 xcodebuild -project oracledart.xcodeproj -configuration ReleaseIA32 SYMROOT=`pwd`/../dart/xcodebuild
cp ../dart/xcodebuild/ReleaseIA32/liboracledart_extension.dylib  .

