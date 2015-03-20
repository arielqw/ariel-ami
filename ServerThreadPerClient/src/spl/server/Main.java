package spl.server;

import spl.util.MyLogger;

public class Main{
	public static void main(String[] args) {

        if (args.length != 1) {
            System.err.println("Usage: server <port>");
            return;
        }
		new MyLogger().setup();

		int port = Integer.parseInt(args[0]);
		
		//Initialize server
        Server server = new Server(port);
		server.start();
    }	
}

