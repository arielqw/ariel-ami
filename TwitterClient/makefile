
RM := rm -rf

# All of the sources participating in the build are defined here

USER_OBJS :=

LIBS := -lboost_thread -lPocoFoundation -lPocoUtil -lboost_system -lboost_iostreams -lpthread

CPP_SRCS += \
../src/protocols/STOMP/frames/ConnectFrame.cpp \
../src/protocols/STOMP/frames/DisconnectFrame.cpp \
../src/protocols/STOMP/frames/MessageFrame.cpp \
../src/protocols/STOMP/frames/SendFrame.cpp \
../src/protocols/STOMP/frames/StompFrame.cpp \
../src/protocols/STOMP/frames/SubscribeFrame.cpp \
../src/protocols/STOMP/frames/UnsubscribeFrame.cpp 

OBJS += \
./src/protocols/STOMP/frames/ConnectFrame.o \
./src/protocols/STOMP/frames/DisconnectFrame.o \
./src/protocols/STOMP/frames/MessageFrame.o \
./src/protocols/STOMP/frames/SendFrame.o \
./src/protocols/STOMP/frames/StompFrame.o \
./src/protocols/STOMP/frames/SubscribeFrame.o \
./src/protocols/STOMP/frames/UnsubscribeFrame.o 

CPP_DEPS += \
./src/protocols/STOMP/frames/ConnectFrame.d \
./src/protocols/STOMP/frames/DisconnectFrame.d \
./src/protocols/STOMP/frames/MessageFrame.d \
./src/protocols/STOMP/frames/SendFrame.d \
./src/protocols/STOMP/frames/StompFrame.d \
./src/protocols/STOMP/frames/SubscribeFrame.d \
./src/protocols/STOMP/frames/UnsubscribeFrame.d 


# Each subdirectory must supply rules for building sources it contributes
src/protocols/STOMP/frames/%.o: ../src/protocols/STOMP/frames/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -Weffc++ -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '-include src/protocols/STOMP/subdir.mk
	
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

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/protocols/STOMP/StompProtocol.cpp \
../src/protocols/STOMP/TweeterProtocol.cpp 

OBJS += \
./src/protocols/STOMP/StompProtocol.o \
./src/protocols/STOMP/TweeterProtocol.o 

CPP_DEPS += \
./src/protocols/STOMP/StompProtocol.d \
./src/protocols/STOMP/TweeterProtocol.d 


# Each subdirectory must supply rules for building sources it contributes
src/protocols/STOMP/%.o: ../src/protocols/STOMP/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -Weffc++ -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/include -O0 -g3 -Wall -Weffc++ -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: makedir TwitterClient

makedir:
	mkdir -p bin

# Tool invocations
TwitterClient: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	g++ -L/usr/lib -L/usr/local/lib -o "bin/TwitterClient" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	-$(RM) $(OBJS)$(C++_DEPS)$(C_DEPS)$(CC_DEPS)$(CPP_DEPS)$(EXECUTABLES)$(CXX_DEPS)$(C_UPPER_DEPS)

# Other Targets
clean:
	-$(RM) $(OBJS)$(C++_DEPS)$(C_DEPS)$(CC_DEPS)$(CPP_DEPS)$(EXECUTABLES)$(CXX_DEPS)$(C_UPPER_DEPS) bin/TwitterClient
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

