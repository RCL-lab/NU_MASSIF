package example;

import util.EvaRunnable;
import util.GenRunnable;
import util.Utils;
import flexsc.CompEnv;
import circuits.arithmetic.DenseMatrixLib;
import circuits.arithmetic.IntegerLib;

public class Matrixmult5 {
	
	static public<T> T[][][] compute(CompEnv<T> gen, T[][][] inputA, T[][][] inputB){
		IntegerLib<T> lib = new IntegerLib<T>(gen);
		return new DenseMatrixLib<T>(gen, lib).multiply(inputA, inputB);
	}
	
	public static class Generator<T> extends GenRunnable<T> {
		T[][][] inputB;
		T[][][] inputA;
		T[][][] in;

		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputB = gen.newTArray(5, 5, 0);
			for(int i = 0; i < 5; ++i)
				for(int j = 0; j < 5; ++ j)
					inputB[i][j] = gen.inputOfBob(new boolean[4]);
			inputA = gen.newTArray(5, 5, 0);
			for(int i = 0; i < 5; ++i)
				for(int j = 0; j< 5; ++j)
					inputA[i][j] = gen.inputOfAlice(Utils.fromInt(i, 4));
		}
		
		@Override
		public void secureCompute(CompEnv<T> gen) {
			in = compute(gen, inputA, inputB);
		}
		@Override
		public void prepareOutput(CompEnv<T> gen) {
			for(int i = 0; i < 5; ++i)
				for(int j = 0; j<5; ++j)
					System.out.println(Utils.toInt(gen.outputToAlice(in[i][j])));
		}
	}
	
	public static class Evaluator<T> extends EvaRunnable<T> {
		T[][][] inputB;
		T[][][] inputA;
		T[][][] in;
		
		@Override
		public void prepareInput(CompEnv<T> gen) {
			inputB = gen.newTArray(5, 5, 0);
			for(int i = 0; i < 5; ++i)
				for(int j = 0; j< 5; ++j)
				inputB[i][j] = gen.inputOfBob(Utils.fromInt(i, 4));
			
			inputA = gen.newTArray(5, 5, 0);
			inputA = gen.inputOfAlice(new boolean[5][5][4]);
		}
		
		@Override
		public void secureCompute(CompEnv<T> gen) {
			in = compute(gen, inputA, inputB);
		}
		
		@Override
		public void prepareOutput(CompEnv<T> gen) {
			for(int i = 0; i < 5; ++i)
				for(int j = 0; j< 5; ++j)
					gen.outputToAlice(in[i][j]);
		}
		
	}
}

