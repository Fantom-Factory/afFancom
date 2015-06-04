
**
** A Flag represents many states by setting and clearing bits on a Int. 
** 
** Using Ints as flags is still valid, but the Flags class gives superior debugging info. An 
** example Flags class:
** 
** pre>
**   const class myFlag : Flags {
**     static const myFlag one     := myFlag(1, "one")
**     static const myFlag two     := myFlag(2, "two")
**     static const myFlag three   := myFlag(3, "three")
**     static const myFlag four    := myFlag(4, "four")
** 
**     new make(|This|? f := null) : super(f) { }
**	   new makeFromDefinition(Int flag, Str? name) : super(flag, name) { }
**	   new makeFromVariant(Variant variant) : super(variant) { }
**   }
** <pre
** 
** Set and clear bits by using '+' and '-' operators:
** 
** pre>
**    (myFlag.two + myFlag.two) .toStr  --> two
**    (myFlag.two - myFlag.four).toStr  --> two
** <pre
** 
** Multiple flags may be set:
** 
** pre>
**    (myFlag.one + myFlag.four).toStr  --> one|four
**    (myFlag.two + myFlag.four).toStr  --> two|four
** <pre
** 
** Flags are automatically coalesced:
** 
** pre>
**    (myFlag.one + myFlag.three) .toStr  --> three 
** <pre
** 
** Unknown flags are presented as numbers:
** 
** pre>
**    (myFlag(16))               .toStr  --> (18)
**    (myFlag(10))               .toStr  --> two|(8)
**    (myFlag(27))               .toStr  --> three|(8)|(16)
** <pre
** 
** Every 'Flags' subclass needs to declare the following ctor to fulfil the variant surrogate 
** contract:
** 
** pre>
**   new makeFromVariant(Variant variant) : super(variant) { }
** <pre
** 	
abstract const class Flag {
	const Int value
	private const Str? pName
	
	Str name {
		get { pName == null ? computeName : pName }
		private set { }
	}
	
	protected new make(|This|? f := null) {
		f?.call(this)
	}
	
	protected new makeFromDefinition(Int value, Str? name) {
		this.value = value
		this.pName = name
		if (name != null && name.isEmpty)
			throw FancomErr("Flag name can not be empty")
	}

	** Add Flag b.  Shortcut is a + b.
	@Operator 
	This plus(Flag b) {
		plusInt(b.value)
	}

	** Removes Flag b.  Shortcut is a - b.
	@Operator 
	This minus(Flag b) {
		minusInt(b.value)
	}

	** Add Flag b.  Shortcut is a + b.
	@Operator 
	This plusInt(Int b) {
		newValue 	:= value.or(b)
		newVariant	:= Variant(newValue)
		return (Flag) Helper.toVariantSurrogate(this.typeof, newVariant)
	}

	** Removes Flag b.  Shortcut is a - b.
	@Operator 
	This minusInt(Int b) {
		newValue 	:= value.and(b.not) 
		newVariant	:= Variant(newValue)
		return (Flag) Helper.toVariantSurrogate(this.typeof, newVariant)
	}
	
	** Same as 'containsAll'
	@Deprecated { msg = "Use 'containsAny' or 'containsAll' instead" }
	Bool contains(Flag flag) {
		value.and(flag.value) == flag.value
	}

	** Returns 'true' if *any* of the given flag values are set on this object.
	Bool containsAny(Flag flag) {
		value.and(flag.value) > 0
	}

	** Returns 'true' if *all* the given flag values are set on this object.
	Bool containsAll(Flag flag) {
		value.and(flag.value) == flag.value
	}

	override Bool equals(Obj? obj) {
		if (obj == null)
			return false
		if (!obj.typeof.fits(Flag#))
			return false
		return (obj as Flag).value == value
	}
	
	override Int hash() {
		return value.hash
	}
	
	override Str toStr() {
		name
	}
	
	// ---- Variant Surrogate Methods ------------------------------------------------------------- 
	
	** Variant surrogate ctor 
	new makeFromVariant(Variant variant) {
		this.value = variant.asInt
		this.pName = null
	}

	** Variant surrogate method
	Variant toVariant() {
		Variant(value)
	}
	
	// ---- Private Methods ----------------------------------------------------------------------- 

	private Str computeName() {
		Flag[]
		match := [,]
		flags := this.findFlags
		value := this.value
		
		while (value > 0) {
			flag := flags.find |flag| {
				flag.value != 0 && flag.value.and(value) == flag.value
			}
			
			if (flag == null) {
				bit := findSetBits(value)[0]
				flag = ValueFlag(bit, "($bit)")
			}
			
			match.add(flag)
			value -= flag.value
		}

		if (match.isEmpty && !flags.isEmpty && flags[-1].value == 0)
			match.add(flags[-1])
		
		return match
			.sort |f1, f2| { (f1 as Flag).value <=> (f2 as Flag).value }
			.map |flag| { flag.pName }
			.join("|")
	}
	
	private Flag[] findFlags() {
		return typeof.fields
			.findAll |field| {
				field.isStatic && field.type == typeof
			}
			.map |field| {
				field.get
			}
			.sort |f1, f2| { 
				// inverse value order - required for finding composites
				(f2 as Flag).value <=> (f1 as Flag).value
			}
	}
	
	private Int[] findSetBits(Int value) {
		// I'm gonna take a leap of faith that no-one uses the MSB of a 64 signed long!
		(63..0)
			.map |i| { 
				2.pow(i) 
			}
			.findAll |bit| {
				value.and(bit) == bit 
			} 
	}
}

internal const class ValueFlag : Flag {
	new make(|This|? f := null) : super(f) { }
	new makeFromDefinition(Int flag, Str name) : super(flag, name) { }
	new makeFromVariant(Variant variant) : super(variant) { }
}