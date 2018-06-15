#ifndef DPLYR_DPLYR_BAD_H
#define DPLYR_DPLYR_BAD_H

namespace dplyr {

template<class C1>
void NORET bad_arg(const SymbolString& arg, C1 arg1) {
  static Function bad_fun = Function("bad_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(arg.get_string()), arg1, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2>
void NORET bad_arg(const SymbolString& arg, C1 arg1, C2 arg2) {
  static Function bad_fun = Function("bad_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(arg.get_string()), arg1, arg2, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2, class C3>
void NORET bad_arg(const SymbolString& arg, C1 arg1, C2 arg2, C3 arg3) {
  static Function bad_fun = Function("bad_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(arg.get_string()), arg1, arg2, arg3, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1>
void NORET bad_pos_arg(int pos_arg, C1 arg1) {
  static Function bad_fun = Function("bad_pos_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(pos_arg, arg1, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2>
void NORET bad_pos_arg(int pos_arg, C1 arg1, C2 arg2) {
  static Function bad_fun = Function("bad_pos_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(pos_arg, arg1, arg2, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2, class C3>
void NORET bad_pos_arg(int pos_arg, C1 arg1, C2 arg2, C3 arg3) {
  static Function bad_fun = Function("bad_pos_args", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(pos_arg, arg1, arg2, arg3, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1>
void NORET bad_col(const SymbolString& col, C1 arg1) {
  static Function bad_fun = Function("bad_cols", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(col.get_string()), arg1, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2>
void NORET bad_col(const SymbolString& col, C1 arg1, C2 arg2) {
  static Function bad_fun = Function("bad_cols", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(col.get_string()), arg1, arg2, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

template<class C1, class C2, class C3>
void NORET bad_col(const SymbolString& col, C1 arg1, C2 arg2, C3 arg3) {
  static Function bad_fun = Function("bad_cols", Environment::namespace_env("dplyr"));
  static Function identity = Function("identity", Environment::base_env());
  String message = bad_fun(CharacterVector::create(col.get_string()), arg1, arg2, arg3, _[".abort"] = identity);
  message.set_encoding(CE_UTF8);
  stop(message.get_cstring());
}

}

#endif // DPLYR_DPLYR_BAD_H
