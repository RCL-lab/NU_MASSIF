package example;

import util.EvaRunnable;
import util.GenRunnable;
import util.Utils;
import circuits.arithmetic.IntegerLib;
import flexsc.CompEnv;
import gc.BadLabelException;

public class Add1000 {
	
	
	static public<T> T[] compute(CompEnv<T> gen, T[] inputA, T[][] inputB){
		T[] out_add = inputA;
		for(int i = 0; i <1000; ++i){
			out_add = new IntegerLib<T>(gen).add(out_add, inputB[i]);
		}
		return out_add;
	}
	
	public static class Generator<T> extends GenRunnable<T> {

		T[]inputA;
		T[][] inputB;
		T[] scResult;
		
		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputA = gen.inputOfAlice(Utils.fromInt(new Integer(args[0]), 32));
			
			inputB = gen.newTArray(1000, 0);
			for(int i = 0; i < 1000; ++i)
				inputB[i] = gen.inputOfBob(new boolean[32]);
			//inputB = gen.inputOfBob(new boolean[10][32]);
			
			//inputA = gen.newTArray(10, 0);
			//for(int i = 0; i < 10; ++i)
			//	inputA[i] = gen.inputOfAlice(Utils.fromInt(i, 4));
			
			//int i = 0;
			//for(i = 0; i<1000; ++i){
			//	inputA[i] = gen.inputOfAlice(Utils.fromInt(new Integer(args[0]), 6));
			//	gen.flush();
			//	inputB[i] = gen.inputOfBob(new boolean[6]);
			}
		
		
		@Override
		public void secureCompute(CompEnv<T> gen) {
			scResult = compute(gen, inputA, inputB);
		}
		
		@Override
		public void prepareOutput(CompEnv<T> gen) throws BadLabelException {
			System.out.println(gen.outputToAlice(scResult));
		}
	}
	
	public static class Evaluator<T> extends EvaRunnable<T> {
		T[] inputA;
		T[][] inputB;
		T[] scResult;
		
		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputA = gen.inputOfAlice(new boolean[32]);
			gen.flush();
			
			inputB = gen.newTArray(1000, 0);
			for(int i = 0; i < 1000; ++i)
				inputB[i] = gen.inputOfBob(Utils.fromInt(i, 32));

			//inputB = gen.inputOfBob(Utils.fromInt(new Integer(args[0]), 6));
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
