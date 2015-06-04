
internal enum class MyEnumWrapper {
	six (6),
	eight(8),
	nine(9);
	
	const Int value
	
	private new make(Int value) {
		this.value = value
	}
	
	Variant toVariant() {
		return Variant(value)
	}
	
	static MyEnumWrapper fromVariant(Variant variant) {
		// dunno
		// need static factory!!!
		return six
	}	
}
