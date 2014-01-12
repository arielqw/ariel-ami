TEMP=Main AppLogger Client connectionHandler Protocol Utility protocol/STOMP/StompProtocol protocol/STOMP/TweeterProtocol protocol/STOMP/frames/ConnectFrame protocol/STOMP/frames/DisconnectFrame protocol/STOMP/frames/MessageFrame protocol/STOMP/frames/SendFrame protocol/STOMP/frames/StompFrame protocol/STOMP/frames/SubscribeFrame protocol/STOMP/frames/UnsubscribeFrame
SOURCES:=src/$(TEMP).cpp
OBJECTS:=bin/$(TEMP).o

LIB_FOLDERS=-L/usr/local/lib -L/usr/lib
LIBS=-lPocoFoundation -lPocoUtil -lopencv_objdetect -lopencv_core -lopencv_imgproc -lopencv_highgui

INCLUDES=-I/usr/local/include I/usr/include -Iinclude

# All Targets
all: TweeterClient


TweeterClient: $(OBJECTS)

	@echo 'Building target: TweeterClient...'
	@echo 'Invoking: C++ Linker...'
	
	g++ -o "bin/tweeter_client" $(OBJECTS) $(LIB_FOLDERS) $(LIBS)
	
	@echo 'Finished building target: TweeterClient'
	@echo ' '
	

bin/%.o: src/%.cpp
	g++ -g -Wall -Weffc++ -c $(INCLUDES) -o $@ $<


#Clean the build directory
clean: 
	@echo 'Cleaning Project Files...'
	rm -f bin/*