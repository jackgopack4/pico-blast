/* $Id: HG_Gene.cpp 121608 2008-03-10 14:19:27Z ivanov $
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
 *   'homologene.asn'.
 */

// standard includes
#include <ncbi_pch.hpp>
#include <corelib/ncbistre.hpp>

// generated includes
#include <objects/homologene/HG_Gene.hpp>

// generated classes

BEGIN_NCBI_SCOPE

BEGIN_objects_SCOPE // namespace ncbi::objects::

// destructor
CHG_Gene::~CHG_Gene(void)
{
}

inline
CHG_Gene::TSymbol CHG_Gene::x_GetGeneidLabel(void) const 
{ 
        return( "GeneID:" + NStr::IntToString( GetGeneid() ) );  
}


CHG_Gene::TSymbol CHG_Gene::GetLabel(void) const
{
        CHG_Gene::TSymbol gene_symbol;
         
        if ( IsSetSymbol() ) {                                                                                                  // if gene name is set  
                gene_symbol = GetSymbol();      
        }
        else if ( IsSetLocus_tag() ) {
                gene_symbol = GetLocus_tag();           
        }
        else if ( IsSetAliases() ) {   // if gene name is NOT set, look for aliases
                const  TAliases &aliases = GetAliases();
                TAliases_iter aliases_iter = aliases.begin();
                gene_symbol = *aliases_iter;                            
        }
        else if ( IsSetGeneid() ) {                                                                                     // if gene name is NOT set and no aliases, set name to gene_id
                gene_symbol = x_GetGeneidLabel();
        }
        else {
                gene_symbol = "(Unknown)";
        }
        return gene_symbol;
}


END_objects_SCOPE // namespace ncbi::objects::

END_NCBI_SCOPE

/* Original file checksum: lines: 65, chars: 1891, CRC32: 815c60b3 */
