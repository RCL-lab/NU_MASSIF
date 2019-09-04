package util;

import testlibs.TestCounter;

public class StopWatch {
	
	/*static {
		System.loadLibrary("counter");
	}
	public  native long start();
	public  native long stop();*/
	static TestCounter myClockWatch = new TestCounter();

	public long ands = 0;
	double startTimeOT = 0;
	double stopTimeOT = 0;
	public double elapsedTimeOT = 0;

	//double startTimeGC = 0;
	//double stopTimeGC = 0;
	//public double elapsedTimeGC = 0;

	long startTimeGC = 0;
	long stopTimeGC = 0;
	public long elapsedTimeGC = 0;	
	
	
	long startTimeGCXOR = 0;
	long stopTimeGCXOR = 0;
	public long elapseTimeGCXOR = 0;
	
	double startTimeTotal = 0;
	double stopTimeTotal = 0;
	public double elapsedTimeTotal = 0;

	double startTimeOTIO = 0;
	double stopTimeOTIO = 0;
	public double elapsedTimeOTIO = 0;

	long startTimeGCIO = 0;
	long stopTimeGCIO = 0;
	public long elapsedTimeGCIO = 0;
	boolean countTime;
	long counter = 1;
	
	
	public StopWatch(boolean countTime) {
		this.countTime = countTime;
	}

	public void startOT() {
		if (countTime)
			startTimeOT = System.nanoTime();
	}

	public void stopOT() {
		if (countTime) {
			stopTimeOT = System.nanoTime();
			elapsedTimeOT += stopTimeOT - startTimeOT;
		}
	}

	public void startOTIO() {
		if (countTime)
			startTimeOTIO = System.nanoTime();
	}

	public void stopOTIO() {
		if (countTime) {
			stopTimeOTIO = System.nanoTime();
			elapsedTimeOTIO += stopTimeOTIO - startTimeOTIO;
		}
	}

	public void startGC() {
		if (countTime)
			//startTimeGC = System.nanoTime();
			//startTimeGC = this.start();
			startTimeGC = myClockWatch.start();
	}
	
	public void startGCXOR() {
		if (countTime)
			//startTimeGCXOR = this.start();
			startTimeGCXOR = myClockWatch.start();
	}
	
	public void stopGCXOR() {
		if (countTime){
			//stopTimeGCXOR = this.stop();
			stopTimeGCXOR = myClockWatch.stop();
			elapseTimeGCXOR += stopTimeGCXOR - startTimeGCXOR;
		}
	}

	public void stopGC() {
		if (countTime) {
//			stopTimeGC = System.nanoTime();
			//stopTimeGC = this.stop();
			stopTimeGC = myClockWatch.stop();
			elapsedTimeGC += stopTimeGC - startTimeGC;
		}
	}

	public void startGCIO() {
		if (countTime)
			startTimeGCIO = myClockWatch.start();//this.start();
	}

	public void stopGCIO() {
		if (countTime) {
			stopTimeGCIO = myClockWatch.stop();//this.stop();
			elapsedTimeGCIO += stopTimeGCIO - startTimeGCIO;
		}
	}

	public void startTotal() {
		startTimeTotal = System.nanoTime();
	}

	public double stopTotal() {
		stopTimeTotal = System.nanoTime();
		elapsedTimeTotal += stopTimeTotal - startTimeTotal;
		return stopTimeTotal - startTimeTotal;
	}

	public void addCounter() {
		++counter;
	}

	public void flush() {
		ands = 0;
		startTimeOT = 0;
		stopTimeOT = 0;
		elapsedTimeOT = 0;

		startTimeGC = 0;
		stopTimeGC = 0;
		elapsedTimeGC = 0;

		startTimeTotal = 0;
		stopTimeTotal = 0;
		elapsedTimeTotal = 0;

		startTimeOTIO = 0;
		stopTimeOTIO = 0;
		elapsedTimeOTIO = 0;

		startTimeGCIO = 0;
		stopTimeGCIO = 0;
		elapsedTimeGCIO = 0;
		counter = 1;

	}

	public void print() {
		System.out
				.println("Total Time \t GC CPU Time\t GCIO Time\t OTCPU Time\t OTIO Time\n");
		System.out.println(elapsedTimeTotal / 1000000000.0 / counter + "\t"
				+ (elapsedTimeGC - elapsedTimeGCIO + elapseTimeGCXOR) /counter + " (counter is :" + counter + ")"
				+ "\t" + elapsedTimeGCIO / 1000000000.0 / counter + " "
				+ (elapsedTimeOT - elapsedTimeOTIO) / 1000000000.0 / counter
				+ "\t" + elapsedTimeOTIO / 1000000000.0 / counter + "\n");
		System.out.println("Number of Gate:"+ands);
	}

	public void print(int i) {
		System.out.println("timer:\t"+i+" \t"+elapsedTimeTotal / 1000000000.0 / counter + "\t"
		+ (elapsedTimeGC - elapsedTimeGCIO + elapseTimeGCXOR) /counter + "counter is : int i" + counter 
		+ "\t" + elapsedTimeGCIO / 1000000000.0 / counter + " "
		+ (elapsedTimeOT - elapsedTimeOTIO) / 1000000000.0 / counter
		+ "\t" + elapsedTimeOTIO / 1000000000.0 / counter + "\n");
	}
	

}
