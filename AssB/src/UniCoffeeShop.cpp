
#include "UniCoffeeShop.h"

UniCoffeeShop::UniCoffeeShop():_menuItems(), _suppliers(), _ingredients(){

}


void UniCoffeeShop::processProducts(const vector<vector<string> >& productsInput) {
	//going through the input file , creating products , ingridients, and linking.
	for (unsigned int i = 0; i < productsInput.size(); ++i) {
		MenuItem* tmp_menuItem = _menuItems.getMenuItem(productsInput[i][0]); //adding product

		//adding ingredients
		for (unsigned int j = 1; j < productsInput[i].size(); ++j) {
			Ingredient* tmp_ingrident = _ingredients.getIngredient(productsInput[i][j]); //referense to ingredient
			tmp_menuItem->addIngridient(tmp_ingrident); //add ingredient to menuItem
			tmp_ingrident->addMenuItem(tmp_menuItem);
		}
	}
}

void UniCoffeeShop::processSuppliers(const vector<vector<string> >& suppliersInput) {
	//going through the input file , creating products , ingridients, and linking.
	for (unsigned int i = 0; i < suppliersInput.size(); ++i) {
		Supplier* tmp_supplier = _suppliers.getSupplier(suppliersInput[i][0]); //get ref to supplier (create if needed)
		Ingredient* tmp_ingredient = _ingredients.getIngredient(suppliersInput[i][1]); //get ref to ing
		tmp_ingredient->addSupplier(tmp_supplier); //add supplier to ingredient
		tmp_supplier->addIngredient( tmp_ingredient, atof(suppliersInput[i][2].c_str()) ); //add ing and price to supplier
	}
}

UniCoffeeShop::~UniCoffeeShop() {
}

void UniCoffeeShop::start(vector< vector<string> >& productsInput,vector< vector<string> >& suppliersInput) {
	processProducts(productsInput);
	processSuppliers(suppliersInput);

	_ingredients.update(); //get best price for each ingredient
	_menuItems.update(); //calculate products prices & decide if on menu


	_suppliers.print();
	_menuItems.print();
	_ingredients.print();

}

int UniCoffeeShop::updateSupplierIngredient(const string& supplier_name, const string& ingredient_name, const string& price) {

	Supplier* supplier = _suppliers.getSupplier(supplier_name);
	Ingredient* changeIngredient = _ingredients.getIngredient(ingredient_name);

	double ingredientBestPrice_before = changeIngredient->getPrice();
	supplier->updateIngredient(ingredient_name,atof(price.c_str())); //change ingredient price at supplier
	changeIngredient->pickBestSupplier();
	double ingredientBestPrice_after = changeIngredient->getPrice();

	//updates the menu if needed
	if(ingredientBestPrice_before != ingredientBestPrice_after ){
		return changeIngredient->updateMyMenuItems();
	}
	return 0;

}

MenuItem* UniCoffeeShop::getProductPrice(const string& product_name) {
	MenuItem* selectedProduct = _menuItems.getMenuItem(product_name);
	return selectedProduct;
}







