#ifndef plogr_plogr_H
#define plogr_plogr_H

#include "plog/Log.h"
#include "plog/Formatters/FuncMessageFormatter.h"

#include <R.h>

namespace plog {

template<class Formatter>
class RAppender : public IAppender
{
public:
  virtual void write(const Record& record)
  {
    util::nstring str = Formatter::format(record); // Use the formatter to get a string from a record.
    REprintf("%s", str.c_str());
  }
};

inline void init_r(Severity maxSeverity = none) {
  static bool initialized = false;
  static RAppender<FuncMessageFormatter> appender;
  if (!initialized) {
    init(maxSeverity, &appender);
    initialized = true;
  } else {
    init(maxSeverity);
  }
}

inline void init_r(const std::string& maxSeverity = "NONE") {
  init_r(getSeverityCode(maxSeverity));
}

}

#endif // #ifndef plogr_plogr_H
