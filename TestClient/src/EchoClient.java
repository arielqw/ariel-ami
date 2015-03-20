import java.io.*;
import java.net.*;
/**
 * Simple echo client for STOMP assignment
 * Usage:
 * 		1.hard code your lines to strs[]
 * 		2. run with ' client {host} {port} '
 * 		3. press the 'enter' key to send a single STOMP frame 
 * @author arielbaruch , amioren
 *
 */
public class EchoClient {
	
	public static void main(String[] args) throws IOException
	{
		System.out.println("[info] [event=client started] [protocol='STOMP/TCP'] [authors={Ariel Baruch, Ami Oren}']");

		Socket clientSocket = null; // the connection socket
		PrintWriter out = null;
		BufferedReader in = null;

		// Get host and port
		String host = args[0];
		int port = Integer.decode(args[1]).intValue();
		
		System.out.println("[info] [event=connecting] [address=" + host + "] [port=" + port+"]");
		
		// Trying to connect to a socket and initialize an output stream
		try {
			clientSocket = new Socket(host, port); // host and port
      		out = new PrintWriter(clientSocket.getOutputStream(), true);
    	} catch (UnknownHostException e) {
    		System.out.println("[error] [msg=unknown host]");
      		System.exit(1);
	    } catch (IOException e) {
    		System.out.println("[error] [msg=Couldn't get output to " + host + " connection]");
			System.exit(1);
    	}
    	
    	// Initialize an input stream
    	try {
    		in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream(),"UTF-8"));
    	} catch (IOException e) {
    		System.out.println("[error] [msg=Couldn't get output to " + host + " connection]");
			System.exit(1);
    	}
    	
		System.out.println("[info] [event=connected] [address=" + host + "] [port=" + port+"]");
    	
    	new Thread(new ListenerThread(in)).start();
    	
    	BufferedReader userIn = new BufferedReader(new InputStreamReader(System.in,"UTF-8"));
    	
    	/**
    	 * Edit your commands HERE ->
    	 */
    	String[] strs = new String[]{
    		"CONNECT\naccept-version:1.2\nhost:127.0.0.1\nlogin:ariel\npasscode:p455\n\n"+'\u0000', //CONNECT
    		"SEND\ndestination:ariel\n\nhello world\n"+'\u0000', //SEND
    		"DISCONNECT\nreceipt:77\n\n"+'\u0000', //DISCONNECT
    		"CONNECT\naccept-version:1.2\nhost:127.0.0.1\nlogin:ami\npasscode:oren\n\n"+'\u0000', //CONNECT AS OTHER USER
    		"SEND\ndestination:ami\n\nhere with @ariel\n"+'\u0000', //SEND @user
    		"DISCONNECT\nreceipt:99\n\n"+'\u0000', //DISCONNECT
    		"CONNECT\naccept-version:1.2\nhost:127.0.0.1\nlogin:ariel\npasscode:WRONG\n\n"+'\u0000', //CONNECT wrong pw
    		"CONNECT\naccept-version:1.2\nhost:127.0.0.1\nlogin:ariel\npasscode:p455\n\n"+'\u0000', //CONNECT
    		"SUBSCRIBE\ndestination:ami\nid:88\n\n"+'\u0000', //SUBSCRIBE
    		"SUBSCRIBE\ndestination:server\nid:99\n\n"+'\u0000', //FOLLOW SERVER
    		"SEND\ndestination:server\n\nclients\n"+'\u0000', //CLIENTS
    		"SEND\ndestination:server\n\nclients online\n"+'\u0000', //CLIENTS ONLINE
    		"SEND\ndestination:server\n\nstats\n"+'\u0000', //STATS
    		"SEND\ndestination:server\n\nstop\n"+'\u0000', //STOP
    	};
    	
		for (int i = 0; i < strs.length; i++)
		{
			userIn.readLine();
			System.out.println("[SENDING]\n"+strs[i]+"[/SENDING]\n");
			out.print(strs[i]);
			out.flush();
		}
		
		System.out.println("[info] [event=client exit]");
		System.exit(1);

    	// Close all I/O
    	out.close();
    	in.close();
    	userIn.close();
    	clientSocket.close();
    	
    	
	}
}
