package gc;

import java.io.IOException;
import java.util.Arrays;

import network.Network;
import ot.FakeOTSender;
import ot.OTExtSender;
import ot.OTPreprocessSender;
import ot.OTSender;
import flexsc.CompEnv;
import flexsc.Flag;
import flexsc.Mode;
import flexsc.Party;

public abstract class GCGenComp extends GCCompEnv {

	static private boolean GcGenComp_DEBUG = false;
	static public GCSignal R = null;
	static {
		R = GCSignal.freshLabel(CompEnv.rnd);
		R.setLSB();
	}

	OTSender snd;
	protected long gid = 0;

	public GCGenComp(Network channel, Mode mode) {
		super(channel, Party.Alice, mode);

		if (Flag.FakeOT)
			snd = new FakeOTSender(80, channel);
		else if(Flag.ProprocessOT)
			snd = new OTPreprocessSender(80, channel);
		else
			snd = new OTExtSender(80, channel);
	}

	public static GCSignal[] genPairForLabel(Mode mode) {
		GCSignal[] label = new GCSignal[2];
		if(mode != Mode.OFFLINE || !Flag.offline)
			label[0] = GCSignal.freshLabel(rnd);
		if(mode == Mode.OFFLINE) {
			if(Flag.offline) {
				label[0] = new GCSignal(gc.offline.GCGen.fread.read(10));
			}
			else 
				label[0].send(gc.offline.GCGen.fout);
		}
		label[1] = R.xor(label[0]);
		return label;
	}
	
	public static GCSignal[] genPair() {
		GCSignal[] label = new GCSignal[2];
		label[0] = GCSignal.freshLabel(rnd);
		label[1] = R.xor(label[0]);
		return label;
	}

	public GCSignal inputOfAlice(boolean in) {
		//debug		
		System.out.println("=============GEN==================");
		System.out.println("Input OF Alice:" + in);
		System.out.println("=============GEN==================");
		
		Flag.sw.startOT();
		GCSignal[] label = genPairForLabel(mode);
		Flag.sw.startOTIO();
		label[in ? 1 : 0].send(channel);
		flush();
		Flag.sw.stopOTIO();
		Flag.sw.stopOT();
		return label[0];
	}

	public GCSignal inputOfBob(boolean in) {
		//debug		
		System.out.println("=============GEN==================");
		System.out.println("Input OF Alice:" + in);
		System.out.println("=============GEN==================");
	
		Flag.sw.startOT();
		GCSignal[] label = genPairForLabel(mode);
		try {
			snd.send(label);
		} catch (IOException e) {
			e.printStackTrace();
		}
		Flag.sw.stopOT();
		return label[0];
	}

	public GCSignal[] inputOfAlice(boolean[] x) {
		Flag.sw.startOT();
		GCSignal[][] pairs = new GCSignal[x.length][2];
		GCSignal[] result = new GCSignal[x.length];
		for (int i = 0; i < x.length; ++i) {
			pairs[i] = genPairForLabel(mode);
			result[i] = pairs[i][0];
		}
		Flag.sw.startOTIO();
		for (int i = 0; i < x.length; ++i)
			pairs[i][x[i] ? 1 : 0].send(channel);
		flush();
		Flag.sw.stopOTIO();
		Flag.sw.stopOT();
		
		if(GcGenComp_DEBUG){	
			//System.out.println("=============GEN=ARR===============");
			//System.out.println("GEN Input OF Alice :");
			for (int i = 0; i < x.length; ++i) {
				System.out.println("GEN Inputs Alice Bytes: "+ result[i].toHexStr() + "\n");
				System.out.println("GEN Inputs Alice t/f: "+ result[i].v + "\n");
				System.out.println("GEN Inputs Alice bool t/f: "+ x[i] + "\n");	
			} 
			//System.out.println("=============GEN=ARR==============");
		}

		return result;
	}

