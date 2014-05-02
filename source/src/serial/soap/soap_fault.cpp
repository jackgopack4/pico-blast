/* $Id: soap_fault.cpp 103479 2007-05-04 15:24:00Z gouriano $
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
 *   'soap_11.xsd'.
 */

// standard includes
#include <ncbi_pch.hpp>

// generated includes
#include <serial/soap/soap_fault.hpp>

BEGIN_NCBI_SCOPE

static struct tag_FaultcodeEnum {
    CSoapFault::ESoap_FaultcodeEnum code;
    const char* value;
} s_FaultCodeEnum[] = {

    {CSoapFault::eVersionMismatch, "VersionMismatch"},
    {CSoapFault::eMustUnderstand,  "MustUnderstand"},
    {CSoapFault::eClient,          "Client"},
    {CSoapFault::eServer,          "Server"},
    {CSoapFault::e_not_set, 0}
};

// generated classes

// destructor
CSoapFault::~CSoapFault(void)
{
}

CSoapFault::ESoap_FaultcodeEnum CSoapFault::GetFaultcodeEnum(void) const
{
    return x_CodeToFaultcodeEnum( GetFaultcode() );
}

void CSoapFault::SetFaultcodeEnum(CSoapFault::ESoap_FaultcodeEnum value)
{
    SetFaultcode( x_FaultcodeEnumToCode(value) );
}

CSoapFault::TFaultcode CSoapFault::x_FaultcodeEnumToCode(
    CSoapFault::ESoap_FaultcodeEnum code)
{
    for (int i=0; s_FaultCodeEnum[i].code != e_not_set; ++i) {
        if (s_FaultCodeEnum[i].code == code) {
            return s_FaultCodeEnum[i].value;
        }
    }
    return kEmptyStr;
}

CSoapFault::ESoap_FaultcodeEnum CSoapFault::x_CodeToFaultcodeEnum(
    const CSoapFault::TFaultcode& value)
{
    for (int i=0; s_FaultCodeEnum[i].code != e_not_set; ++i) {
        if (NStr::CompareNocase(value.c_str(),s_FaultCodeEnum[i].value) == 0) {
            return s_FaultCodeEnum[i].code;
        }
    }
    return e_not_set;
}


END_NCBI_SCOPE
