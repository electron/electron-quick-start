#ifndef DPLYR_ENCODING_H
#define DPLYR_ENCODING_H

#define TYPE_BITS 5
#define BYTES_MASK (1<<1)
#define LATIN1_MASK (1<<2)
#define UTF8_MASK (1<<3)
#define ASCII_MASK (1<<6)

struct sxpinfo_struct {
  // *INDENT-OFF*
  SEXPTYPE type    :  TYPE_BITS;/* ==> (FUNSXP == 99) %% 2^5 == 3 == CLOSXP
                                 * -> warning: `type' is narrower than values
                                 *              of its type
                                 * when SEXPTYPE was an enum */
  // *INDENT-ON*
  unsigned int obj   :  1;
  unsigned int named :  2;
  unsigned int gp    : 16;
  unsigned int mark  :  1;
  unsigned int debug :  1;
  unsigned int trace :  1;  /* functions and memory tracing */
  unsigned int spare :  1;  /* currently unused */
  unsigned int gcgen :  1;  /* old generation number */
  unsigned int gccls :  3;  /* node class */
}; /*		  Tot: 32 */

#ifndef IS_BYTES
#define IS_BYTES(x) (reinterpret_cast<sxpinfo_struct*>(x)->gp & BYTES_MASK)
#endif

#ifndef IS_LATIN1
#define IS_LATIN1(x) (reinterpret_cast<sxpinfo_struct*>(x)->gp & LATIN1_MASK)
#endif

#ifndef IS_ASCII
#define IS_ASCII(x) (reinterpret_cast<sxpinfo_struct*>(x)->gp & ASCII_MASK)
#endif

#ifndef IS_UTF8
#define IS_UTF8(x) (reinterpret_cast<sxpinfo_struct*>(x)->gp & UTF8_MASK)
#endif

namespace dplyr {

Rcpp::CharacterVector reencode_factor(Rcpp::IntegerVector x);
Rcpp::CharacterVector reencode_char(SEXP x);

}


#endif
