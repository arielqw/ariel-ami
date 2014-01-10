import java.io.IOException;
import java.net.Socket;
import encoding.Encoder;
 
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
        while (!_protocol.shouldClose() && !_socket.isClosed()) {                          
            try {
                if (!_tokenizer.isAlive())
                    _protocol.connectionTerminated();
                else {
                    String msg = _tokenizer.nextToken();
                    String ans = _protocol.processMessage(msg);
                    if (ans != null) {
                        byte[] buf = _encoder.toBytes(ans);
                        _socket.getOutputStream().write(buf, 0, buf.length);
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
        System.out.println("thread done");
    }
}