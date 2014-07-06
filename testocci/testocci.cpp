#include <iostream>
#include <occi.h>

using namespace oracle::occi;
using namespace std;


int main(int argc, char* argv[]) {
    if (argc < 4) {
        cout << argv[0] << "<userid> <password> <db>" << "\n\n";
        cout << "For example,\n";
        cout << "  " << argv[0] << " scott tiger (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED)))\n";
        return -1;
    }
    string user = argv[1];
    string passwd = argv[2];
    string db = argv[3];
    try {
        Environment *env = Environment::createEnvironment (Environment::DEFAULT);
        Connection *conn = env->createConnection (user, passwd, db);
        cout << "Connected. Test ok.\n";
        env->terminateConnection (conn);
        Environment::terminateEnvironment (env);
    } catch(oracle::occi::SQLException exception) {
        cout << "Following exception caught. Test failed.\n" << exception.getMessage();
    }

}