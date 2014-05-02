/*===========================================================================
*
*                            PUBLIC DOMAIN NOTICE
*               National Center for Biotechnology Information
*
*  This software/database is a "United States Government Work" under the
*  terms of the United States Copyright Act.  It was written as part of
*  the author's official duties as a United States Government employee and
*  thus cannot be copyrighted.  This software/database is freely available
*  to the public for use. The National Library of Medicine and the U.S.
*  Government have not placed any restriction on its use or reproduction.
*
*  Although all reasonable efforts have been taken to ensure the accuracy
*  and reliability of the software and data, the NLM and the U.S.
*  Government do not and cannot warrant the performance or results that
*  may be obtained by using this software or data. The NLM and the U.S.
*  Government disclaim all warranties, express or implied, including
*  warranties of performance, merchantability or fitness for any particular
*  purpose.
*
*  Please cite the author in any work or product based on this material.
*
* ===========================================================================
*
*/

#include <vdb/manager.h>
#include <vdb/schema.h>
#include <vdb/table.h>
#include <vdb/cursor.h>

#include <kdb/manager.h>
#include <kdb/column.h>

#include <kapp/main.h>
#include <kapp/args.h>

#include <klib/text.h>
#include <klib/log.h>
#include <klib/status.h>
#include <klib/rc.h>
#include <klib/out.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

typedef struct vcol2kcol vcol2kcol;
struct vcol2kcol
{
    int64_t row_id;
    const KColumn *kcol;
    String name, path;
    uint32_t vcol;
    uint32_t elem_bits;
};

#define WRITING 1
#if WRITING
#else
#define VCursorOpen(X) (0)
#define VCursorOpenRow(X) (0)
#define VCursorCommitRow(X) (0)
#define VCursorCloseRow(X) (0)
#define VCursorCommit(X) (0)
#if 0
#define VCursorAddColumn(A, B, C, D, E) (0)
#define VCursorDatatype(A, B, C, D) (0)
#endif
#define VCursorWrite(A, B, C, D, E, F) (0)
#endif

static
rc_t kdb_to_vdb_row ( VCursor *curs, int argc, vcol2kcol *v )
{
    int i;
    rc_t rc;
    for ( rc = 0, i = 0; rc == 0 && i < argc; ++ i )
    {
        const KColumnBlob *kblob;
        rc = KColumnOpenBlobRead ( v [ i ] . kcol, & kblob, v [ i ] . row_id );
        if ( rc != 0 )
        {
            if ( GetRCState ( rc ) == rcNotFound )
                return RC ( rcExe, rcColumn, rcReading, rcData, rcDone );

            PLOGERR ( klogInt, (klogInt, rc, "failed to open blob for row $(row_id) in column '$(path)'"
                      , "row_id=%lu,path=%s"
                      , v [ i ] . row_id
                      , v [ i ] . path . addr
                ));
        }
        else
        {
            uint32_t count;
            char buff [ 1024 ];
            size_t num_read, remaining, offset = 0;

            do
            {
                rc = KColumnBlobRead ( kblob, offset, buff, sizeof buff, & num_read, & remaining );
                if ( rc != 0 )
                {
                    PLOGERR ( klogInt, (klogInt, rc, "failed to read blob for row $(row_id) in column '$(path)'"
                              , "row_id=%lu,path=%s"
                              , v [ i ] . row_id
                              , v [ i ] . path . addr
                        ));
                    break;
                }

                count = num_read * 8 / v [ i ] . elem_bits;
                if ( count == 0 )
                {
                    if ( remaining != 0 )
                        LOGMSG ( klogWarn, "discarding data at end of row" );
                    break;
                }

                remaining += num_read;
                num_read = count * v [ i ] . elem_bits >> 3;
                offset += num_read;
                remaining -= num_read;

                if ( remaining != 0 && ( v [ i ] . elem_bits & 7 ) != 0 )
                    LOGMSG ( klogWarn, "large blob of non-byte-aligned data may be corrupted by tool" );

                rc = VCursorWrite ( curs, v [ i ] . vcol, v [ i ] . elem_bits, buff, 0, count );
                if ( rc != 0 )
                {
                    int64_t rid = 0;
                    VCursorRowId ( curs, & rid );

                    PLOGERR ( klogInt, (klogInt, rc, "failed to write data to row $(row_id) from column '$(path)'"
                              , "row_id=%lu,path=%s"
                              , rid
                              , v [ i ] . path . addr
                        ));
                    break;
                }
            }
            while ( remaining != 0 );

            if ( rc == 0 )
            {
                int64_t start;
                uint32_t count;

                rc = KColumnBlobIdRange ( kblob, &start, &count );
                if ( rc != 0 )
                    LOGERR ( klogInt, rc, "failed to obtain blob id range" );
                v [ i ] . row_id = start + count;
            }

            KColumnBlobRelease ( kblob );
        }
    }

    return rc;
}

