################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/encoder/encoder.cpp 

OBJS += \
./src/encoder/encoder.o 

CPP_DEPS += \
./src/encoder/encoder.d 


# Each subdirectory must supply rules for building sources it contributes
src/encoder/%.o: ../src/encoder/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


