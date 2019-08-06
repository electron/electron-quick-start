#ifndef DPLYR_SYMBOLS_H
#define DPLYR_SYMBOLS_H

namespace dplyr {

struct symbols {
  static SEXP package;
  static SEXP n;
  static SEXP tzone;
  static SEXP units;
  static SEXP dot_env;
  static SEXP dot_data;

  static SEXP sum;
  static SEXP mean;
  static SEXP var;
  static SEXP sd;
  static SEXP n_distinct;
  static SEXP first;
  static SEXP last;
  static SEXP nth;
  static SEXP group_indices;
  static SEXP min;
  static SEXP max;
  static SEXP row_number;
  static SEXP ntile;
  static SEXP min_rank;
  static SEXP percent_rank;
  static SEXP dense_rank;
  static SEXP cume_dist;
  static SEXP lead;
  static SEXP lag;
  static SEXP in;

  static SEXP narm;
  static SEXP default_;

  static SEXP dplyr;
  static SEXP base;
  static SEXP stats;

  static SEXP desc;
  static SEXP double_colon;
  static SEXP na_rm;
  static SEXP new_env;
  static SEXP comment;
  static SEXP groups;
  static SEXP vars;
  static SEXP position;

  static SEXP op_minus;
  static SEXP str;
  static SEXP dot_Internal;
  static SEXP inspect;
  static SEXP dot;
  static SEXP dot_x;
  static SEXP drop;
  static SEXP rlang;
  static SEXP eval_tidy;
  static SEXP quote;
  static SEXP dot_drop;
  static SEXP warn_deprecated;
  static SEXP signal_soft_deprecated;
  static SEXP call;
  static SEXP env;
  static SEXP fun;
  static SEXP cpp_class;
  static SEXP levels;
  static SEXP labels;
  static SEXP indices;
  static SEXP ptype;
  static SEXP names;
  static SEXP formula;
};

struct fns {
  static SEXP quote;
};

struct strings {
  static SEXP POSIXct;
  static SEXP POSIXt;
  static SEXP Date;
};

struct vectors {
  static SEXP factor;
};

} // namespace dplyr


#endif
