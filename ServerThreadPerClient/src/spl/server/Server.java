package spl.server;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Inet4Address;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.logging.Logger;

import spl.server.encoding.Encoder;
import spl.server.encoding.StringEncoder;
import spl.server.protocols.stomp.StompProtocol;
import spl.server.protocols.stomp.StompTokenizer;
 
/**
 * this class represents a Tweeter server
 *
 */
public class Server {
	private final static Logger LOGGER = Logger.getGlobal();

	private int _port;
	private UsersDatabase _usersDatabase;
	private TopicsDatabase _entriesDatabase;
	private boolean _shutdown;
	private ServerSocket _socketAcceptor;
	private Statistics _statistics;
	

	public Server(int port) {
		_port =port;
		_usersDatabase = new UsersDatabase();
		_entriesDatabase = new TopicsDatabase(_usersDatabase);
		_shutdown = false;
		_statistics = new Statistics(_usersDatabase, _entriesDatabase);
	}
	
	/**
	 * running the server
	 */
	public void start(){
		try {
			init();
		} catch (Exception e) {
			LOGGER.info("[server] [event=server offline]");
		}
	}
	
	/**
	 * Running as thread-per-client model
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	private void init() throws NumberFormatException, IOException{
	    /*The characteristic of the server concurrency model is determined by the selected implementation for the scm 
	    instance (SingleThread, ThreadPerClient or ThreadPool - as described in the next sections)*/
	    
		ServerConcurrencyModel scm = new ThreadPerClient();  
	    String encoding = "UTF-8";
	    Encoder encoder = new StringEncoder(encoding);
	    _socketAcceptor = new ServerSocket(_port);
	    
		LOGGER.info("[server] [event=server online] [protocol='tweeter/STOMP'] [IP address='"+Inet4Address.getLocalHost().getHostAddress()+"'] [port='"+_port+"'] [encoding='"+encoding+"']");
		
		//as long as shutdown wasn't requested
	    while (!_shutdown) {
	        Socket clientSocket = _socketAcceptor.accept(); //waiting to accept new connections 
			LOGGER.info("[server] [event=client accepted] [IP address="+clientSocket.getInetAddress()+"]");
	        
			Tokenizer tokenizer = new StompTokenizer(new InputStreamReader(clientSocket.getInputStream(),encoder.getCharset()),'\u0000');
	        MessagingProtocol protocol = new StompProtocol(_usersDatabase,_entriesDatabase,this,_statistics);
	        Runnable connectionHandler = new ConnectionHandler(clientSocket, encoder, tokenizer, protocol);
	       
	        //handling new connection accepted
	        scm.apply(connectionHandler);
	    }		

	}
	
	/**
	 * shutting down server
	 */
	public void shutdown(){
		_shutdown = true;
		try {
			_socketAcceptor.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
 
}