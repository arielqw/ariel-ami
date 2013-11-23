// AppLogger.h

#ifndef APP_LOGGER_H
#define APP_LOGGER_H

#include <string>
#include <sstream>
#include <vector>

#include "Poco/Message.h"

// Forward decalrations (instant including h files)
namespace Poco{class Logger;};
class CMyLogger;

// Application logger: class that handles all application logging.
// It is implemented as a singleton
// Singleton is a design pattern that is used to restrict instantiation of a class to one object.
// This is useful when exactly one object is needed to coordinate actions across the system - for example only one logger.
// Sometimes it is generalized to systems that operate more efficiently when only one or a few objects exist.

class CAppLogger
{
private:
        enum ELogger
        {
                ELoggerFile             = 0,
                   ELoggerConsole,

                ELoggersCount
            };

        CAppLogger(
             		const std::string& logFileName,
        		Poco::Message::Priority minFilePriority,
        		Poco::Message::Priority minConsolePriority);

public:
        ~CAppLogger(void);

        // The one and only application logger is accessible through this method
        static CAppLogger& Instance(
        		const std::string& logFileName = "log.log",
        		Poco::Message::Priority minFilePriority 	= Poco::Message::PRIO_INFORMATION,
        		Poco::Message::Priority minConsolePriority	= Poco::Message::PRIO_INFORMATION
        	)
        {
                // This is the instance.
                static CAppLogger instance(logFileName, minFilePriority, minConsolePriority);

                static bool firstCall = true;
                if (firstCall)
                {
                        firstCall = false;
                        //instance.Log("Message","Starting new log session.", Poco::Message::PRIO_DEBUG);
                }


                // Return a reference to the instance.
                return instance;
        }

        static void Init(const std::string& logFileName, Poco::Message::Priority minFilePriority, Poco::Message::Priority minConsolePriority)
        {

        }
        // Write to log a STL string.
        void Log(const std::string& title,const std::string& content, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/);
        // Write to log a STL string stream.
        void Log(const std::ostringstream& inLogString, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/);

private:
        // Holds pointers to all loggers
        std::vector<Poco::Logger*> mLoggers;
};

#endif // APP_LOGGER_H

