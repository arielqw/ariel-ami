package spl.server;
interface ServerConcurrencyModel {
   public void apply (Runnable connectionHandler); 
}