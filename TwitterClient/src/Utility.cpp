/*
 * Utility.cpp
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#include "../include/Utility.h"

Utility::Utility() {
	// TODO Auto-generated constructor stub

}

Utility::~Utility() {
	// TODO Auto-generated destructor stub
}

void Utility::splitString(const string& str,char delimiter, vector<string>& output){
	string tmp="";

	for(unsigned int i=0;i<str.length();i++){
		if(str[i] != delimiter){
			tmp = tmp+str[i];
		}
		else{
			output.push_back(tmp);
			tmp="";
		}
	}
	output.push_back(tmp);
}
