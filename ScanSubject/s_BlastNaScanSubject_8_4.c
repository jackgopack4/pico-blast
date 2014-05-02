/** Scan the compressed subject sequence, returning 8-letter word hits
 * with stride 4. Assumes a standard nucleotide lookup table
 * @param lookup_wrap Pointer to the (wrapper to) lookup table [in]
 * @param subject The (compressed) sequence to be scanned for words [in]
 * @param offset_pairs Array of query and subject positions where words are 
 *                found [out]
 * @param max_hits The allocated size of the above array - how many offsets 
 *        can be returned [in]
 * @param scan_range The starting and ending pos to be scanned [in] 
 *        on exit, scan_range[0] is updated to be the stopping pos [out]
*/

static Int4 s_BlastNaScanSubject_8_4(const LookupTableWrap * lookup_wrap,
                        const BLAST_SequenceBlk * subject,
                        BlastOffsetPair * NCBI_RESTRICT offset_pairs,
                        Int4 max_hits, Int4 * scan_range)
{
    Uint1 *s;
    Uint1 *abs_start, *s_end;
    BlastNaLookupTable *lookup;
    Int4 num_hits;
    Int4 total_hits = 0;
    Int4 lut_word_length;

//    ASSERT(lookup_wrap->lut_type == eNaLookupTable);
//    lookup = (BlastNaLookupTable *) lookup_wrap->lut;

//    lut_word_length = lookup->lut_word_length;
//    ASSERT(lut_word_length == 8);

    abs_start = subject->sequence;
    s = abs_start + scan_range[0] / COMPRESSION_RATIO;
    s_end = abs_start + scan_range[1] / COMPRESSION_RATIO;

    for (; s <= s_end; s++) {

        Int4 index = s[0] << 8 | s[1];

        num_hits = s_BlastLookupGetNumHits(lookup, index);
        if (num_hits == 0)
            continue;
        if (num_hits > (max_hits - total_hits))
            break;

        s_BlastLookupRetrieve(lookup,
                              index,
                              offset_pairs + total_hits,
                              (s - abs_start) * COMPRESSION_RATIO);
        total_hits += num_hits;
    }
    scan_range[0] = (s - abs_start) * COMPRESSION_RATIO;

    return total_hits;
}