static
rc_t kdb_to_vdb_load ( VCursor *curs, int argc, vcol2kcol *v )
{
    rc_t rc = VCursorOpen ( curs );
    if ( rc != 0 )
        LOGERR ( klogErr, rc, "failed to open cursor" );
    else
    {
        while ( rc == 0 )
        {
            rc = VCursorOpenRow ( curs );
            if ( rc != 0 )
                LOGERR ( klogErr, rc, "failed to open cursor row" );
            else
            {
                rc_t rc2;

                rc = kdb_to_vdb_row ( curs, argc, v );
                if ( rc == 0 )
                {
                    rc = VCursorCommitRow ( curs );
                    if ( rc != 0 )
                        LOGERR ( klogErr, rc, "failed to commit row" );
                }

                rc2 = VCursorCloseRow ( curs );
                if ( rc2 != 0 )
                {
                    LOGERR ( klogErr, rc2, "failed to close cursor row" );
                    if ( rc == 0 )
                        rc = rc2;
                }
            }
        }

        if ( GetRCState ( rc ) == rcDone )
            rc = 0;

        if ( rc == 0 )
            rc = VCursorCommit ( curs );
    }

    return rc;
}

static
rc_t kdb_to_vdb_create ( VDBManager *vmgr, const VSchema *schema,
    const char *table_type, const char *table_path, bool force,
    int argc, vcol2kcol *v )
{
    KCreateMode cmode = force ? kcmInit : kcmCreate;

    VTable *vtbl;
    rc_t rc = VDBManagerCreateTable ( vmgr, & vtbl, schema, table_type, cmode, table_path );
    if ( rc != 0 )
    {
        PLOGERR ( klogErr, (klogErr, rc, "failed to $(cmode) table '$(path)'"
                  , "cmode=%s,path=%s"
                  , force ? "create or replace" : "create"
                  , table_path
            ));
    }
    else
    {
        VCursor *curs;
        rc = VTableCreateCursorWrite ( vtbl, & curs, kcmInsert );
        if ( rc != 0 )
            LOGERR ( klogInt, rc, "failed to create cursor" );
        else
        {
            int i;
            for ( i = 0; i < argc; ++ i )
            {
                VTypedesc desc;

                rc = VCursorAddColumn ( curs, & v [ i ] . vcol, "%.*s",
                    ( int ) v [ i ] . name . size, v [ i ] . name . addr );
                if ( rc != 0 )
                {
                    PLOGERR ( klogErr, (klogErr, rc, "failed to add column '$(col)' to cursor"
                              , "col=%.*s"
                              , ( int ) v [ i ] . name . size, v [ i ] . name . addr
                        ));
                    break;
                }

                rc = VCursorDatatype(curs, v[i].vcol, 0, &desc);
                if ( rc != 0 )
                {
                    PLOGERR ( klogInt, (klogInt, rc, "failed to access datatype for column '$(name)'"
                              , "name=%.*s"
                              , ( int ) v [ i ] . name . size, v [ i ] . name . addr
                        ));
                    break;
                }

                v [ i ] . elem_bits = VTypedescSizeof ( & desc );
            }

            if ( rc == 0 )
                rc = kdb_to_vdb_load ( curs, argc, v );

            VCursorRelease ( curs );
        }

#if 1
        if ( rc == 0 )
            rc = VTableReindex ( vtbl );
#endif

        VTableRelease ( vtbl );
    }

    return rc;
}

static
rc_t vcol2kcol_make ( vcol2kcol **out, int argc, char *argv [] )
{
    int i;
    vcol2kcol *v = malloc ( argc * sizeof * v );
    if ( v == NULL )
        return RC ( rcExe, rcColumn, rcOpening, rcMemory, rcExhausted );

    for ( i = 0; i < argc; ++ i )
    {
        const char *pair = argv [ i ];
        const char *sep = strchr ( pair, '=' );
        if ( sep == NULL )
        {
            free ( v );
            fprintf ( stderr, "bad column spec - '%s'\n", pair );
            return RC ( rcExe, rcArgv, rcReading, rcParam, rcInvalid );
        }

        v [ i ] . row_id = 1;
        v [ i ] . kcol = NULL;
        StringInit ( & v [ i ] . name, pair, sep - pair, string_len ( pair, sep - pair ) );
        StringInitCString ( & v [ i ] . path, sep + 1 );
        v [ i ] . vcol = 0;
        v [ i ] . elem_bits = 8;
    }

    * out = v;
    return 0;
}

