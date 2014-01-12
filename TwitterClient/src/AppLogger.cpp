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
		Poco::Message::Priority minConsolePriority	/*= Poco::Message::PRIO_INFORMATION*/):mLoggers()
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
	destroyHtmlLogger();
}

void CAppLogger::Log(const std::string& inLogString, Poco::Message::Priority inPriority/* = Poco::Message::PRIO_INFORMATION*/)
{
	Message msg;
	msg.setPriority(inPriority);

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



void CAppLogger::StartHtmlLogger(const string& loggerName) {
	map<string, Poco::Logger*>::iterator it = mHtmlLoggers.find(loggerName);
	if (it != mHtmlLoggers.end())	return;			//logger exists - do nothing

	Poco::Logger* logger = &Logger::create(loggerName, LoggingFactory::defaultFactory().createChannel("FileChannel"), Poco::Message::PRIO_INFORMATION);
	logger->getChannel()->setProperty("path", loggerName+".html");
	mHtmlLoggers[loggerName] = logger;
	logger->getChannel()->open();
	Message msg;
	msg.setPriority(Poco::Message::PRIO_INFORMATION);
	msg.setText("<html><body><h3>username: " + loggerName + "</h3><table border='solid black'>");
	logger->log(msg);

}

void CAppLogger::destroyHtmlLogger() {

	for(map<string, Poco::Logger*>::iterator p = mHtmlLoggers.begin(); p!=mHtmlLoggers.end(); ++p)
	{
		Logger* logger = p->second;
		Message msg;
		msg.setPriority(Poco::Message::PRIO_INFORMATION);
		msg.setText("</table></body></html>");
		logger->log(msg);
		//destroy
		logger->getChannel()->close();
		logger->getChannel()->release();
	}
	mHtmlLoggers.clear();

}

void CAppLogger::LogHtmlRow(const string& loggerName, string arg0, string arg1) {
	map<string, Poco::Logger*>::iterator it = mHtmlLoggers.find(loggerName);
	if (it == mHtmlLoggers.end())	return;		//logger wasnt found

	Logger* logger = it->second;

	stringstream ss;
	ss << "<tr><td>" << arg0 << "</td><td>" << arg1 << "</td><td>" << CurrentDateTime() << "</td></tr>";
	Message msg;
	msg.setPriority(Poco::Message::PRIO_INFORMATION);
	msg.setText(ss.str());
	logger->log(msg);

}


// Get current date/time, format is YYYY-MM-DD.HH:mm:ss
// Get current date/time, format is DD-MM-YYYY HH:mm:ss
const std::string CAppLogger::CurrentDateTime() {
    time_t     now = time(0);
    struct tm  tstruct;
    char       buf[80];
    tstruct = *localtime(&now);
    // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
    // for more information about date/time format
    strftime(buf, sizeof(buf), "%d/%m/%Y %X", &tstruct);

    return buf;
}



