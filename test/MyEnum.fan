
internal enum class MyEnum {
	none,
	one,
	two,
	three;
}

internal enum class MyOtherEnum {
	one(1),
	two(2),
	three(3);
	
	const Int value
	
	private new make(Int value) {
		this.value = value
	}
	
	static MyOtherEnum fromVariant(Variant variant) {
		varVal := variant.asInt
		return MyOtherEnum.vals.find { 
			it.value == varVal
		} ?: throw Err("Could not find MyOtherEnum with value '$varVal'")
	}
	
	Variant toFancom() {
		Variant(value)
	}		
}
