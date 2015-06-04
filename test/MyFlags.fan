
internal const class MyFlags : Flag {
	static const MyFlags eight		:= MyFlags(8, "eight")
	static const MyFlags one		:= MyFlags(1, "one")
	static const MyFlags two		:= MyFlags(2, "two")
	static const MyFlags three		:= MyFlags(3, "three")
	static const MyFlags four		:= MyFlags(4, "four")
	static const MyFlags naught		:= MyFlags(0, "naught")

	new makeFromDefinition(Int flag, Str? name) : super(flag, name) { }
	new makeFromVariant(Variant variant) : super(variant) { }	
}