public interface MessagingProtocol {
    /**
     * Process a given message.
     * 
     * @return the answer to send back, or null if no answer is required
     */
    String processMessage(String msg);
 
    /**
    * determine whether the given message is the termination message
    * @param msg the message to examine
    * @return true if the message is the termination message, false otherwise
    */
    boolean isEnd(String msg);
 
    /**
     * @return true if the connection should be terminated
     */
    boolean shouldClose();
 
    /**
     * called when the connection was not gracefully shut down.
     */
    void connectionTerminated();
 
}