using [java] com.jacob.com::ComThread as JComThread

**
** Handles the tricky business of COM threading. 
** 
** Every time a Fancom Variant is created, a doppelganger is created in COM land. While the JVM 
** Garbage Collector does a good of cleaning up the Fancom Variants, there is no similar mechanism 
** to clean up the Variants in COM land. 
** 
** Instead, JACOB holds references to these COM Variants, on a per thread basis, in a Running 
** Object Table (ROT) and only destroys them upon a manual call to `ComThread.release`. 
** 
** (To do a proper job of this requires a finer grained control of the ROT - so some main classes,
** like SpInProcRecoCtx, don't get cleaned up and continue to fire events. The rest of the code 
** (including Event Code) could then be run in a closure to release all objects created within. 
** But this needs JACOB to be modified.) 
** 
** In essence, call 'initSta()' at the start of your COM calls and 'release()' at the end.
** 
** For more details:
** - See [COM Apartments in JACOB]`http://danadler.com/jacob/JacobThreading.html` from JACOB
** - See [The Least You Need to Know about COM]`http://groovy.codehaus.org/The+Least+You+Need+to+Know+about+COM` from Groovy Scriptcom
** 
class ComThread {

	static const private |->| shutdownHook := |->| {
		JComThread.Release		
	}
	
	** Initialise an STA thread.
	static Void initSta() {
		releaseThreadOnShutdown
		JComThread.InitSTA
	}

	** Initialise an MTA thread.
	static Void initMta() {
		releaseThreadOnShutdown
		JComThread.InitMTA
	}
	
	** Release current COM resources for this thread.
	static Void release() {
		JComThread.Release
	}
	
	private static Void releaseThreadOnShutdown() {
		// ensure we don't keep adding more and more hooks!
		Env.cur.removeShutdownHook(shutdownHook)
		
		// (re)register the hook
		Env.cur.addShutdownHook(shutdownHook)
	}
}
