package gc.regular;

import flexsc.Flag;
import flexsc.Mode;
import gc.GCGenComp;
import gc.GCSignal;
import network.Network;

public class GCGen extends GCGenComp {
	Garbler gb;

	public GCGen(Network channel) {
		super(channel, Mode.REAL);
		gb = new Garbler();
		for(int i = 0; i < 2; ++i) {
			labelL[i] = new GCSignal(new byte[10]);
			labelR[i] = new GCSignal(new byte[10]);
			lb[i] = new GCSignal(new byte[10]);
			toSend[0][i] = new GCSignal(new byte[10]);
			toSend[1][i] = new GCSignal(new byte[10]);
		}
	}

	private GCSignal[][] gtt = new GCSignal[2][2];
	private GCSignal[][] toSend = new GCSignal[2][2];
	private GCSignal labelL[] = new GCSignal[2];
	private GCSignal labelR[] = new GCSignal[2];
	private GCSignal[] lb = new GCSignal[2];

	private GCSignal garble(GCSignal a, GCSignal b) {
		labelL[0] = a;
		GCSignal.xor(R, labelL[0], labelL[1]);
		labelR[0] = b;
		GCSignal.xor(R, labelR[0], labelR[1]);

		int cL = a.getLSB();
		int cR = b.getLSB();
		
		//debug
		System.out.println("********GARBLER**************");
		System.out.println("AND :");
		System.out.println("R :\t" +R.toHexStr() + "\t");
		System.out.println("L[0] :\t" +labelL[0].toHexStr() + "\t L[1] :\t" + labelL[1].toHexStr());
		System.out.println("R[0] :\t" +labelR[0].toHexStr() + "\t R[1] :\t" + labelR[1].toHexStr());
		//System.out.println("CL :\t" +cL + "\t CR :\t" + cR);

		gb.enc(labelL[cL], labelR[cR], gid, GCSignal.ZERO, lb[cL & cR]);
		GCSignal.xor(R, lb[cL & cR], lb[1 - (cL & cR)]);
		
		//System.out.println("lb[0] :\t" +lb[0].toHexStr() + "\t lb[1] :\t" + lb[1].toHexStr());
		//System.out.println("=======================================================================");

		gtt[0 ^ cL][0 ^ cR] = lb[0];
		gtt[0 ^ cL][1 ^ cR] = lb[0];
		gtt[1 ^ cL][0 ^ cR] = lb[0];
		gtt[1 ^ cL][1 ^ cR] = lb[1];

		if (cL != 0 || cR != 0)
			gb.enc(labelL[0], labelR[0], gid,
					gtt[0 ^ cL][0 ^ cR], toSend[0 ^ cL][0 ^ cR]);
		if (cL != 0 || cR != 1)
			gb.enc(labelL[0], labelR[1], gid,
					gtt[0 ^ cL][1 ^ cR], toSend[0 ^ cL][1 ^ cR]);
		if (cL != 1 || cR != 0)
			gb.enc(labelL[1], labelR[0], gid,
					gtt[1 ^ cL][0 ^ cR], toSend[1 ^ cL][0 ^ cR]);
		if (cL != 1 || cR != 1)
			gb.enc(labelL[1], labelR[1], gid,
					gtt[1 ^ cL][1 ^ cR], toSend[1 ^ cL][1 ^ cR]);
		
		//System.out.println("GTT :");
		//System.out.println("gtt[0][0] :\t" +gtt[0][0].toHexStr());
		//System.out.println("gtt[0][1] :\t" +gtt[0][1].toHexStr());
		//System.out.println("gtt[1][0] :\t" +gtt[1][0].toHexStr());
		//System.out.println("gtt[1][1] :\t" +gtt[1][1].toHexStr());		
		//System.out.println("********END GARBLER**************");
		/*System.out.println("tO send :");
		System.out.println("toSend[0][0] :\t" +toSend[0][0].toHexStr());
		System.out.println("toSend[0][1] :\t" +toSend[0][1].toHexStr());
		System.out.println("toSend[1][0] :\t" +toSend[1][0].toHexStr());
		System.out.println("toSend[1][1] :\t" +toSend[1][1].toHexStr());*/	
		System.out.println(" ");
		return GCSignal.newInstance(lb[0].bytes);
	}

	private void sendGTT() {
		try {
			Flag.sw.startGCIO();
			toSend[0][1].send(channel);
			toSend[1][0].send(channel);
			toSend[1][1].send(channel);
			Flag.sw.stopGCIO();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}

	public GCSignal and(GCSignal a, GCSignal b) {
		//debug
		//----------------------------------------------------------
		
		//System.out.println("res.v: \t" + res.v);
		//------------------------------------------------------------		

		Flag.sw.startGC();
		//System.out.println("call 1");
		GCSignal res;
		/*
		System.out.println("*************************");
		System.out.println("AND :");
		System.out.println("a.bytes: \t" + a.toHexStr() + "\t b.bytes: \t" + b.toHexStr());
		System.out.println("a.v: \t" + a.v + "\t b.v: \t" + b.v);
		System.out.println("a.isPublic: \t" + a.isPublic() + "\t b.isPublic : \t" + b.isPublic());
		*/
		if (a.isPublic() && b.isPublic())
			res = ( (a.v && b.v) ? new GCSignal(true): new GCSignal(false));
		else if (a.isPublic())
			res = a.v ? b : new GCSignal(false);
		else if (b.isPublic())
			res = b.v ? a : new GCSignal(false);
		else {
			++numOfAnds;
			GCSignal ret;
			ret = garble(a, b);

			sendGTT();
			gid++;
			gatesRemain = true;
			res = ret;
		}
		Flag.sw.stopGC();
		//debug
		//----------------------------------------------------------
		//System.out.println("*************************");
		//System.out.println("AND :");
		//System.out.println("a.v: \t" + a.v + "\t b.v: \t" + b.v);
		System.out.println("res.v: \t" + res.v);
		System.out.println("*************************");
		//------------------------------------------------------------


	
		return res;
	}

}
