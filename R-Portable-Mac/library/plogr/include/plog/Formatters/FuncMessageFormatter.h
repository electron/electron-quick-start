#pragma once
#include <plog/Util.h>

namespace plog
{
    class FuncMessageFormatter
    {
    public:
        static util::nstring header()
        {
            return util::nstring();
        }

        static util::nstring format(const Record& record)
        {
            util::nstringstream ss;
            ss << record.getFunc().c_str() << "@" << record.getLine() << ": ";
            ss << record.getMessage().c_str() << "\n";

            return ss.str();
        }
    };
}
