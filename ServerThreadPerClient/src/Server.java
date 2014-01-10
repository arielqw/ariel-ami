import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import encoding.Encoder;
import encoding.StringEncoder;

 
class Server {
    public static void main(String[] args) 
        throws NumberFormatException, IOException 
    {
        if (args.length != 1) {
            System.err.println("please supply only one argument, the port to bind.");
            return;
        }
        /*The characteristic of the server concurrency model is determined by the selected implementation for the scm 
        instance (SingleThread, ThreadPerClient or ThreadPool - as described in the next sections)*/
        ServerConcurrencyModel scm = new ThreadPerClient();  
        Encoder encoder = new StringEncoder("UTF-8");
        ServerSocket socketAcceptor = new ServerSocket(Integer.parseInt(args[0]));
        while (true) {
            Socket clientSocket = socketAcceptor.accept();
            System.out.println("client accepted!");
            Tokenizer tokenizer = new StompTokenizer(new InputStreamReader(clientSocket.getInputStream(),encoder.getCharset()),'\u0000');
            MessagingProtocol protocol = new StompProtocol();
            Runnable connectionHandler = new ConnectionHandler(clientSocket, encoder, tokenizer, protocol);
            scm.apply(connectionHandler);
        }
    }
}