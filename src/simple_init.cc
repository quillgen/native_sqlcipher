#include "native_sqlcipher.h"
#include "sqlite3.h"

// Forward declarations for both initialization functions
extern "C" int sqlcipher_extra_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);
extern "C" int sqlite3_simple_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);

// Combined initialization function
FFI_PLUGIN_EXPORT extern "C" int combined_sqlite_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi)
{
    int rc;

    // First call the simple tokenizer initialization
    rc = sqlite3_simple_init(db, pzErrMsg, pApi);
    if (rc != SQLITE_OK)
    {
        return rc;
    }

    // Then call the SQLCipher initialization
    rc = sqlcipher_extra_init(db, pzErrMsg, pApi);

    return rc;
}