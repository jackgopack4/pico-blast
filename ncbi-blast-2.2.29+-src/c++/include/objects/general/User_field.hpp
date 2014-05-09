/* $Id: User_field.hpp 405847 2013-07-09 13:56:53Z gouriano $
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
 *   using specifications from the data definition file
 *   'general.asn'.
 */

#ifndef OBJECTS_GENERAL_USER_FIELD_HPP
#define OBJECTS_GENERAL_USER_FIELD_HPP


// generated includes
#include <objects/general/User_field_.hpp>

// generated classes

BEGIN_NCBI_SCOPE

BEGIN_objects_SCOPE // namespace ncbi::objects::

class NCBI_GENERAL_EXPORT CUser_field : public CUser_field_Base
{
    typedef CUser_field_Base Tparent;
public:
    // constructor
    CUser_field(void);
    // destructor
    ~CUser_field(void);

    /// add fields to the current user field
    CUser_field& AddField(const string& label, int           value);
    CUser_field& AddField(const string& label, double        value);
    CUser_field& AddField(const string& label, bool          value);

    CUser_field& AddField(const string& label, const CUser_field_Base::TData::TStr& value);
    CUser_field& AddField(const string& label, const CUser_field_Base::TData::TStrs& value);

    CUser_field& AddField(const string& label, const vector<int>&    value);
    CUser_field& AddField(const string& label, const vector<double>& value);

    CUser_field& AddField(const string& label, CUser_object& value);
    CUser_field& AddField(const string& label,
                          const vector< CRef<CUser_object> >& value);
    CUser_field& AddField(const string& label,
                          const vector< CRef<CUser_field> >& value);

    /// Access a named field in this user field.  This will tokenize the
    /// string 'str' on the delimiters; if the field doesn't exist, an
    /// exception will be thrown.
    const CUser_field&     GetField(const string& str,
                                    const string& delim = ".") const;

    /// Return a field reference representing the tokenized key, or a
    /// NULL reference if the key doesn't exist.
    CConstRef<CUser_field> GetFieldRef(const string& str,
                                       const string& delim = ".") const;

    /// For functions that don't use delims, we instead use a chain of names.
    struct NCBI_GENERAL_EXPORT SFieldNameChain {
        /// Convenience func.  This can be deprecated if a
        /// NStr::Join function is created that takes 
        /// the type of TFieldNameChainUnderlying
        void Join(ostream & out_name_strm, const string & delim = ".") const;

        void operator += (const CTempStringEx & str) {
            m_FieldNameChain.push_back(str);
        }

        bool operator < (const SFieldNameChain & rhs) const {
            return m_FieldNameChain < rhs.m_FieldNameChain;
        }

        typedef vector<CTempStringEx> TFieldNameChainUnderlying;
        TFieldNameChainUnderlying m_FieldNameChain;
    };

    /// Maps field names like the input for GetFieldRef to the user-field.
    typedef map<SFieldNameChain, CConstRef<CUser_field> > TMapFieldNameToRef;

    /// Flags that affect behavior of TMapFieldNameToRef functions.
    enum EFieldMapFlags {
        fFieldMapFlags_ExcludeThis = (1<<0) ///< = 0x1 (excludes this CUser_field's name and mapping to self from results)
    };
    typedef int TFieldMapFlags; ///< holds bitwise OR of "EFieldMapFlags"

    /// Recursively get the map of field names like the input 
    /// for GetFieldRef to the user-field.
    ///
    /// @param out_mapFieldNameToRef
    ///   The results are put into here, but it becomes INVALID if this
    ///   CUser_field or any of its descendents change their label.
    ///   It will NOT be cleared
    ///   before more data is added, and in that case would overwrite any
    ///   item which has the same key.
    /// @param fFieldMapFlags
    ///   Flags that affect behavior of function.
    /// @param parent_name
    ///   Outside users probably don't need this.  It's really for 
    ///   internal recursive calls when building the map.
    void GetFieldsMap(
        CUser_field::TMapFieldNameToRef & out_mapFieldNameToRef,
        TFieldMapFlags fFieldMapFlags = 0,
        const SFieldNameChain & parent_name = SFieldNameChain() ) const;

    /// Access a named field in this user field.  This will tokenize the
    /// string 'str' on the delimiters and recursively add fields where needed
    CUser_field&      SetField(const string& str,
                               const string& delim = ".");

    /// Return a field reference representing the tokenized key, or a
    /// NULL reference if the key cannot be created for some reason.
    CRef<CUser_field> SetFieldRef(const string& str,
                                  const string& delim = ".");

    /// Verify that a named field exists
    bool HasField(const string& str,
                  const string& delim = ".") const;
                  
    /// Delete the named field.
    /// return true if successful. false if field doesn't exist.
    bool DeleteField(const string& str,
                  const string& delim = ".");

private:
    // Prohibit copy constructor and assignment operator
    CUser_field(const CUser_field& value);
    CUser_field& operator=(const CUser_field& value);

};



/////////////////// CUser_field inline methods

// constructor
inline
CUser_field::CUser_field(void)
{
}


/////////////////// end of CUser_field inline methods


END_objects_SCOPE // namespace ncbi::objects::

END_NCBI_SCOPE

#endif // OBJECTS_GENERAL_USER_FIELD_HPP
/* Original file checksum: lines: 93, chars: 2437, CRC32: 222a2c32 */