static
rc_t vcol2kcol_open ( vcol2kcol *v, int argc, const KDBManager *kmgr )
{
    int i;
    rc_t rc;

    for ( rc = 0, i = 0; i < argc; ++ i )
    {
        rc = KDBManagerOpenColumnRead ( kmgr, & v [ i ] . kcol, v [ i ] . path . addr );
        if ( rc != 0 )
        {
            PLOGERR ( klogErr, (klogErr, rc, "failed to open KColumn '(path)'", "path=%s", v [ i ] . path . addr ));
            break;
        }
        rc = KColumnIdRange ( v [ i ] . kcol, & v [ i ] . row_id, NULL );
        if ( rc != 0 )
        {
            PLOGERR ( klogErr, (klogErr, rc, "failed to determine id range for KColumn '(path)'", "path=%s", v [ i ] . path . addr ));
            break;
        }
    }

    return rc;
}

static
void vcol2kcol_whack ( vcol2kcol *v, int argc )
{
    int i;
    for ( i = 0; i < argc; ++ i )
        KColumnRelease ( v [ i ] . kcol );
    free ( v );
}

static
rc_t kdb_to_vdb ( const char *schema_path, const char *table_type,
    const char *table_path, bool force, int argc, char *argv [] )
{
    KDBManager *kmgr;
    rc_t rc = KDBManagerMakeUpdate ( & kmgr, NULL );
    if ( rc != 0 )
        LOGERR ( klogInt, rc, "failed to make KDB manager" );
    else
    {
        VDBManager *vmgr;
        rc = VDBManagerMakeUpdate ( & vmgr, NULL );
        if ( rc != 0 )
            LOGERR ( klogInt, rc, "failed to make VDB manager" );
        else
        {
            VSchema *schema;
            rc = VDBManagerMakeSchema ( vmgr, & schema );
            if ( rc != 0 )
                LOGERR ( klogInt, rc, "failed to make empty schema" );
            else
            {
                rc = VSchemaParseFile ( schema, schema_path );
                if ( rc != 0 )
                    PLOGERR ( klogErr, (klogErr, rc, "failed to parse schema file '$(file)'", "file=%s", schema_path ));
                else
                {
                    vcol2kcol *v;
                    rc = vcol2kcol_make ( & v, argc, argv );
                    if ( rc == 0 )
                    {
                        rc = vcol2kcol_open ( v, argc, kmgr );
                        if ( rc == 0 )
                            rc = kdb_to_vdb_create ( vmgr, schema, table_type, table_path, force, argc, v );

                        vcol2kcol_whack ( v, argc );
                    }
                }

                VSchemaRelease ( schema );
            }

            VDBManagerRelease ( vmgr );
        }

        KDBManagerRelease ( kmgr );
    }

    return rc;
}


/* Version  EXTERN
 *  return 4-part version code: 0xMMmmrrrr, where
 *      MM = major release
 *      mm = minor release
 *    rrrr = bug-fix release
 */
ver_t CC KAppVersion ( void )
{
    return 0;
}
    
/* KMain - EXTERN
 *  executable entrypoint "main" is implemented by
 *  an OS-specific wrapper that takes care of establishing
 *  signal handlers, logging, etc.
 *
 *  in turn, OS-specific "main" will invoke "KMain" as
 *  platform independent main entrypoint.
 *
 *  "argc" [ IN ] - the number of textual parameters in "argv"
 *  should never be < 0, but has been left as a signed int
 *  for reasons of tradition.
 *
 *  "argv" [ IN ] - array of NUL terminated strings expected
 *  to be in the shell-native character set: ASCII or UTF-8
 *  element 0 is expected to be executable identity or path.
 */

const char UsageDefaultName[] = "kdb2vdb";

