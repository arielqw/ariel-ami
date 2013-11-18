
#include "../include/UniCoffeeShop.h"

void UniCoffeeShop::splitString(const string& str,char delimiter, vector<string>& output){
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

void UniCoffeeShop::readFromFile(const string&  filename,vector< vector<string> >& table) {
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

void UniCoffeeShop::writeToFile(const string& filename , const string& str) const{
	ofstream myfile (filename.c_str());
	if (myfile.is_open())
	{
		myfile << str;
		myfile.close();
	}
	else	cout << "Unable to open file";
}


void UniCoffeeShop::printMatrix(const vector< vector<string> >& matrix) const{
	for (unsigned int i = 0; i < matrix.size(); ++i) {
		for (unsigned int j = 0; j < matrix[i].size(); ++j) {
			cout<< matrix[i][j]<<',';
		}
		cout<< endl;
	}
}


void UniCoffeeShop::addIngredientToShoppingList(const AuctionWinner& winner)
{

	//1. search for supplier in shopping list - not found = create it
	for (unsigned int i = 0; i < _shoppingListOutput.size(); ++i) {
		if (winner.supplierName == _shoppingListOutput[i].supplierName ){
			//supplier found. now search to see if ingredient already exists
			for (unsigned int j = 0; j < _shoppingListOutput[i].ingredients.size(); ++j) {
				if (_shoppingListOutput[i].ingredients[j] == winner.ingridientName)
				{
					//ingredient exists - nothing to do
					return;
				}
			}
			//handle supplier found but ingredient isnt
			_shoppingListOutput[i].ingredients.push_back(winner.ingridientName);
			return;
		}
	}

	//handle supplier not found
	ShoppingListItem shoppingListItem;
	shoppingListItem.supplierName = winner.supplierName;
	shoppingListItem.ingredients.push_back(winner.ingridientName);
	_shoppingListOutput.push_back(shoppingListItem);

}


AuctionWinner UniCoffeeShop::getAuctionWinner(const string& ingredient) const
{
	//Creating an empty AuctionWinner
    AuctionWinner winner;
    winner.ingridientName = ingredient;

    //Finding the best price in the suppliers list
    for (unsigned int i = 0; i < _suppliersInput.size(); ++i) {
            if (ingredient == _suppliersInput[i][1])
            {
                    double currentPrice = atof(_suppliersInput[i][2].c_str());
                    //if empty or lower than lowest price yet
                    if (winner.supplierName == "" || currentPrice < winner.winningPrice)
                    {
                            winner.supplierName	= _suppliersInput[i][0];
                            winner.winningPrice	= currentPrice;
                    }
            }
    }
    return winner;
}

void UniCoffeeShop::processData() {
	/* going throught Products, finding lowest price for all it's ingredients
	 * if the final price (that calculatePrice() returns) fits the demands:
	 * 1. add the product to the menu output
	 * 2. add the supplier to the shopping list
	 */

	//iterate over the input products
	for (unsigned int i = 0; i < _productsInput.size(); ++i) {
		vector< AuctionWinner > container;
		double priceSum=0;
		bool noAuctionWinner = false;

		//iterate over the product's ingredients
		for (unsigned int j = 1; !noAuctionWinner && j < _productsInput[i].size(); ++j) {
			AuctionWinner winner = getAuctionWinner(_productsInput[i][j]);
			if (winner.supplierName == "") //no supplier for this ingredient
			{
				noAuctionWinner = true;
				break;
			}
			container.push_back(winner);
			priceSum += winner.winningPrice;
		}

		//if we found best prices for all ingredients:
		if (!noAuctionWinner){
			double priceWithFees = calculatePrice(priceSum); //calculating price (with labor and profit)
			if (priceWithFees <= 5){
				//1. create menuItem and add to the menuList
				MenuItem menuItem;
				menuItem.itemName 	= _productsInput[i][0];
				menuItem.itemPrice 	= priceWithFees;
				_menuOutput.push_back(menuItem);

				//iterate over winners and create and add the winners to the shoppinglist
				for (unsigned int k = 0; k < container.size(); ++k) {
					addIngredientToShoppingList(container[k]);
				}

			}
		}

	}

}

double UniCoffeeShop::calculatePrice(double priceBeforeFee){

	return (priceBeforeFee+1)*1.5;
}




void UniCoffeeShop::printOutput(bool debug) const
{
    string outputStrA;

     for (unsigned int i = 0; i < _menuOutput.size(); ++i) {
             char priceStr[10];
             sprintf(priceStr,"%.2f", _menuOutput[i].itemPrice);
             outputStrA += _menuOutput[i].itemName +"," + priceStr + "\n";
     }

     if (outputStrA.size() > 0) outputStrA.erase(outputStrA.size()-1);     //deleting the last \n

     string outputStrB;

     for (unsigned int i = 0; i < _shoppingListOutput.size(); ++i) {
             outputStrB += _shoppingListOutput[i].supplierName + ",";
             for (unsigned int j = 0; j < _shoppingListOutput[i].ingredients.size(); ++j) {
                     outputStrB += _shoppingListOutput[i].ingredients[j] + ",";
             }
             if (outputStrB.size() > 0) outputStrB.erase(outputStrB.size()-1);
             outputStrB += '\n';
     }

     if (outputStrB.size() > 0) outputStrB.erase(outputStrB.size()-1); //deleting the last \n


     writeToFile(string("Menu.out"), 			outputStrA);
     writeToFile(string("ShoppingList.out"), 	outputStrB);

     if(debug){
         cout<< "Menu:\n" + outputStrA + "\nShoppingList:\n" + outputStrB << endl;
     }
}

UniCoffeeShop::UniCoffeeShop(): _productsInput(),_suppliersInput(),_menuOutput(),_shoppingListOutput() {}

void UniCoffeeShop::start() {
	readFromFile("Products.conf",this->_productsInput);
	readFromFile("Suppliers.conf",this->_suppliersInput);
	processData();
	printOutput(false);
}

ProductPrice UniCoffeeShop::getProductPrice(const string& product_name) const {
	ProductPrice prod;
	return prod;
}

bool UniCoffeeShop::updateSupplierIngredient(const string& supplier_name,
		const string& ingredient_name, double price_to_update) {
}





