using [java] java.lang::System

@NoDoc
class JacobProperties {
	private new make() { }
	
	static Void enableDebugLogging() {
		System.setProperty("com.jacob.debug", "true")
	}
}
