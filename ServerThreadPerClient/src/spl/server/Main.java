package spl.server;

public class Main{
	public static void main(String[] args) {

        if (args.length != 1) {
            System.err.println("please supply only one argument, the port to bind.");
            return;
        }
        Server server = new Server(Integer.parseInt(args[0]));
        try {
			server.start();
		} catch (Exception e) {
			
		}
    }	
}

