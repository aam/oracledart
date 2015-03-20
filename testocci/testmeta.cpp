#include <iostream>
#include <occi.h>

using namespace oracle::occi;
using namespace std;


int main(int argc, char* argv[]) {
    if (argc < 5) {
        cout << argv[0] << "<userid> <password> <db> <query>" << "\n\n";
        cout << "For example,\n";
        cout << "  " << argv[0] << " scott tiger (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=w8-32-12core)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)(SERVER=DEDICATED))) \"select * form emp\"\n";
        return -1;
    }
    string user = argv[1];
    string passwd = argv[2];
    string db = argv[3];
    string query = argv[4];
    try {
        Environment *env = Environment::createEnvironment (Environment::DEFAULT);
        Connection *conn = env->createConnection (user, passwd, db);
        cout << "Connected. Test ok.\n";

        Statement *stmt = conn->createStatement(query);
        cout << "Created statement.\n";
        ResultSet *resultset = stmt->executeQuery();
        cout << "Got resultset.\n";
        {
        std::vector<MetaData> v_metadata = resultset->getColumnListMetaData();
        cout << "Get column list metadata vector.\n";
        cout << "Metadata vector size " << v_metadata.size() << "\n";
        for (int i=0; i < v_metadata.size(); i++) {
            cout << "  "
                 << std::string(v_metadata.at(i).getString(oracle::occi::MetaData::ATTR_NAME)).c_str()
                 << "\n";
        }
        }

        cout << "End of metadata vector.\n";
        stmt->closeResultSet(resultset);
        cout << "Closed resultset.\n";
        conn->terminateStatement(stmt);
        cout << "Terminated statement.\n";
        env->terminateConnection (conn);
        cout << "Terminated connection.\n";
        Environment::terminateEnvironment (env);
        cout << "Terminated environment.\n";
    } catch(oracle::occi::SQLException exception) {
        cout << "Following exception caught. Test failed.\n" << exception.getMessage();
    }

}