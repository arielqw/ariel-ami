package spl.server;
import java.io.IOException;
import java.net.Socket;
import spl.server.encoding.Encoder;
 
public class ConnectionHandler implements Runnable {
 
    private final Socket _socket;
    private final Encoder _encoder;
    private final Tokenizer _tokenizer;
    private final MessagingProtocol _protocol;
 
    public ConnectionHandler(Socket s, Encoder encoder, Tokenizer tokenizer, MessagingProtocol protocol) {
        _socket = s;
        _encoder = encoder;
        _tokenizer = tokenizer;
        _protocol= protocol;
    }
 
    public void run() {
    	_protocol.setConnectionHanlder(this);
        while (!_protocol.shouldClose() && !_socket.isClosed()) {                          
            try {
                if (!_tokenizer.isAlive())
                    _protocol.connectionTerminated();
                else {
                    String msg = _tokenizer.nextToken();
                    //System.out.println("[message received start]\n"+msg+"[message end]");
                    boolean shouldDisconnect = _protocol.processMessage(msg);
                    if (shouldDisconnect) {
                    	//TODO:disconnect?
                    }
                    
                }
            } catch (IOException e) {
                _protocol.connectionTerminated();
                break;
            }
        }
        try {
            _socket.close();
        } catch (IOException ignored) {
        }
        System.out.println("[Client is closed]");
    }
    
    public void send(String msg) throws IOException{
        byte[] buf = _encoder.toBytes(msg);
        _socket.getOutputStream().write(buf, 0, buf.length);
    }
}