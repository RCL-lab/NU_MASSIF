package gc.regular;

import gc.GCSignal;

import java.nio.ByteBuffer;
import java.security.MessageDigest;

final class Garbler {
	private MessageDigest sha1 = null;
	Garbler() {
		try {
			sha1 = MessageDigest.getInstance("SHA-1");
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}

	public void enc(GCSignal lb0, GCSignal lb1, long k, GCSignal m, GCSignal ret) {
		getPadding(lb0, lb1, k, ret);
		
		System.out.println("********ENC GARBLER**************");
		System.out.println("SHA1 :");
		System.out.println("lb0 :\t" +lb0.toHexStr() + "\t lb1 :\t" + lb1.toHexStr() + "\t k :\t" + k);
		//System.out.println("ret :\t" +ret.toHexStr() + "\t");
		//System.out.println("*---*--*ENC GARBLER*--*--*--*--*");
		GCSignal.xor(ret, m, ret);
		//System.out.println("SHA1 XOR :");
		//System.out.println("ret :\t" +ret.toHexStr() + "\t");
		System.out.println("*---*--*ENC GARBLER*--*--*--*--*");	
	}

	public void dec(GCSignal lb0, GCSignal lb1, long k, GCSignal c, GCSignal ret) {
		getPadding(lb0, lb1, k, ret);
		GCSignal.xor(ret, c, ret);
	}
	ByteBuffer buffer = ByteBuffer.allocate(GCSignal.len*2+8); 
	private void getPadding(GCSignal lb0, GCSignal lb1, long k, GCSignal ret) {
		buffer.clear();
		sha1.update((buffer.put(lb0.bytes).put(lb1.bytes).putLong(k)).array());
		System.arraycopy(sha1.digest(), 0, ret.bytes, 0, GCSignal.len);
	}
}
