package util;

import java.util.Arrays;

import org.apache.commons.cli.ParseException;

import flexsc.CompEnv;
import flexsc.Flag;
import flexsc.Mode;
import flexsc.Party;

public abstract class GenRunnable<T> extends network.Server implements Runnable {

	Mode m;
	int port;
	protected String[] args;
	public boolean verbose = false;
	public ConfigParser config;
	public void setParameter(ConfigParser  config, String[] args) {
		this.m = Mode.getMode(config.getString("Mode"));
		this.port = config.getInt("Port");
		this.args = args;
		this.config = config;
	}

	public void setParameter(Mode m, int port) {
		this.m = m;
		this.port = port;
	}

	public abstract void prepareInput(CompEnv<T> gen) throws Exception;
	public abstract void secureCompute(CompEnv<T> gen) throws Exception;
	public abstract void prepareOutput(CompEnv<T> gen) throws Exception;

	public void run() {
		try {
			if(verbose)
				System.out.println("connecting");
			listen(port);
			if(verbose)
				System.out.println("connected");
			double s1= System.nanoTime();
			@SuppressWarnings("unchecked")
			CompEnv<T> env = CompEnv.getEnv(m, Party.Alice, this);

			
			prepareInput(env);
			os.flush();
			double s = System.nanoTime();
			//System.out.println("start time is :" + s);
			secureCompute(env);
			//secureCompute(env);
			double e = System.nanoTime();
			//System.out.println("end time is :" + s);
			os.flush();
			prepareOutput(env);
			os.flush();
			disconnect();
			double e1 = System.nanoTime();
			if(verbose) {
				System.out.println("Gen running time:"+(e-s)/1e6 + " ms.");
				System.out.println("env num of ands:" + env.numOfAnds);
				System.out.println("overall :" + (e1-s1)/1e6 + "ms.");
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}


	@SuppressWarnings("rawtypes")
	public static void main(String[] args) throws ParseException, ClassNotFoundException, InstantiationException, IllegalAccessException {
		ConfigParser config = new ConfigParser("Config.conf");

		Class<?> clazz = Class.forName(args[0]+"$Generator");
		GenRunnable run = (GenRunnable) clazz.newInstance();
		run.setParameter(config, Arrays.copyOfRange(args, 1, args.length));
		run.run();
	
		if(Flag.CountTime)
			Flag.sw.print();
	}
}
