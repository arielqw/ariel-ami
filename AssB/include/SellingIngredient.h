/*
 * SellingIngredient.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef SELLINGINGREDIENT_H_
#define SELLINGINGREDIENT_H_
#include <string>

#include "Ingredient.h"
#include "MenuItem.h"
using namespace std;

class SellingIngredient {
private:
	SellingIngredient(const SellingIngredient& other);
	SellingIngredient& operator=(const SellingIngredient& other);

	Ingredient* _ingredient;
	double _price;
public:
	SellingIngredient(Ingredient* ingridient);
	virtual ~SellingIngredient();

	string getName();
	double getPrice() const;
	void setPrice(double price);
};

#endif /* SELLINGINGREDIENT_H_ */
