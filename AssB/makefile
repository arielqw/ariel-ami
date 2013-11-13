# All Targets
all: UniCoffeeShop

# Tool invocations
# Executable "UniCoffeeShop" depends on the files UniCoffeeShop.o and Main.o.
UniCoffeeShop: bin/UniCoffeeShop.o bin/Main.o
	@echo 'Building target: UniCoffeeShop'
	@echo 'Invoking: C++ Linker'
	g++ -o bin/UniCoffeeShop bin/UniCoffeeShop.o bin/Main.o
	@echo 'Finished building target: UniCoffeeShop'
	@echo ' '

# Depends on the source and header files
bin/UniCoffeeShop.o: src/UniCoffeeShop.cpp
	g++ -g -Wall -Weffc++ -c -Linclude -o bin/UniCoffeeShop.o src/UniCoffeeShop.cpp

# Depends on the source and header files 
bin/Main.o: src/Main.cpp
	g++ -g -Wall -Weffc++ -c -Linclude -o bin/Main.o src/Main.cpp

#Clean the build directory
clean: 
	rm -f bin/*

