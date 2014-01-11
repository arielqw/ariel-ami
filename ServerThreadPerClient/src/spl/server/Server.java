package spl.server;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import spl.server.encoding.*;
import spl.server.protocols.stomp.StompProtocol;
import spl.server.protocols.stomp.StompTokenizer;
 
class Server {
	private int _port;
	private UsersDatabase _usersDatabase;
	private TopicsDatabase _entriesDatabase;
	
	public Server(int port) {
		_port =port;
		_usersDatabase = new UsersDatabase();
		_entriesDatabase = new TopicsDatabase(_usersDatabase);
	}
	
	public void start() throws NumberFormatException, IOException{
		System.out.println("[server started]\n");
	    /*The characteristic of the server concurrency model is determined by the selected implementation for the scm 
	    instance (SingleThread, ThreadPerClient or ThreadPool - as described in the next sections)*/
	    ServerConcurrencyModel scm = new ThreadPerClient();  
	    Encoder encoder = new StringEncoder("UTF-8");
	    ServerSocket socketAcceptor = new ServerSocket(_port);
	    while (true) {
	        Socket clientSocket = socketAcceptor.accept();
	        System.out.println("[client accepted="+clientSocket.getInetAddress()+"]");
	        Tokenizer tokenizer = new StompTokenizer(new InputStreamReader(clientSocket.getInputStream(),encoder.getCharset()),'\u0000');
	      //  Tokenizer tokenizer = new StompTokenizer(new InputStreamReader(clientSocket.getInputStream(),encoder.getCharset()),'*');
	        MessagingProtocol protocol = new StompProtocol(_usersDatabase,_entriesDatabase);
	        Runnable connectionHandler = new ConnectionHandler(clientSocket, encoder, tokenizer, protocol);
	        scm.apply(connectionHandler);
	    }		
	}
	
 
}