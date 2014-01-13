package spl.server;

/**
 * opening a new thread per client connection model
 *
 */
class ThreadPerClient implements ServerConcurrencyModel {
   public void apply (Runnable connectionHandler) {
      new Thread(connectionHandler).start(); // NOTE HERE: Each connection handler runs in a different thread
   }
}