rc_t CC UsageSummary (const char * progname)
{
    return KOutMsg (
        "\n"
        "Usage:\n"
        "  %s [ options ] -s schema -t table-type \\\n"
        "    -o path-to-vtable vcolumn=path-to-kcolumn...\n",
        "\n"
        "Summary:\n"
        "create a named VTable and load from KColumn\n"
        "Usage: \n",
        progname);
}
rc_t CC Usage (const Args * args)
{
    const char * progname = UsageDefaultName;
    const char * fullpath = UsageDefaultName;
    rc_t rc;

    if (args == NULL)
        rc = RC (rcApp, rcArgv, rcAccessing, rcSelf, rcNull);
    else
        rc = ArgsProgram (args, &fullpath, &progname);

    UsageSummary (progname);

    KOutMsg ("    parses schema text supplied from '-s' option and locates table-type by\n"
             "    name given with '-t' option.\n"
             "\n",
             "    creates VTable using path from 'o' option. this operation will fail if\n"
             "    the table exists unless the '-f' option is specified.\n"
             "\n",
             "    each vcol=kcol pair will cause the KColumn to be opened and loaded into\n"
             "    the corresponding named VColumn.\n"
             "\n");

    KOutMsg ("Options:\n");

    KOutMsg ("need to write up force, scheme-path, table-type and output\n");

    HelpOptionsStandard();

    HelpVersion (fullpath, KAppVersion());

    return rc;
    return rc;
}

#define OPTION_FORCE    "force"
#define OPTION_SCHEMA   "schema-path"
#define OPTION_TTYPE    "table-type"
#define OPTION_TPATH    "output"

static const char* force_usage [] = { "force overwrite", NULL };
static const char* schema_usage[] = { "path to schema", NULL };
static const char* ttype_usage [] = { "type of table", NULL };
static const char* tpath_usage [] = { "path to output", NULL };

OptDef Options[] =
{
  { OPTION_FORCE,  "f", NULL, force_usage,  0, false, false },
  { OPTION_SCHEMA, "s", NULL, schema_usage, 1, true,  false },
  { OPTION_TTYPE,  "t", NULL, ttype_usage,  1, true,  false },
  { OPTION_TPATH,  "o", NULL, tpath_usage,  1, true,  false },
};

rc_t CC KMain ( int argc, char *argv [] )
{
    Args * args;
    rc_t rc;

    rc = ArgsMakeAndHandle (&args, argc, argv, 1, Options, sizeof Options / sizeof (OptDef));
    if (rc == 0)
    {
        do
        {
            uint32_t pcount;

            bool force = false;
            const char *schema_path = NULL;
            const char *table_type = NULL;
            const char *table_path = NULL;


            rc = ArgsOptionCount (args, OPTION_FORCE, &pcount);
            if (rc)
                break;
            if (pcount)
                force = true;

            rc = ArgsOptionCount (args, OPTION_SCHEMA, &pcount);
            if (rc)
                break;
            if (pcount)
            {
                rc = ArgsOptionValue (args, OPTION_SCHEMA, 0, &schema_path);
                if (rc)
                    break;
            }
            else
            {
                fprintf ( stderr, "missing schema path\n" );
                rc = RC ( rcExe, rcArgv, rcReading, rcParam, rcNotFound );
                break;
            }

            rc = ArgsOptionCount (args, OPTION_TTYPE, &pcount);
            if (rc)
                break;
            if (pcount)
            {
                rc = ArgsOptionValue (args, OPTION_TTYPE, 0, &table_type);
                if (rc)
                    break;
            }
            else
            {
                fprintf ( stderr, "missing table type\n" );
                rc = RC ( rcExe, rcArgv, rcReading, rcParam, rcNotFound );
                break;
            }

            rc = ArgsOptionCount (args, OPTION_TPATH, &pcount);
            if (rc)
            {
                rc = ArgsOptionValue (args, OPTION_TPATH, 0, &table_path);
                if (rc)
                    break;
            }
            else
            {
                fprintf ( stderr, "missing table path\n" );
                rc = RC ( rcExe, rcArgv, rcReading, rcParam, rcNotFound );
                break;
            }

            rc = ArgsParamCount (args, &pcount);
            if (rc)
                break;
            if (pcount == 0)
            {
                fprintf ( stderr, "missing column spec\n" );
                rc = RC ( rcExe, rcArgv, rcReading, rcParam, rcNotFound );
                break;
            }
            else 
            {
                uint32_t ix;

                for (ix = 0; ix < pcount; ++ix)
                {
                    const char * pc;

                    rc = ArgsParamValue (args, ix, &pc);
                    if (rc)
                        break;

                    argv[ix] = (char *)pc;

                }
                if (rc)
                    break;
            }

            kdb_to_vdb ( schema_path, table_type, table_path, force, (int)pcount, argv );

        } while (0);

        ArgsWhack (args);
    }
    return 0;
}
