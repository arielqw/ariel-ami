################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/Client.cpp \
../src/ConnectFrame.cpp \
../src/DisconnectFrame.cpp \
../src/Main.cpp \
../src/Protocol.cpp \
../src/SendFrame.cpp \
../src/StompFrame.cpp \
../src/SubscribeFrame.cpp \
../src/UserInputHandler.cpp \
../src/connectionHandler.cpp 

OBJS += \
./src/Client.o \
./src/ConnectFrame.o \
./src/DisconnectFrame.o \
./src/Main.o \
./src/Protocol.o \
./src/SendFrame.o \
./src/StompFrame.o \
./src/SubscribeFrame.o \
./src/UserInputHandler.o \
./src/connectionHandler.o 

CPP_DEPS += \
./src/Client.d \
./src/ConnectFrame.d \
./src/DisconnectFrame.d \
./src/Main.d \
./src/Protocol.d \
./src/SendFrame.d \
./src/StompFrame.d \
./src/SubscribeFrame.d \
./src/UserInputHandler.d \
./src/connectionHandler.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


