//////////////////////////////////////////////////////////////////////////
//  Plog - portable and simple log for C++
//  Documentation and sources: https://github.com/SergiusTheBest/plog
//  License: MPL 2.0, http://mozilla.org/MPL/2.0/

#pragma once
#include <plog/Record.h>
#include <plog/Logger.h>
#include <plog/Init.h>

//////////////////////////////////////////////////////////////////////////
// Helper macros that get context info

#ifdef _MSC_BUILD
#   if _MSC_VER >= 1600 && !defined(__INTELLISENSE__) // >= Visual Studio 2010 and skip IntelliSense
#       define PLOG_GET_THIS()      __if_exists(this) { this } __if_not_exists(this) { 0 }
#   else
#       define PLOG_GET_THIS()      0
#   endif
#   define PLOG_GET_FUNC()          __FUNCTION__
#else
#   define PLOG_GET_THIS()          0
#   define PLOG_GET_FUNC()          __PRETTY_FUNCTION__
#endif

//////////////////////////////////////////////////////////////////////////
// Global switch

#ifdef PLOGR_ENABLE
#define _PLOGR_ENABLE 1
#else
#define _PLOGR_ENABLE 0
#endif // PLOGR_ENABLE

//////////////////////////////////////////////////////////////////////////
// Log severity level checker

#define IF_LOG_(instance, severity)     if (_PLOGR_ENABLE && plog::get<instance>() && plog::get<instance>()->checkSeverity(severity))
#define IF_LOG(severity)                IF_LOG_(0, severity)

//////////////////////////////////////////////////////////////////////////
// Main logging macros

#define LOG_(instance, severity)        IF_LOG_(instance, severity) (*plog::get<instance>()) += plog::Record(severity, PLOG_GET_FUNC(), __LINE__, PLOG_GET_THIS())
#define LOG(severity)                   LOG_(0, severity)

#define LOG_VERBOSE                     LOG(plog::verbose)
#define LOG_DEBUG                       LOG(plog::debug)
#define LOG_INFO                        LOG(plog::info)
#define LOG_WARNING                     LOG(plog::warning)
#define LOG_ERROR                       LOG(plog::error)
#define LOG_FATAL                       LOG(plog::fatal)

#define LOG_VERBOSE_(instance)          LOG_(instance, plog::verbose)
#define LOG_DEBUG_(instance)            LOG_(instance, plog::debug)
#define LOG_INFO_(instance)             LOG_(instance, plog::info)
#define LOG_WARNING_(instance)          LOG_(instance, plog::warning)
#define LOG_ERROR_(instance)            LOG_(instance, plog::error)
#define LOG_FATAL_(instance)            LOG_(instance, plog::fatal)

#define LOGV                            LOG_VERBOSE
#define LOGD                            LOG_DEBUG
#define LOGI                            LOG_INFO
#define LOGW                            LOG_WARNING
#define LOGE                            LOG_ERROR
#define LOGF                            LOG_FATAL

#define LOGV_(instance)                 LOG_VERBOSE_(instance)
#define LOGD_(instance)                 LOG_DEBUG_(instance)
#define LOGI_(instance)                 LOG_INFO_(instance)
#define LOGW_(instance)                 LOG_WARNING_(instance)
#define LOGE_(instance)                 LOG_ERROR_(instance)
#define LOGF_(instance)                 LOG_FATAL_(instance)

//////////////////////////////////////////////////////////////////////////
// Conditional logging macros

#define LOG_IF_(instance, severity, condition)  if (condition) LOG_(instance, severity)
#define LOG_IF(severity, condition)             LOG_IF_(0, severity, condition)

#define LOG_VERBOSE_IF(condition)               LOG_IF(plog::verbose, condition)
#define LOG_DEBUG_IF(condition)                 LOG_IF(plog::debug, condition)
#define LOG_INFO_IF(condition)                  LOG_IF(plog::info, condition)
#define LOG_WARNING_IF(condition)               LOG_IF(plog::warning, condition)
#define LOG_ERROR_IF(condition)                 LOG_IF(plog::error, condition)
#define LOG_FATAL_IF(condition)                 LOG_IF(plog::fatal, condition)

#define LOG_VERBOSE_IF_(instance, condition)    LOG_IF_(instance, plog::verbose, condition)
#define LOG_DEBUG_IF_(instance, condition)      LOG_IF_(instance, plog::debug, condition)
#define LOG_INFO_IF_(instance, condition)       LOG_IF_(instance, plog::info, condition)
#define LOG_WARNING_IF_(instance, condition)    LOG_IF_(instance, plog::warning, condition)
#define LOG_ERROR_IF_(instance, condition)      LOG_IF_(instance, plog::error, condition)
#define LOG_FATAL_IF_(instance, condition)      LOG_IF_(instance, plog::fatal, condition)

#define LOGV_IF(condition)                      LOG_VERBOSE_IF(condition)
#define LOGD_IF(condition)                      LOG_DEBUG_IF(condition)
#define LOGI_IF(condition)                      LOG_INFO_IF(condition)
#define LOGW_IF(condition)                      LOG_WARNING_IF(condition)
#define LOGE_IF(condition)                      LOG_ERROR_IF(condition)
#define LOGF_IF(condition)                      LOG_FATAL_IF(condition)

#define LOGV_IF_(instance, condition)           LOG_VERBOSE_IF_(instance, condition)
#define LOGD_IF_(instance, condition)           LOG_DEBUG_IF_(instance, condition)
#define LOGI_IF_(instance, condition)           LOG_INFO_IF_(instance, condition)
#define LOGW_IF_(instance, condition)           LOG_WARNING_IF_(instance, condition)
#define LOGE_IF_(instance, condition)           LOG_ERROR_IF_(instance, condition)
#define LOGF_IF_(instance, condition)           LOG_FATAL_IF_(instance, condition)
