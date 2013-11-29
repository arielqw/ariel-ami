# All Targets
all: SimUniCoffeeShop

# Tool invocations
#	AppLogger.o      imageoperations.o  MenuItem.o           Suppliers.o
#	CoffeeManager.o  ImgTools.o         MenuItems.o          UniCoffeeShop.o
#	Customer.o       Ingredient.o       RegularCustomer.o    VipCustomer.o
#	Customers.o      Ingredients.o      SellingIngredient.o
#	imageloader.o    Main.o             Supplier.o


SimUniCoffeeShop: bin/Main.o bin/AppLogger.o bin/imageoperations.o bin/MenuItem.o bin/Suppliers.o bin/CoffeeManager.o bin/ImgTools.o bin/MenuItems.o bin/UniCoffeeShop.o bin/Customer.o bin/Ingredient.o bin/RegularCustomer.o bin/VipCustomer.o bin/Customers.o bin/Ingredients.o bin/SellingIngredient.o bin/imageloader.o bin/Supplier.o

	@echo 'Building target: SimUniCoffeeShop...'
	@echo 'Invoking: C++ Linker...'
	
	g++ -o "bin/sim_coffee_shop" bin/MenuItems.o bin/UniCoffeeShop.o bin/Customer.o  bin/Ingredient.o bin/RegularCustomer.o bin/VipCustomer.o bin/Customers.o bin/Ingredients.o bin/SellingIngredient.o bin/Suppliers.o bin/Supplier.o bin/MenuItem.o bin/CoffeeManager.o bin/Main.o	bin/ImgTools.o bin/imageoperations.o bin/imageloader.o bin/AppLogger.o -L/usr/local/lib -L/usr/lib -lPocoFoundation -lPocoUtil -lopencv_objdetect -lopencv_core -lopencv_imgproc -lopencv_highgui
	
	@echo 'Finished building target: SimUniCoffeeShop'
	@echo ' '

# Depends on the source and header files
bin/AppLogger.o: src/AppLogger.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/AppLogger.o src/AppLogger.cpp

# Depends on the source and header files
bin/CoffeeManager.o: src/CoffeeManager.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/CoffeeManager.o src/CoffeeManager.cpp
	
# Depends on the source and header files
bin/Customer.o: src/Customer.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Customer.o src/Customer.cpp

# Depends on the source and header files 
bin/Customers.o: src/Customers.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Customers.o src/Customers.cpp

# Depends on the source and header files
bin/imageloader.o: src/imageloader.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/imageloader.o src/imageloader.cpp
	
# Depends on the source and header files
bin/imageoperations.o: src/imageoperations.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/imageoperations.o src/imageoperations.cpp

# Depends on the source and header files
bin/ImgTools.o: src/ImgTools.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/ImgTools.o src/ImgTools.cpp

# Depends on the source and header files
bin/Ingredient.o: src/Ingredient.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Ingredient.o src/Ingredient.cpp
	
# Depends on the source and header files
bin/Ingredients.o: src/Ingredients.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Ingredients.o src/Ingredients.cpp
	
# Depends on the source and header files
bin/Main.o: src/Main.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Main.o src/Main.cpp
	
# Depends on the source and header files
bin/MenuItem.o: src/MenuItem.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/MenuItem.o src/MenuItem.cpp
	
# Depends on the source and header files
bin/MenuItems.o: src/MenuItems.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/MenuItems.o src/MenuItems.cpp
	
# Depends on the source and header files
bin/RegularCustomer.o: src/RegularCustomer.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/RegularCustomer.o src/RegularCustomer.cpp
	
# Depends on the source and header files
bin/SellingIngredient.o: src/SellingIngredient.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/SellingIngredient.o src/SellingIngredient.cpp
		
# Depends on the source and header files
bin/Supplier.o: src/Supplier.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Supplier.o src/Supplier.cpp
		
# Depends on the source and header files
bin/Suppliers.o: src/Suppliers.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/Suppliers.o src/Suppliers.cpp
		
# Depends on the source and header files
bin/UniCoffeeShop.o: src/UniCoffeeShop.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/UniCoffeeShop.o src/UniCoffeeShop.cpp
		
# Depends on the source and header files
bin/VipCustomer.o: src/VipCustomer.cpp
	g++ -g -Wall -Weffc++ -c -I/usr/local/include -Iinclude -o bin/VipCustomer.o src/VipCustomer.cpp
		

#Clean the build directory
clean: 
	@echo 'Cleaning Project Files...'
	rm -f bin/*