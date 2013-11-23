// AppLogger.cpp

#include "Poco/LoggingFactory.h"
#include "Poco/Logger.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FileChannel.h"

#include "../include/AppLogger.h"

using namespace Poco;
using namespace std;

CAppLogger::CAppLogger(
		const std::string& logFileName 				/*= "log.log"*/,
		Poco::Message::Priority minFilePriority 	/*= Poco::Message::PRIO_INFORMATION*/,
		Poco::Message::Priority minConsolePriority	/*= Poco::Message::PRIO_INFORMATION*/)
{
	// We tell the vector how much elements we it'll have - its more efficient.
	mLoggers.resize(ELoggersCount);
	// Build the loggers
	mLoggers[ELoggerConsole] =
		&Logger::create("Log.Console", LoggingFactory::defaultFactory().createChannel("ConsoleChannel"), minConsolePriority);
	mLoggers[ELoggerFile] =
		&Logger::create("Log.File", LoggingFactory::defaultFactory().createChannel("FileChannel"), minFilePriority);
	//note that the priorty level set different. the file logger will have more masseges then the console logger


	// Set file channel path property (file & directory).
	mLoggers[ELoggerFile]->getChannel()->setProperty("path", logFileName);

	// Open all loggers.
	vector<Logger*>::iterator iterator;
	for(iterator = mLoggers.begin();
		iterator != mLoggers.end();
		iterator++)
	{
		if (*iterator != NULL)
		{
			(*iterator)->getChannel()->open();
		}
	}
}

CAppLogger::~CAppLogger(void)
{
	// Close all loggers
	vector<Logger*>::iterator iterator;
	for(iterator = mLoggers.begin();
		iterator != mLoggers.end();
		iterator++)
	{
		if (*iterator != NULL)
		{
			(*iterator)->getChannel()->close();
			(*iterator)->getChannel()->release();
		}
	}
}

void CAppLogger::Log(const std::string& title,const std::string& content, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/)
{
	std::string level;

	switch(inPriority){
		case Poco::Message::PRIO_CRITICAL:
			level = "critical";
			break;
		case Poco::Message::PRIO_DEBUG:
			level = "debug";
			break;
		case Poco::Message::PRIO_ERROR:
			level = "error";
			break;
		case Poco::Message::PRIO_FATAL:
			level = "fatal";
			break;
		case Poco::Message::PRIO_INFORMATION:
			level = "information";
			break;
		case Poco::Message::PRIO_NOTICE:
			level = "notice";
			break;
		case Poco::Message::PRIO_TRACE:
			level = "trace";
			break;
		case Poco::Message::PRIO_WARNING:
			level = "warning";
			break;
		default:
			level = "n/a";
			break;
	}

	Message msg;
	msg.setPriority(inPriority);
	//TODO: masasa: no need for logger titles, only Bold comments.
	msg.setText(title+" ("+level+")"+'\n'+content);

	vector<Logger*>::iterator iterator;
	for(iterator = mLoggers.begin();
		iterator != mLoggers.end();
		iterator++)
	{
		if (*iterator != NULL)
		{
			(*iterator)->log(msg);
		}
	}
}

void CAppLogger::Log(const std::ostringstream& inLogString, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/)
{
	Log("",inLogString.str(), inPriority);
}

