/*
 * CoffeeManager.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "../include/CoffeeManager.h"

CoffeeManager::CoffeeManager() {
	// TODO Auto-generated constructor stub


}
void CoffeeManager::splitString(const string& str,char delimiter, vector<string>& output){
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

void CoffeeManager::readFromFile(const string&  filename,vector< vector<string> >& table) {
	string line;

	//Splitting lines by ',' and saving to vector of strings
	ifstream myfile(filename.c_str());
	if (myfile.is_open()) {
		while (getline(myfile, line)) {
			vector<string> splitLine;
			splitString(line, ',', splitLine);
			table.push_back( splitLine );
		}
		myfile.close();
	}
	else
		cout << "Unable to open file";
}

void CoffeeManager::registerEvent(const string& name, const string& product_name, const string& is_VIP) {
	std::cout<< "registerEvent: "<< name << " " << product_name << " " << is_VIP << std::endl;
}

void CoffeeManager::purchaseEvent(const string& customer_image) {
	std::cout<< "purchaseEvent: "<< customer_image << std::endl;
}

void CoffeeManager::updateSupplierIngredientEvent(const string& supplier_name, const string& ingredient_name, const string& price) {
	std::cout<< "updateSupplierIngredientEvent: "<< supplier_name << " " << ingredient_name << " " << price << std::endl;
}

void CoffeeManager::singleBuy() {
}


CoffeeManager::~CoffeeManager() {
	// TODO Auto-generated destructor stub
}

void CoffeeManager::eventHandler(const string& eventFileName) {
	//0. read from file
	vector< vector<string> > eventsList;
	readFromFile(eventFileName,eventsList);

	//going through each line
	for (int i = 0; i < eventsList.size(); ++i) {
		std::string event = eventsList[i][0];
		if(event == "register"){
			std::cout << eventsList[i].size() << std::endl;
			registerEvent(eventsList[i][1], eventsList[i][2], eventsList[i][3]);
		}
		else if(event == "purchase"){
			purchaseEvent(eventsList[i][1]);
		}
		else if(event == "supplier_change"){
			updateSupplierIngredientEvent(eventsList[i][1], eventsList[i][2], eventsList[i][3]);
		}

	}
	//1. readLine
	//2. called event
}

void CoffeeManager::start(const string& productsFileName,const string& suppliersFileName,const string& eventFileName) {

	vector< vector<string> > productsInput;
	vector< vector<string> > suppliersInput;

	readFromFile(productsFileName,productsInput);
	readFromFile(suppliersFileName,suppliersInput);

	_shop = new UniCoffeeShop(productsInput,suppliersInput);

	_shop->start();

	eventHandler(eventFileName);

	delete _shop;
}