	public GCSignal[] inputOfBob(boolean[] x) {
		GCSignal[] ret = new GCSignal[x.length];
		for(int i = 0; i < x.length; i+=Flag.OTBlockSize) {
			GCSignal[] tmp = inputOfBobInter(Arrays.copyOfRange(x, i, Math.min(i+Flag.OTBlockSize, x.length)));
			System.arraycopy(tmp, 0, ret, i, tmp.length);
		}
		
		if(GcGenComp_DEBUG){	
			//System.out.println("=============GEN=ARR===============");
			//System.out.println("GEN Input OF Alice :");
			for (int i = 0; i < x.length; ++i) {
				System.out.println("GEN Inputs Bob Bytes: "+ ret[i].toHexStr() + "\n");
				System.out.println("GEN Inputs Bob t/f: "+ ret[i].v + "\n");
				System.out.println("GEN Inputs Bob bool t/f: "+ x[i] + "\n");		
			} 
			//System.out.println("=============GEN=ARR==============");
		}		

		return ret;
	}
	public GCSignal[] inputOfBobInter(boolean[] x) {
		Flag.sw.startOT();
		GCSignal[][] pair = new GCSignal[x.length][2];
		for (int i = 0; i < x.length; ++i)
			pair[i] = genPairForLabel(mode);
		try {
			snd.send(pair);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		GCSignal[] result = new GCSignal[x.length];
		for (int i = 0; i < x.length; ++i)
			result[i] = pair[i][0];
		Flag.sw.stopOT();
		return result;
	}

	protected boolean gatesRemain = false;

	public boolean outputToAlice(GCSignal out) {
		if(GcGenComp_DEBUG){	
		System.out.println("=============GENOUT==================");
		System.out.println("Output to Alice: " + out.v + "\t"+ out.toHexStr());		
		System.out.println("=============GENOUT==================");
		}

		if (gatesRemain) {
			gatesRemain = false;
			flush();
		}
		
		if (out.isPublic())
			return out.v;

		GCSignal lb = GCSignal.receive(channel);
		
		if(GcGenComp_DEBUG){
		System.out.println("=============RCVOUT==================");
		System.out.println("Output to Alice: " + lb.v + "\t"+ lb.toHexStr());		
		System.out.println("=============RCVOUT==================");
		
		GCSignal my_val = R.xor(out);
		System.out.println("=============CHKOUT==================");
		System.out.println("Output to Alice: " + my_val.v + "\t"+ my_val.toHexStr());		
		System.out.println("=============CHKOUT==================");
		}

		if (lb.equals(out))
			return false;
		else if (lb.equals(R.xor(out)))
			return true;

		try {
			throw new Exception("bad label at final output.");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		//return false;
	}

	public boolean outputToBob(GCSignal out) {
		if (!out.isPublic())
			out.send(channel);
		return false;
	}

	public boolean[] outputToBob(GCSignal[] out) {
		System.out.println("outputToBob size:"+ out.length);
		boolean[] result = new boolean[out.length];

		for (int i = 0; i < result.length; ++i) {
			if (!out[i].isPublic())
				out[i].send(channel);
		}
		flush();

		for (int i = 0; i < result.length; ++i)
			result[i] = false;
		return result;
	}

	public boolean[] outputToAlice(GCSignal[] out) {
		System.out.println("outputToAlice size:"+ out.length);
		boolean[] result = new boolean[out.length];
		for (int i = 0; i < result.length; ++i) {
			result[i] = outputToAlice(out[i]);
		}
		return result;
	}


	public GCSignal xor(GCSignal a, GCSignal b) {
		//debug
		//----------------------------------------------------------
		System.out.println("*********GEN*************");
		System.out.println("XOR :");
		if(!a.isPublic())
			System.out.println("a.bytes: \t" + a.toHexStr());
		if(!b.isPublic())
			System.out.println("b.bytes: \t" + b.toHexStr());
		System.out.println("a.v: \t" + a.v + "\t b.v: \t" + b.v);
		System.out.println("a.v public?: \t" + a.isPublic() + "\t b.v public?: \t" + b.isPublic());
		//------------------------------------------------------------
		Flag.sw.startGCXOR();
		if (a.isPublic() && b.isPublic()){
			//return new GCSignal(a.v ^ b.v);
			GCSignal gs = new GCSignal(a.v ^ b.v);
			Flag.sw.stopGCXOR();
			//System.out.println("gs.v: \t" + gs.v);
			return gs;
		}
		else if (a.isPublic())
			//return a.v ? not(b) : new GCSignal(b);
		{
			if(a.v == true){
				GCSignal gs = not(b);
				Flag.sw.stopGCXOR();
				System.out.println("gs.bytes: \t" + gs.toHexStr());
				return gs;
			}
			else{
				GCSignal gs = new GCSignal(b);
				Flag.sw.stopGCXOR();
				System.out.println("gs.bytes: \t" + gs.toHexStr());
				return gs;
			}
			
		}
		else if (b.isPublic())
			//return b.v ? not(a) : new GCSignal(a);
		{
			if(b.v == true){
				GCSignal gs = not(a);
				Flag.sw.stopGCXOR();
				System.out.println("gs.bytes: \t" + gs.toHexStr());
				return gs;
			}
			else{
				GCSignal gs = new GCSignal(a);
				Flag.sw.stopGCXOR();
				System.out.println("gs.bytes: \t" + gs.toHexStr());
				return gs;
			}
			
		}	
			
		else {
			//return a.xor(b);
			GCSignal gs = a.xor(b);
			Flag.sw.stopGCXOR();
			System.out.println("gs.bytes: \t" + gs.toHexStr());
			//System.out.println("gs.v public?: \t" + gs.isPublic());
			return gs;
		}
	}

	public GCSignal not(GCSignal a) {
		if (a.isPublic())
			return new GCSignal(!a.v);
		else
			return R.xor(a);
	}
}
