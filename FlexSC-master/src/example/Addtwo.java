package example;

import util.EvaRunnable;
import util.GenRunnable;
import util.Utils;
import circuits.arithmetic.IntegerLib;
import flexsc.CompEnv;
import gc.BadLabelException;
import gc.GCSignal;

public class Addtwo {
	
	
	static public<T> T[] compute(CompEnv<T> gen, T[] inputA, T[] inputB){
		// debug		
		//if (inputA instanceof GCSignal) {
		//	System.out.println("==================================");
		//	System.out.println("Inputs :");
		//	System.out.println("inputA: \t" + inputA + "\t inputB: \t" + inputB);
		//	System.out.println("==================================");	
		//}
		T[] out_add = new IntegerLib<T>(gen).add(inputA, inputB);
		return out_add;
	}
	
	public static class Generator<T> extends GenRunnable<T> {

		T[] inputA;
		T[] inputB;
		T[] scResult;
		
		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputA = gen.inputOfAlice(Utils.fromInt(new Integer(args[0]), 6));
			gen.flush();
			inputB = gen.inputOfBob(new boolean[6]);
		}
		
		@Override
		public void secureCompute(CompEnv<T> gen) {
			scResult = compute(gen, inputA, inputB);
		}
		
		@Override
		public void prepareOutput(CompEnv<T> gen) throws BadLabelException {
			System.out.println("gen.output to Alice: "+ gen.outputToAlice(scResult));
		}
	}
	
	public static class Evaluator<T> extends EvaRunnable<T> {
		T[] inputA;
		T[] inputB;
		T[] scResult;
		
		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputA = gen.inputOfAlice(new boolean[6]);
			gen.flush();
			inputB = gen.inputOfBob(Utils.fromInt(new Integer(args[0]), 6));
		}
		
		@Override
		public void secureCompute(CompEnv<T> gen) {
			scResult = compute(gen, inputA, inputB);
		}
		
		@Override
		public void prepareOutput(CompEnv<T> gen) throws BadLabelException {
			gen.outputToAlice(scResult);
		}
	}
}
