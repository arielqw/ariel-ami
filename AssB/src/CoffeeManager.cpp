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
		//cout << "Unable to open file";
		CAppLogger::Instance().Log("Error: producers/suppliers/configuration file not found",filename+" not found.",Poco::Message::PRIO_CRITICAL);
	}
}

void CoffeeManager::registerEvent(const string& name, const string& product_name, const string& is_VIP) {
	_customers.registerCustomer(name,product_name,is_VIP);

	std::string isVIPstr = "regular";
	if(is_VIP == "1"){
		isVIPstr= "VIP";
	}
	CAppLogger::Instance().Log("Customer Registration","New "+isVIPstr+" Costumer registered - "+name+", Favorite product - "+product_name+".",Poco::Message::PRIO_NOTICE);

}

void CoffeeManager::purchaseEvent(const string& customer_image) {
	CAppLogger::Instance().Log("custome message: ","purchasing: "+customer_image,Poco::Message::PRIO_DEBUG);

	ImgTools image("customers/"+ customer_image);

	vector<Customer*> customersContainer;
	_customers.detectCustomers(image, customersContainer);

	for (int i = 0; i < customersContainer.size(); ++i) {
		singleBuy(*(customersContainer[i]));
	}
}

void CoffeeManager::updateSupplierIngredientEvent(const string& supplier_name, const string& ingredient_name, const string& price) {
	_shop->updateSupplierIngredient(supplier_name,ingredient_name,price);
	std::string numOfChangedProducts;
	//TODO: num of products changed.
	CAppLogger::Instance().Log("Supplier price change","Supplier "+supplier_name+" changed the price of "+ingredient_name+"\nProducts updated: "+numOfChangedProducts,Poco::Message::PRIO_NOTICE);
}

void CoffeeManager::singleBuy(Customer& buyer) {
	MenuItem favoriteItem = _shop->getProductPrice( buyer.getFavoriteProduct() );
	if(favoriteItem.itemName != ""){ //found
		double total = buyer.computeProductPrice( favoriteItem.brutoPrice );
		double neto = favoriteItem.netoPrice;
		CAppLogger::Instance().Log("Purchase messages","Costumer "+buyer.getCustomerName()+" purchased "+favoriteItem.itemName,Poco::Message::PRIO_WARNING);

		_revenue += total;
		_profit += (total-neto);
	}
	else{ //not found
		CAppLogger::Instance().Log("Purchase messages","Costumer "+buyer.getCustomerName()+" failed to purchase "+favoriteItem.itemName,Poco::Message::PRIO_WARNING);
	}
}


CoffeeManager::~CoffeeManager() {
	// TODO Auto-generated destructor stub
}

void CoffeeManager::eventHandler(const string& eventFileName) {
	//0. read from file
	vector< vector<string> > eventsList;
	readFromFile(eventFileName,eventsList,',');

	//going through each line
	for (int i = 0; i < eventsList.size(); ++i) {
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
	//_customers.
	//1. readLine
	//2. called event
}

void CoffeeManager::start(const string& confFileName, const string& productsFileName,const string& suppliersFileName,const string& eventFileName) {


	vector< vector<string> > confInput;
	readFromFile(confFileName, confInput, '=');

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

	CAppLogger::Instance().Log("myTitle","LOG_FILE_NAME: "+LOG_FILE_NAME,Poco::Message::PRIO_INFORMATION);


	vector< vector<string> > productsInput;
	vector< vector<string> > suppliersInput;

	readFromFile(productsFileName,productsInput,',');
	readFromFile(suppliersFileName,suppliersInput,',');

	_shop = new UniCoffeeShop(productsInput,suppliersInput);

	_shop->start();

	eventHandler(eventFileName);

	char c_revenue[10];
	char c_profit[10];
	sprintf(c_revenue,"%.2f",_revenue);
	sprintf(c_profit,"%.2f",_profit);

	CAppLogger::Instance().Log("End of simulation","The total revenue is "+std::string(c_revenue)+", while the total profit is "+std::string(c_profit),Poco::Message::PRIO_WARNING);

	delete _shop;
}






