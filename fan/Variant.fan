using [java] com.jacob.com::Variant as JVariant
using [java] java.util::Date as JDate

** A multi-format data type used for all COM communications.
** 
** A Variant's type may be queried using the 'isXXX()' methods and returned with the 'asXXX()' 
** methods. Variants have the notion of being null, the equivalent of VB Nothing. Whereas Variant 
** objects themselves are never null, their 'asXXX()' methods may return null.
** 
** The [asType()]`asType` method can be used to return any Fantom literal ('Bool', 'Int', 'Emum', 
** etc...) and also Fancom Surrogates. Surrogates are user defined classes which wrap either a 
** `Dispatch` or a `Variant` object. Surrogates make it easy to write boiler plate Fantom classes 
** that mimic the behaviour of COM components. 
** 
** 
** Variant Surrogates [#surrogate]
** ===============================
** A Variant Surrogate is any object that conforms to the following rules. (Think of it as an 
** *implied* interface.)
** 
** A Variant Surrogate **must** have either:
**  - a ctor with the signature 'new makeFromVariant(Variant variant)' or
**  - a static factory method with the signature 'static MyClass fromVariant(Variant variant)'
** 
** A Variant Surrogate **must** also have either:
**  - a method with the signature 'Variant toVariant()' or
**  - a field with the signature 'Variant variant'
**  
** This allows Variant Surrogates to be passed in as parameters to a Dispatch object, and to be 
** instantiated from the [asType()]`asType` method.
** 
** Enums are good candidates for converting into surrogates. Also see `Flag` as another example.
** 
** Note: Fancom Surrogate methods and fields may be of any visibility - which is useful if don't 
** wish to expose them.
**  
** Note: Fancom Surrogates don't require you to implement any Mixins, reflection is used to find 
** your wrapper methods.
**
**
** Variant Types [#variantTypes]
** =============================
** The conversion of types between the various underlying systems is given below:
** 
** pre>
**   Automation Type | JACOB Type | Fancom Type | Remarks
**   ---------------------------------------------------------------------
**    0 VT_EMPTY       null         null          Equivalent to VB Nothing
**    1 VT_NULL        null         null          Equivalent to VB Null
**    2 VT_I2          short        Int           
**    3 VT_I4          int          Int / Enum    A Long in VC
**    4 VT_R4          float        Float
**    5 VT_R8          double       Float
**    6 VT_CY          Currency     ---
**    7 VT_DATE        Date         DateTime
**    8 VT_BSTR        String       Str
**    9 VT_DISPATCH    Dispatch     Dispatch
**   10 VT_ERROR       int          throws Err
**   11 VT_BOOL        boolean      Bool
**   12 VT_VARIANT     Object       ---
**   14 VT_DECIMAL     BigDecimal   Decimal
**   16 VT_I1          ---          Int 
**   17 VT_UI1         byte         Int
**   18 VT_UI2         ---          Int 
**   19 VT_UI4         ---          Int 
**   20 VT_I8          long         Int
**   21 VT_UI8         ---          Int           Unsigned 64 bit - will throw err if out of range 
**   22 VT_INT         ---          Int           Signed 32 / 64 bit (dependent on OS) 
**   23 VT_UINT        ---          Int           Unsigned 32 / 64 bit - will throw err if out of range
**   25 VT_HRESULT     ---          throws Err
**   30 VT_LPSTR       ---          Str
**   31 VT_LPWSTR      ---          Str
** <pre
** 
** All other value types are unsupported by JACOB and hence unsupported by Fancom. For more information 
** on Automation Types see [VARENUM enumeration (Automation)]`http://msdn.microsoft.com/en-us/library/windows/desktop/ms221170%28v=vs.85%29.aspx` on MSDN. 
** 
class Variant {
	private static const Int VT_VECTOR	:= 0x1000 
	private static const Int VT_ARRAY	:= 0x2000 
	private static const Int VT_BYREF	:= 0x4000
	
	** The JACOB Variant this object wraps
	JVariant variant { private set }
	
	internal VarType varType

	// ---- Constructors --------------------------------------------------------------------------

	** Make a 'null' Variant
	new make() {
		this.variant = JVariant()
		this.varType = VarType.fromVt(variant.getvt)
	}

	** Make a Variant representing a 'Bool' value
	new makeFromBool(Bool value) {
		this.variant = JVariant(value)
		this.varType = VarType.fromVt(variant.getvt)
	}

	** Make a Variant representing a 'DateTime' value
	new makeFromDateTime(DateTime value) {
		this.variant = JVariant(JDate(value.toJava))
		this.varType = VarType.fromVt(variant.getvt)
	}

	** Make a Variant representing a 'Decimal' value
	new makeFromDecimal(Decimal value) {
		this.variant = JVariant(value)
		this.varType = VarType.fromVt(variant.getvt)
	}
	
	** Make a Variant representing a 'Float' value
	new makeFromFloat(Float value) {
		this.variant = JVariant(value)
		this.varType = VarType.fromVt(variant.getvt)
	}
	
	** Make a Variant representing an 'Int' value
	new makeFromInt(Int value) {
		this.variant = fromLong(value)
		this.varType = VarType.fromVt(variant.getvt)
	}

	** Make a Variant representing a 'Str' value
	new makeFromStr(Str value) {
		this.variant = JVariant(value)
		this.varType = VarType.fromVt(variant.getvt)
	}
	
	** Make a Variant wrapping the given JACOB Variant
	internal new makeFromVariant(JVariant variant) {
		this.variant = variant
		this.varType = VarType.fromVt(variant.getvt)
	}

	
	// ---- Is Methods ----------------------------------------------------------------------------
	
	** Returns 'true' if this Variant represents a 'null' value
	Bool isNull() {
		variant.isNull
	}
	
	** Returns 'true' if this Variant represents a 'Bool' value.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isBool() {
		if (isNull)
			return false
		return varType.isFantomBool
	}

	** Returns 'true' if this Variant represents a `Dispatch` object.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isDispatch() {
		if (isNull)
			return false
		return varType.isFantomDispatch
	}

	** Returns 'true' if this Variant represents a [DateTime]`sys::DateTime` object.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isDateTime() {
		if (isNull)
			return false
		return varType.isFantomDateTime
	}

	** Returns 'true' if this Variant represents a [Decimal]`sys::Decimal` object.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isDecimal() {
		if (isNull)
			return false
		return varType.isFantomDecimal
	}

	** Returns 'true' if this Variant can be converted into the given 'Enum' type, checking that 
	** the Variant value is a valid ordinal for the type. 
	** Throws 'ArgErr' if the given type is not a subclass of 'Enum'.
	Bool isEnum(Type enumType) {
		if (!enumType.isEnum)
			throw ArgErr(Messages.wrongType(enumType, Enum#))
		if (isNull)
			return false
		if (!varType.isFantomInt)
			return false
		
		// attempt to create an Enum, returning false if an Err is throw
		// yeah, this is a little 'orrid but when dealing with surrogates and ordinals it's the only 
		// way to be sure
		try {
			surrogate := Helper.toVariantSurrogate(enumType, this) 
			if (surrogate == null)
				Helper.toEnum(enumType, this)
			return true
		} catch (Err e) {
			return false
		}
	}

	** Returns 'true' if this Variant represents a 'Float' value.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isFloat() {
		if (isNull)
			return false
		return varType.isFantomFloat
	}

	** Returns 'true' if this Variant represents a 'Int' value.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isInt() {
		if (isNull)
			return false
		return varType.isFantomInt
	}
	
	** Returns 'true' if this Variant represents a 'Str' value.
	** Will return 'false' if the Variant represents 'null' as the type cannot be determined.
	Bool isStr() {
		if (isNull)
			return false
		return varType.isFantomStr
	}


	// ---- As Methods ----------------------------------------------------------------------------

	** Returns the Variant value as a 'Bool' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a 'Bool' type.
	Bool? asBool() {
		if (isNull)
			return null
		if (!isBool)
			throw FancomErr(Messages.wrongVariantType(this, Bool#))
		return variant.changeType(VarType.VT_BOOL.vt).getBoolean
	}
	
	** Returns the Variant value as a 'DateTime' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a 'DateTime' type.
	DateTime? asDateTime() {
		if (isNull)
			return null
		if (!isDateTime)
			throw FancomErr(Messages.wrongVariantType(this, DateTime#))
		date := variant.changeType(VarType.VT_DATE.vt).getJavaDate
		return DateTime.fromJava(date.getTime)
	}

	** Returns the Variant value as a 'Decimal' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a 'Decimal' type.
	Decimal? asDecimal() {
		if (isNull)
			return null
		if (!isDecimal)
			throw FancomErr(Messages.wrongVariantType(this, Decimal#))
		return variant.changeType(VarType.VT_DECIMAL.vt).getDecimal
	}
	
	** Returns the Variant value as a `Dispatch` object or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a `Dispatch` type.
	Dispatch? asDispatch() {
		if (isNull)
			return null
		if (!isDispatch)
			throw FancomErr(Messages.wrongVariantType(this, Dispatch#))
		dispatch := variant.changeType(VarType.VT_DISPATCH.vt).getDispatch
		return Dispatch(dispatch)
	}
	
	** Returns the Variant value as an instance of the supplied 'Enum' type or 'null' if the 
	** Variant represents 'null'. 
	** 
	** Throws 'ArgErr' if the given type is not a subclass of 'Enum'.
	** Throws `FancomErr` if the Variant is not an 'Enum' ('Int') type or if the 'Int' value is not a valid ordinal for the enum.
	Enum? asEnum(Type enumType) {
		if (isNull) 
			return null
		if (!isEnum(enumType))
			throw FancomErr(Messages.wrongVariantType(this, enumType))
		
		// check for variant surrogacy first, as enums often define their own values
		surrogate := Helper.toVariantSurrogate(enumType, this) 
		if (surrogate != null)
			return surrogate
		return Helper.toEnum(enumType, this) 
	}	
	
	** Returns the Variant value as a 'Float' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a 'Float' type.
	Float? asFloat() {
		if (isNull)
			return null
		if (!isFloat)
			throw FancomErr(Messages.wrongVariantType(this, Float#))
		return variant.changeType(VarType.VT_R8.vt).getDouble
	}

	** Returns the Variant value as an 'Int' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not an 'Int' type.
	Int? asInt() {
		if (isNull)
			return null
		if (!isInt)
			throw FancomErr(Messages.wrongVariantType(this, Int#))
		return variant.changeType(VarType.VT_I8.vt).getLong
	}

	** Returns the Variant value as a 'Str' or 'null' if the Variant represents 'null'. 
	** Throws `FancomErr` if the Variant is not a 'Str' type.
	Str? asStr() {
		if (isNull)
			return null
		if (!isStr)
			throw FancomErr(Messages.wrongVariantType(this, Str#))
		return variant.changeType(VarType.VT_BSTR.vt).getString
	}

	** A Swiss Army knife this method is; attempts to convert the Variant value into the given Type, be 
	** it a 'Bool', 'Enum' or a Fancom wrapper. Throws `FancomErr` if unsuccessful.
	Obj? asType(Type type) {
		if (isNull)
			return null
		return Helper.toFantomObj(this, type) ?: throw FancomErr(Messages.wrongVariantType(this, type))
	}

	
	// ---- Misc Methods --------------------------------------------------------------------------

	** Returns 'true' if this Variant is a 'Vector' value.
	Bool isVector() {
		variant.getvt.and(VT_VECTOR) > 0
	}

	** Returns 'true' if this Variant represents an array.
	Bool isArray() {
		variant.getvt.and(VT_ARRAY) > 0
	}
	
	** Returns 'true' if this Variant is a 'ByRef' value.
	Bool isByRef() {
		variant.getvt.and(VT_BYREF) > 0
	}
	
	** Returns details of the underlying COM value.
	override Str toStr() {
		// toString() on a safe(!) byte array gave errors, so we just disp '...' instead
		typeName  := varType.name
		byRef	  := isByRef ? "*" : ""
		vector	  := isVector ? "()" : ""
		return isArray ? "(${varType.name}[])..." : "(${varType.name}${vector}${byRef})$variant.toString"
	}
	
	internal static native JVariant fromLong(Int value)
}

