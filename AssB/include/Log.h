/*
 * LoggerWrapper.h
 *
 *  Created on: Nov 18, 2013
 *      Author: amio
 */

#ifndef LOG_H_
#define LOG_H_
#include "Poco/Logger.h"
#include "Poco/PatternFormatter.h"
#include "Poco/FormattingChannel.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FileChannel.h"
#include "Poco/Message.h"
using Poco::Logger;
using Poco::PatternFormatter;
using Poco::FormattingChannel;
using Poco::ConsoleChannel;
using Poco::FileChannel;
using Poco::Message;

class Log {
public:
	virtual ~Log();
	//static void Init(const std::string& logFileName,	Poco::Message::Priority minFilePriority, Poco::Message::Priority minConsolePriority);
private:
	Log();
};

#endif /* LOGGERWRAPPER_H_ */
