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
 
public class Server {
	private int _port;
	private UsersDatabase _usersDatabase;
	private TopicsDatabase _entriesDatabase;
	private boolean _shutdown;
	private ServerSocket _socketAcceptor;
	public Server(int port) {
		_port =port;
		_usersDatabase = new UsersDatabase();
		_entriesDatabase = new TopicsDatabase(_usersDatabase);
		_shutdown = false;
	}
	
	public void start() throws NumberFormatException, IOException{
		System.out.println("[server started]\n");
	    /*The characteristic of the server concurrency model is determined by the selected implementation for the scm 
	    instance (SingleThread, ThreadPerClient or ThreadPool - as described in the next sections)*/
	    ServerConcurrencyModel scm = new ThreadPerClient();  
	    Encoder encoder = new StringEncoder("UTF-8");
	    _socketAcceptor = new ServerSocket(_port);
	    while (!_shutdown) {
	        Socket clientSocket = _socketAcceptor.accept();
	        System.out.println("[client accepted="+clientSocket.getInetAddress()+"]");
	        Tokenizer tokenizer = new StompTokenizer(new InputStreamReader(clientSocket.getInputStream(),encoder.getCharset()),'\u0000');
	        MessagingProtocol protocol = new StompProtocol(_usersDatabase,_entriesDatabase,this);
	        Runnable connectionHandler = new ConnectionHandler(clientSocket, encoder, tokenizer, protocol);
	        scm.apply(connectionHandler);
	    }		

	}
	public void shutdown(){
		System.out.println("[server shutdown]");
		_shutdown = true;
		try {
			_socketAcceptor.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
 
}