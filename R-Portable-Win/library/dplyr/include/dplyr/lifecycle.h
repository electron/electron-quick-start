#ifndef DPLYR_LIFECYCLE_H
#define DPLYR_LIFECYCLE_H

namespace dplyr {
namespace lifecycle {

void warn_deprecated(const std::string&);
void signal_soft_deprecated(const std::string&, SEXP);

}
}

#endif
