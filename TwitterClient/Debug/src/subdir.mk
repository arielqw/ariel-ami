################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/ConnectFrame.cpp \
../src/DisconnectFrame.cpp \
../src/SendFrame.cpp \
../src/StompClient.cpp \
../src/StompFrame.cpp \
../src/UserInputHandler.cpp \
../src/connectionHandler.cpp 

OBJS += \
./src/ConnectFrame.o \
./src/DisconnectFrame.o \
./src/SendFrame.o \
./src/StompClient.o \
./src/StompFrame.o \
./src/UserInputHandler.o \
./src/connectionHandler.o 

CPP_DEPS += \
./src/ConnectFrame.d \
./src/DisconnectFrame.d \
./src/SendFrame.d \
./src/StompClient.d \
./src/StompFrame.d \
./src/UserInputHandler.d \
./src/connectionHandler.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


