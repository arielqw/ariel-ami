/*
 * CoffeeManager.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "CoffeeManager.h"

CoffeeManager::CoffeeManager():_revenue(0), _profit(0), _shop(NULL), _customers() {

}

CoffeeManager::CoffeeManager(const CoffeeManager& other):_revenue(0), _profit(0), _shop(NULL), _customers() {
	//unreachble
}

CoffeeManager& CoffeeManager::operator =(const CoffeeManager& other) {
	//unreachble
	return *this;
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

void CoffeeManager::readFromFile(const string&  filename,vector< vector<string> >& table, char delimiter) {
	string line;

	//Splitting lines by ',' and saving to vector of strings
	ifstream myfile(filename.c_str());
	if (myfile.is_open()) {
		while (getline(myfile, line)) {
			vector<string> splitLine;
			splitString(line, delimiter, splitLine);
			table.push_back( splitLine );
		}
		myfile.close();
	}
	else{
		//"Unable to open file";
		CAppLogger::Instance().Log(filename+" not found.",Poco::Message::PRIO_CRITICAL);
	}
}

void CoffeeManager::registerEvent(const string& name, const string& product_name, const string& is_VIP) {
	_customers.registerCustomer(name,product_name,is_VIP);

	std::string isVIPstr = "regular";
	if(is_VIP == "1"){
		isVIPstr= "VIP";
	}
	CAppLogger::Instance().Log("New "+isVIPstr+" Costumer registered - "+name+", Favorite product - "+product_name+".",Poco::Message::PRIO_NOTICE);

}

void CoffeeManager::purchaseEvent(const string& customer_image) {
	CAppLogger::Instance().Log("purchasing: "+customer_image,Poco::Message::PRIO_TRACE);

	ImgTools image("customers/"+ customer_image);

	vector<Customer*> customersContainer;
	_customers.detectCustomers(image, customersContainer);

	ostringstream debugStr;
	debugStr << "detected " << customersContainer.size() << " customers in photo";
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_DEBUG);

	//iterates over customers found in picture and tries to make a purchase for any single one of them
	for (unsigned int i = 0; i < customersContainer.size(); ++i) {
		singleBuy(*(customersContainer[i]));
	}
}

void CoffeeManager::updateSupplierIngredientEvent(const string& supplier_name, const string& ingredient_name, const string& price) {
	int numOfChangedProducts = _shop->updateSupplierIngredient(supplier_name,ingredient_name,price);

	std::ostringstream debugStr;
	debugStr << "Supplier " << supplier_name <<
				" changed the price of " << ingredient_name << endl <<
				"Products updated: " << numOfChangedProducts;
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_NOTICE);
}

void CoffeeManager::singleBuy(Customer& buyer) {
	MenuItem* favoriteItem = _shop->getProductPrice( buyer.getFavoriteProduct() );
	if(favoriteItem->isOnMenu()){ //found
		double total = buyer.computeProductPrice( favoriteItem->getBrutoPrice() );
		double neto = favoriteItem->getNetoPrice();
		CAppLogger::Instance().Log("Costumer "+buyer.getCustomerName()+" purchased "+favoriteItem->getName(),Poco::Message::PRIO_WARNING);

		_revenue += total;
		_profit += (total-neto);
	}
	else{ //not found
		CAppLogger::Instance().Log("Costumer "+buyer.getCustomerName()+" failed to purchase "+favoriteItem->getName(),Poco::Message::PRIO_WARNING);
	}
}


CoffeeManager::~CoffeeManager() {
	
}

void CoffeeManager::eventHandler(const string& eventFileName) {
	//0. read from file
	vector< vector<string> > eventsList;
	readFromFile(eventFileName,eventsList,',');

	//going through each line
	for (unsigned int i = 0; i < eventsList.size(); ++i) {
		std::string event = eventsList[i][0];
		if(event == "register"){
			registerEvent(eventsList[i][1], eventsList[i][2], eventsList[i][3]);
		}
		else if(event == "purchase"){
			purchaseEvent(eventsList[i][1]);
		}
		else if(event == "supplier_change"){
			updateSupplierIngredientEvent(eventsList[i][1], eventsList[i][2], eventsList[i][3]);
		}

	}

	_customers.saveCostumersCollage();

}

void CoffeeManager::logRevenueAndProfit() const {
	char c_revenue[10];
	char c_profit[10];
	sprintf(c_revenue,"%.2f",_revenue);
	sprintf(c_profit,"%.2f",_profit);

	CAppLogger::Instance().Log("The total revenue is "+std::string(c_revenue)+", while the total profit is "+std::string(c_profit),Poco::Message::PRIO_WARNING);
}



void CoffeeManager::start(const string& confFileName, const string& productsFileName,const string& suppliersFileName,const string& eventFileName) {


	vector< vector<string> > confInput;
	readFromFile(confFileName, confInput, '=');

	//////// Init Logger //////////////////////////

	std::string LOG_FILE_NAME = "app.log";
	Poco::Message::Priority LOGGER_FILE_PRIORITY = Poco::Message::PRIO_INFORMATION;
	Poco::Message::Priority LOGGER_CONSOLE_PRIORITY= Poco::Message::PRIO_DEBUG;

	for (unsigned int i = 0; i < confInput.size(); ++i) {
		if( confInput[i][0] == "LOG_FILE_NAME"){
			LOG_FILE_NAME = confInput[i][1];
		}
		else if(confInput[i][0] == "LOGGER_FILE_PRIORITY"){
			LOGGER_FILE_PRIORITY = (Poco::Message::Priority)atoi(confInput[i][1].c_str());
		}
		else if(confInput[i][0] == "LOGGER_CONSOLE_PRIORITY"){
			LOGGER_CONSOLE_PRIORITY = (Poco::Message::Priority)atoi(confInput[i][1].c_str());
		}
	}

	CAppLogger::Instance( LOG_FILE_NAME,LOGGER_FILE_PRIORITY,LOGGER_CONSOLE_PRIORITY );

	//////// Init Logger end //////////////////////////


	vector< vector<string> > productsInput;
	vector< vector<string> > suppliersInput;

	readFromFile(productsFileName,productsInput,',');
	readFromFile(suppliersFileName,suppliersInput,',');

	_shop = new UniCoffeeShop();

	_shop->start(productsInput,suppliersInput);

	//read through the file events and run them realtime
	eventHandler(eventFileName);

	_customers.saveCostumersCollage();

	logRevenueAndProfit();

	delete _shop;
}






