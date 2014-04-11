/*
* File Name     : Defs.h
*
* Author        : Corey Olson
*
* Description   : This is a definitions file for Pico Computing's Smith-Waterman
* 				  alignment system, which is part of the Pico Bioinformatics
* 				  Accelerated Suite (PicoBASe).  This Smith-Waterman software is
* 				  based upon the CUDASW++ work done by Liu Yongchao
* 				  (http://cudasw.sourceforge.net/).
*
* Copyright     : 2013, Pico Computing, Inc.
*/
#ifndef DEFS_H_
#define DEFS_H_

// parameters that can be modified by the user
#define PICO_SW_VERSION					"0.1"

//* for nucleotide alignments
#define MAX_NUCLEOTIDES					5	// A, C, G, T, N
#define DUMMY_NUCLEOTIDE  				(MAX_NUCLEOTIDES + 1)
#define NUCLEOTIDE_MATRIX_SIZE			(MAX_NUCLEOTIDES + 2)
// */

//* for amino acid alignments
#define MAX_AMINO_ACIDS     			23
#define DUMMY_AMINO_ACID   				(MAX_AMINO_ACIDS + 1)
#define AMINO_MATRIX_SIZE				(MAX_AMINO_ACIDS + 2)
// */

#endif /* DEFS_H_ */
