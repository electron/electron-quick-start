#pragma once
#include <plog/Logger.h>
#include <plog/Severity.h>
#include <plog/Appenders/IAppender.h>

namespace plog
{
    //////////////////////////////////////////////////////////////////////////
    // Empty initializer / one appender

    template<int instance>
    inline Logger<instance>& init(Severity maxSeverity = none, IAppender* appender = NULL)
    {
        static Logger<instance> logger;
        logger.setMaxSeverity(maxSeverity);
        return appender ? logger.addAppender(appender) : logger;
    }

    inline Logger<0>& init(Severity maxSeverity = none, IAppender* appender = NULL)
    {
        return init<0>(maxSeverity, appender);
    }
}
