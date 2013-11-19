/*
 * LoggerWrapper.cpp
 *
 *  Created on: Nov 18, 2013
 *      Author: amio
 */

#include "../include/Log.h"

Log::Log() {
	// TODO Auto-generated constructor stub

}

Log::~Log() {
	// TODO Auto-generated destructor stub
}

/*
static void Log::Init(const std::string& logFileName,	Poco::Message::Priority minFilePriority, Poco::Message::Priority minConsolePriority)
{

}
*/
/*
static void Log::Init(const std::string& logConfFileName) {
	// set up two channel chains - one to the
	// console and the other one to a log file.
	FormattingChannel* pFCConsole = new FormattingChannel(new PatternFormatter("%s: %p: %t"));
	pFCConsole->setChannel(new ConsoleChannel);
	pFCConsole->open();

	FormattingChannel* pFCFile = new FormattingChannel(new PatternFormatter("%Y-%m-%d %H:%M:%S.%c %N[%P]:%s:%q:%t"));
	pFCFile->setChannel(new FileChannel("sample.log"));

	pFCFile->open();

	// create two Logger objects - one for
	// each channel chain.
	//Logger& consoleLogger = Logger::create("log", pFCConsole, Message::PRIO_DEBUG);
	Logger& consoleLogger = Logger::create("ConsoleLogger", pFCConsole, Message::PRIO_INFORMATION);
	Logger& fileLogger    = Logger::create("FileLogger", pFCFile, Message::PRIO_WARNING);

	// log some messages
	/*
	consoleLogger.error("An error message");
	fileLogger.error("An error message");

	consoleLogger.warning("A warning message");
	fileLogger.error("A warning message");

	consoleLogger.information("An information message");
	fileLogger.information("An information message");

	poco_information(consoleLogger, "Another informational message");
	poco_warning_f2(consoleLogger, "A warning message with arguments: %d, %d", 1, 2);

	Logger::get("ConsoleLogger").error("Another error message");

}
*/


