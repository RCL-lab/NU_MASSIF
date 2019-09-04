package gc;

import java.io.IOException;
import java.util.Arrays;

import network.Network;
import ot.FakeOTReceiver;
import ot.OTExtReceiver;
import ot.OTPreprocessReceiver;
import ot.OTReceiver;
import flexsc.Flag;
import flexsc.Mode;
import flexsc.Party;

public abstract class GCEvaComp extends GCCompEnv{

	static private boolean GcEvaComp_DEBUG = false;
	OTReceiver rcv;

	protected long gid = 0;

	public GCEvaComp(Network channel, Mode mode) {
		super(channel, Party.Bob, mode);

		if (Flag.FakeOT)
			rcv = new FakeOTReceiver(channel);
		else if (Flag.ProprocessOT)
			rcv = new OTPreprocessReceiver(channel);
		else
			rcv = new OTExtReceiver(channel);

	}

	public GCSignal inputOfAlice(boolean in) {
		Flag.sw.startOT();
		GCSignal signal = GCSignal.receive(channel);
		Flag.sw.stopOT();
		return signal;
	}

	public GCSignal inputOfBob(boolean in) {
		Flag.sw.startOT();
		GCSignal signal = null;
		try {
			signal = rcv.receive(in);
		} catch (IOException e) {
			e.printStackTrace();
		}
		Flag.sw.stopOT();
		return signal;
	}

	public GCSignal[] inputOfBob(boolean[] x) {
		GCSignal[] ret = new GCSignal[x.length];
		for(int i = 0; i < x.length; i+=Flag.OTBlockSize) {
			GCSignal[] tmp = inputOfBobInter(Arrays.copyOfRange(x, i, Math.min(i+Flag.OTBlockSize, x.length)));
			System.arraycopy(tmp, 0, ret, i, tmp.length);
		}

		if(GcEvaComp_DEBUG){	
		//System.out.println("=============EVA=ARR===============");
		//System.out.println("Input OF Bob :");
		for (int i = 0; i < ret.length; ++i) {
			System.out.println("EVA Inputs Bob bytes: "+ ret[i].toHexStr() + "\n");
			System.out.println("EVA Inputs Bob t/f: "+ ret[i].v + "\n");
			System.out.println("EVA Inputs Bob bool t/f: "+ x[i] + "\n");	
		} 
		//System.out.println("=============EVA=ARR==============");
		}
		return ret;
		
	}

	public GCSignal[] inputOfBobInter(boolean[] x) {
		Flag.sw.startOT();
		GCSignal[] signal = null;
		try {
			signal = rcv.receive(x);
		} catch (IOException e) {
			e.printStackTrace();
		}
		Flag.sw.stopOT();
		
/**
		if(GcEvaComp_DEBUG){	
		//System.out.println("=============EVA=BOBINT===============");
		//System.out.println("Input OF Bob :");
		for (int i = 0; i < x.length; ++i) {
			System.out.println("Inputs: "+ x[i]);	
		} 
		System.out.println("=============EVA=BOBINT==============");
		System.out.println("signal:" + signal[0].v + " with length " +  x.length );
		System.out.println("=============EVA=BOBINT==============");
		}
**/
		return signal;
	}

	public GCSignal[] inputOfAlice(boolean[] x) {
		Flag.sw.startOT();
		GCSignal[] result = new GCSignal[x.length];
		for (int i = 0; i < x.length; ++i)
			result[i] = GCSignal.receive(channel);
		Flag.sw.stopOT();
		
		if(GcEvaComp_DEBUG){		
		//System.out.println("=============EVA=ARR===============");
		//System.out.println("Eva Input OF Alice :");
		for (int i = 0; i < result.length; ++i) {
			System.out.println("Eva Inputs Alice bytes: "+ result[i].toHexStr() + "\n");
			System.out.println("Eva Inputs Alice t/f: "+ result[i].v + "\n");	
			System.out.println("EVA Inputs Alice bool t/f: "+ x[i] + "\n");
		} 
		//System.out.println("=============EVA=ARR==============");
		}

		return result;
	}

	public boolean outputToAlice(GCSignal out) {
		//debug		
		System.out.println("=============EVAOUT==================");
		System.out.println("Output to Alice: " + out.v);		
		System.out.println("=============EVAOUT==================");
		if (!out.isPublic())
			out.send(channel);
		return false;
	}

	public boolean outputToBob(GCSignal out) {
		if (out.isPublic())
			return out.v;

		GCSignal lb = GCSignal.receive(channel);
		if (lb.equals(out))
			return false;
		else
			return true;
	}

	public boolean[] outputToAlice(GCSignal[] out) {
		boolean[] result = new boolean[out.length];
		for (int i = 0; i < result.length; ++i) {
			if (!out[i].isPublic())
				out[i].send(channel);
		}

		channel.flush();		

		for (int i = 0; i < result.length; ++i)
			result[i] = false;
		return result;
	}

	public boolean[] outputToBob(GCSignal[] out) {
		boolean[] result = new boolean[out.length];
		for (int i = 0; i < result.length; ++i) {
			result[i] = outputToBob(out[i]);
		}
		return result;
	}

	public GCSignal xor(GCSignal a, GCSignal b) {
		//debug
		//----------------------------------------------------------
		//System.out.println("********EVAXOR**************");
		//System.out.println("XOR :");
		//System.out.println("a.v: \t" + a.v + "\t b.v: \t" + b.v);
		//System.out.println("a.v public?: \t" + a.isPublic() + "\t b.v public?: \t" + b.isPublic());
		//System.out.println("a.bytes?: \t" + a.toHexStr());
		//------------------------------------------------------------
		//GCSignal ret = new GCSignal(true);

		if (a.isPublic() && b.isPublic())
			return  ((a.v ^ b.v) ? new GCSignal(true):new GCSignal(false));
		else if (a.isPublic()){
			return a.v ? not(b) : b;}
		else if (b.isPublic()) {
			return b.v ? not(a) : a; }
		else	{
			return a.xor(b);}
	}

	public GCSignal not(GCSignal a) {
		if (a.isPublic())
			return ((!a.v) ?new GCSignal(true):new GCSignal(false));
		else {
			return a;
		}
	}
}
