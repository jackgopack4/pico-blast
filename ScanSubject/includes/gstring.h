/* =============================================================================
    File: gstring.h. Version 4.0.1.3. Sep 15, 2007.

 *************************************************************************************************************************
 * WARNING: when passing gstrings to a vararg function, you must explicitly cast them to a (const char*) or call c_str() *
 ************************************************************************************************************************
 =============================================================================
*/

#ifndef _GSTRING_H_
#define _GSTRING_H_

#ifdef WX_WINDOWS
  #include <wx/string.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <pico_types.h>
#include <always.h>

// add Trim* functions

/************************
 * cGString             *
 ************************/

// this is stored before m_s
struct GSTRING_INFO
   {size_t refs, allocSize;};  // ref-count = # users, allocSize = space we've allocated minus the size of this struct.

class cGString
   {public:
       cGString();
       cGString(const cGString& gsR); //copy constructor
       // if count is zero, strP must be terminated with ascii 00
       cGString(const char* strP, int count = -1);         // constructor
       cGString(char ch, int repCount = 1);  // or tchar  This will create a cGString with a specified number of characters.
       ~cGString();

        // note: forces termination (and thus maybe a copy) of this string
        // ms documentation doesn't define behavior when s is null... i'll return -1
       int              Find         (const char* strP, int offset = 0) const;
       int              Compare      (const char* strP) const;
       int              CompareNoCase(const char* strP) const;
       char            *Disown       (void);

       cGString         Left         (int count) const;
       cGString         Right        (int count) const;
       cGString         Mid          (int pos, int count = -1) const;
       static cGString  Format       (const char* format, ...);
       int              Replace      (const char* olds, const char* news, bool ignoreCase=false);
       cGString&        TrimLeft     (const char* targets);
       cGString&        TrimRight    (const char* targets);
       void             MakeLower    ();
       void             MakeUpper    ();

       int              Remove       (char c);
       int              GetLength    () const;
       operator const char*          () const;
       const char      *c_str        () const;
       void             Release      (); // decrements the ref count and if it's zero, frees and zeros m_subP
       #ifdef PICO_WIDGETS
       wxString         wxStr        () const {return wxString((const char *) *this, wxConvLibc);}
       #endif

       // given a separator char, we can split a string into fields
       int              GetFieldCount(char sep); // number of fields in this string
       cGString         GetField     (char sep, int index); // return the index-th field. zero-based.

       const cGString& operator=     (const cGString& gsR);
       const cGString& operator=     (const char* strP);
       const cGString& operator+=    (const cGString& strR);
       const cGString& operator+=    (const char *strP);
       // Wide char assignment into a GString
       //const cGString& operator=(const unsigned short* wstrP);
       friend bool     operator==    (const cGString&, const cGString&);
       friend bool     operator==    (const cGString&, const char*);
       friend bool     operator==    (const char*, const cGString&);
       friend bool     operator!=    (const cGString&, const cGString&);
       friend bool     operator!=    (const cGString&, const char*);
       friend bool     operator!=    (const char*, const cGString&);
       friend cGString operator+     (const cGString&, const cGString&);
//     friend std::ostream & operator<<(std::ostream & os, const cGString& gstrR);

    protected:
        // seems kinda weird to have all members mutable, but there should still be plenty of things to optimize about const functions
       mutable char*  m_superP; // the start of the "superstring" that this substring is a part of
       mutable char*  m_subP;   // the start of this substring
       mutable size_t m_size;   // the size of this substring, not counting terminator

       GSTRING_INFO* Info() const {return (((GSTRING_INFO*) m_superP) - 1);};
       void         Reserve     (int size) const; // ensures we can hold <size> chars, plus one more for the null
       void         PrePreWrite () const;
       void         PreWrite    () const; // make sure we have our own copy of the data
       void         CopyPart    (const cGString& src, int offset = 0, int count = 0);
   }; //cGString...

bool operator!=(const cGString& gsl,  const cGString& gsr);
bool operator!=(const cGString& gsl,  const char* gsrP);
bool operator!=(const char* gslP,     const cGString& gsr);

#if 0 // vector<gstring>...
#ifndef PICO_WIDGETS //{
class cGSTRING_ARRAY:  public cCLASS_CONTAINER <cGString>
   {public:
    int CompareIndex(cGString *lP, cGString *rP) {return lP->CompareNoCase((const char*)rP);}

    int Add(cGString *gsP)  {return cCLASS_CONTAINER <cGString>::Add( gsP);}
    int Add(cGString &gsR)  {return cCLASS_CONTAINER <cGString>::Add(&gsR);}
    int Add(const char *sP) {cGString gs(sP); return cCLASS_CONTAINER <cGString>::Add(&gs);} // if we did this all in one line, gcc would complain: "taking addr of temporary"
   };
#endif //}
#endif

#endif // _GSTRING_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
