/* $Id: Name_std.cpp 417357 2013-11-06 16:00:50Z rafanovi $
 * ===========================================================================
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
 * Author:  .......
 *
 * File Description:
 *   .......
 *
 * Remark:
 *   This code was originally generated by application DATATOOL
 *   using the following specifications:
 *   'general.asn'.
 */

// standard includes
#include <ncbi_pch.hpp>

// generated includes
#include <objects/general/Name_std.hpp>

// generated classes

BEGIN_NCBI_SCOPE

BEGIN_objects_SCOPE // namespace ncbi::objects::

// destructor
CName_std::~CName_std(void)
{
}


const CName_std::TSuffixes& CName_std::GetStandardSuffixes(void)
{
    static const char* sfxs[] = { "2nd", "3rd", "4th", "5th", "6th", "II", "III", "IV", "Jr.", "Sr.", "V", "VI"};
    DEFINE_STATIC_ARRAY_MAP_WITH_COPY(TSuffixes, suffixes, sfxs);

    return suffixes;
}


END_objects_SCOPE // namespace ncbi::objects::

END_NCBI_SCOPE

/* Original file checksum: lines: 65, chars: 1888, CRC32: daed53d2 */
