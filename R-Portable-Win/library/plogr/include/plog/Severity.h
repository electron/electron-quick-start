#pragma once

namespace plog
{
    enum Severity
    {
        none = 0,
        fatal = 1,
        error = 2,
        warning = 3,
        info = 4,
        debug = 5,
        verbose = 6
    };

    inline const char* getSeverityName(Severity severity)
    {
        switch (severity)
        {
        case fatal:
            return "FATAL";
        case error:
            return "ERROR";
        case warning:
            return "WARN";
        case info:
            return "INFO";
        case debug:
            return "DEBUG";
        case verbose:
            return "VERB";
        default:
            return "NONE";
        }
    }

    inline Severity getSeverityCode(const std::string& name)
    {
        if (name == "FATAL")
            return fatal;
        if (name == "ERROR")
            return error;
        if (name == "WARN")
            return warning;
        if (name == "INFO")
            return info;
        if (name == "DEBUG")
            return debug;
        if (name == "VERB")
            return verbose;

        return none;
    }
}
