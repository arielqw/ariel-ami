################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/AppLogger.cpp \
../src/Client.cpp \
../src/Main.cpp \
../src/Protocol.cpp \
../src/Utility.cpp \
../src/connectionHandler.cpp 

OBJS += \
./src/AppLogger.o \
./src/Client.o \
./src/Main.o \
./src/Protocol.o \
./src/Utility.o \
./src/connectionHandler.o 

CPP_DEPS += \
./src/AppLogger.d \
./src/Client.d \
./src/Main.d \
./src/Protocol.d \
./src/Utility.d \
./src/connectionHandler.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


