/* $Id: SeqTable_multi_data.hpp 348915 2012-01-05 17:03:37Z vasilche $
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
 */

/// @file SeqTable_multi_data.hpp
/// User-defined methods of the data storage class.
///
/// This file was originally generated by application DATATOOL
/// using the following specifications:
/// 'seqtable.asn'.
///
/// New methods or data members can be added to it if needed.
/// See also: SeqTable_multi_data_.hpp


#ifndef OBJECTS_SEQTABLE_SEQTABLE_MULTI_DATA_HPP
#define OBJECTS_SEQTABLE_SEQTABLE_MULTI_DATA_HPP


// generated includes
#include <objects/seqtable/SeqTable_multi_data_.hpp>

#include <serial/objhook.hpp>

// generated classes

BEGIN_NCBI_SCOPE

BEGIN_objects_SCOPE // namespace ncbi::objects::

/////////////////////////////////////////////////////////////////////////////
class NCBI_SEQ_EXPORT CSeqTable_multi_data : public CSeqTable_multi_data_Base
{
    typedef CSeqTable_multi_data_Base Tparent;
public:
    // constructor
    CSeqTable_multi_data(void);
    // destructor
    ~CSeqTable_multi_data(void);

    size_t GetSize(void) const;

    // reserve memory for multi-row data vectors
    class NCBI_SEQ_EXPORT CReserveHook : public CPreReadChoiceVariantHook
    {
        virtual void PreReadChoiceVariant(CObjectIStream& in,
                                          const CObjectInfoCV& variant);
    };
    
private:
    // Prohibit copy constructor and assignment operator
    CSeqTable_multi_data(const CSeqTable_multi_data& value);
    CSeqTable_multi_data& operator=(const CSeqTable_multi_data& value);

};

/////////////////// CSeqTable_multi_data inline methods

// constructor
inline
CSeqTable_multi_data::CSeqTable_multi_data(void)
{
}


/////////////////// end of CSeqTable_multi_data inline methods


NCBISER_HAVE_GLOBAL_READ_VARIANT_HOOK(CSeqTable_multi_data, "*",
                                      new CSeqTable_multi_data::CReserveHook)

END_objects_SCOPE // namespace ncbi::objects::

END_NCBI_SCOPE


#endif // OBJECTS_SEQTABLE_SEQTABLE_MULTI_DATA_HPP
