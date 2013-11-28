// AppLogger.cpp

#include "Poco/LoggingFactory.h"
#include "Poco/Logger.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FileChannel.h"

#include "AppLogger.h"

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

void CAppLogger::Log(const std::string& inLogString, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/)
{
	Message msg;
	msg.setPriority(inPriority);
	//TODO: masasa: no need for logger titles, only Bold comments.
	msg.setText(inLogString);

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
	Log(inLogString.str(), inPriority);
}

