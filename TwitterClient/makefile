TEMP=Main AppLogger Client connectionHandler Protocol Utility protocols/STOMP/StompProtocol protocols/STOMP/TweeterProtocol protocols/STOMP/frames/ConnectFrame protocols/STOMP/frames/DisconnectFrame protocols/STOMP/frames/MessageFrame protocols/STOMP/frames/SendFrame protocols/STOMP/frames/StompFrame protocols/STOMP/frames/SubscribeFrame protocols/STOMP/frames/UnsubscribeFrame
SOURCES:=src/$(TEMP).cpp
OBJECTS:=bin/$(TEMP).o

LIB_FOLDERS=-L/usr/local/lib -L/usr/lib
LIBS=-lPocoFoundation -lPocoUtil -lopencv_objdetect -lopencv_core -lopencv_imgproc -lopencv_highgui

INCLUDES=-I/usr/local/include -I/usr/include -Iinclude

# All Targets
all: makedirs TweeterClient

makedirs:
	mkdir -p bin/protocols/STOMP/frames

TweeterClient: $(OBJECTS)

	@echo 'Building target: TweeterClient...'
	@echo 'Invoking: C++ Linker...'
	
#	mkdir -p bin
#	mkdir -p bin/protocols
#	mkdir -p bin/protocols/STOMP
#	mkdir -p bin/protocols/STOMP/frames
	
	
	
	g++ -o "bin/tweeter_client" $(OBJECTS) $(LIB_FOLDERS) $(LIBS)
	
	@echo 'Finished building target: TweeterClient'
	@echo ' '
	
	
bin/%.o: src/%.cpp
	@echo compiling $@
	g++ -g -Wall -Weffc++ -c $(INCLUDES) -o $@ $<


#Clean the build directory
clean: 
	@echo 'Cleaning Project Files...'
	rm -f bin/*