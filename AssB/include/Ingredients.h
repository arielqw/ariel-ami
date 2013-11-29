/*
 * Ingredients.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef INGREDIENTS_H_
#define INGREDIENTS_H_
#include "Ingredient.h"
#include <vector>

/*
 * this class holds all the ingredients that are known by the coffeeshop
 */
class Ingredients {
private:
	vector < Ingredient* > m_ingredients;
public:
	Ingredients();
	virtual ~Ingredients();

	Ingredient* getIngredient(const string& ingredient_name);
	void update();
	void print() const;
};

#endif /* INGREDIENTS_H_ */
