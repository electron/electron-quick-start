#pragma once
#include "ConsoleAppender.h"

namespace plog
{
    template<class Formatter>
    class ColorConsoleAppender : public ConsoleAppender<Formatter>
    {
    public:
#ifdef _WIN32
        ColorConsoleAppender() : m_isatty(!!::_isatty(::_fileno(stdout))), m_stdoutHandle(), m_originalAttr()
        {
            if (m_isatty)
            {
                m_stdoutHandle = ::GetStdHandle(STD_OUTPUT_HANDLE);

                CONSOLE_SCREEN_BUFFER_INFO csbiInfo;
                ::GetConsoleScreenBufferInfo(m_stdoutHandle, &csbiInfo);

                m_originalAttr = csbiInfo.wAttributes;
            }
        }
#else
        ColorConsoleAppender() : m_isatty(!!::isatty(::fileno(stdout))) {}
#endif

        virtual void write(const Record& record)
        {
            setColor(record.getSeverity());
            ConsoleAppender<Formatter>::write(record);
            resetColor();
        }

    private:
        void setColor(Severity severity)
        {
            if (m_isatty)
            {
                switch (severity)
                {
#ifdef _WIN32
                case fatal:
                    ::SetConsoleTextAttribute(m_stdoutHandle, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY | BACKGROUND_RED); // white on red background
                    break;

                case error:
                    ::SetConsoleTextAttribute(m_stdoutHandle, FOREGROUND_RED | FOREGROUND_INTENSITY | (m_originalAttr & 0xf0)); // red
                    break;

                case warning:
                    ::SetConsoleTextAttribute(m_stdoutHandle, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY | (m_originalAttr & 0xf0)); // yellow
                    break;

                case debug:
                case verbose:
                    ::SetConsoleTextAttribute(m_stdoutHandle, FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY | (m_originalAttr & 0xf0)); // cyan
                    break;
#else
                case fatal:
                    std::cout << "\x1B[97m\x1B[41m"; // white on red background
                    break;

                case error:
                    std::cout << "\x1B[91m"; // red
                    break;

                case warning:
                    std::cout << "\x1B[93m"; // yellow
                    break;

                case debug:
                case verbose:
                    std::cout << "\x1B[96m"; // cyan
                    break;
#endif
                default:
                    break;
                }
            }
        }

        void resetColor()
        {
            if (m_isatty)
            {
#ifdef _WIN32
                ::SetConsoleTextAttribute(m_stdoutHandle, m_originalAttr);
#else
                std::cout << "\x1B[0m\x1B[0K";
#endif
            }
        }

    private:
        bool    m_isatty;
#ifdef _WIN32
        HANDLE  m_stdoutHandle;
        WORD    m_originalAttr;
#endif
    };
}
