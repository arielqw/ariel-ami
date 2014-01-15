import java.io.BufferedReader;


public class ListenerThread implements Runnable
{
	
	public ListenerThread(BufferedReader in)
	{
		_in = in;
	}

	private BufferedReader _in;
	
	@Override
	public void run()
	{
		while(true)
		{
			try
			{
				System.out.println(_in.readLine());
			} catch (Exception e)
			{
				// TODO Auto-generated catch block
				System.exit(1);
				e.printStackTrace();
			}
		}

	}

}
