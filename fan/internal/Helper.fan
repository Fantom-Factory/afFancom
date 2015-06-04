using [java] com.jacob.com::Dispatch as JDispatch
using [java] com.jacob.com::Variant as JVariant
using [java] java.util::Date as JDate

** Surrogate methods are not allowed to return 'null' for within the bowls of toFantomObj() etc al, 
** it's too difficult to extract the use cases where it may be deemed acceptable. 
internal class Helper {
	private const static Log 	log 		:= Utils.getLog(Helper#)
	private new make() { }

	** Returns 'null' if a conversion can not be found - this allows for more contextual error 
	** messages from the caller.
	** 
	** Therefore 'null' checks should be performed by the caller prior to to calling this. 
	static Obj? toJacobObj(Obj? obj) {
		if (obj == null)		return JVariant()
		if (obj is Bool)		return obj
		if (obj is DateTime)	return JDate((obj as DateTime).toJava)
		if (obj is Decimal)		return obj
		if (obj is Int)			return obj	// throw FancomErr(Messages.intsMustBeWrapped(obj, index));
		if (obj is Float)		return obj
		if (obj is Str)			return obj
		if (obj is Variant)		return (obj as Variant).variant

		// check for variant surrogacy first, as enums may also be surrogates
		variant := fromVariantSurrogate(obj)
		if (variant != null)
			return variant.variant

		// check for Enums next - using the ordinal
		if (obj is Enum)
			return fromEnum(obj as Enum).variant

		// last resort... is it a dispatch surrogate? 
		dispatch := fromDispatchSurrogate(obj)
		if (dispatch != null)
			return dispatch.dispatch
		
		// you loose!
		return null
	}
	
	** Returns 'null' if a conversion can not be found - this allows for more contextual error 
	** messages from the caller.
	** 
	** Therefore 'null' checks should be performed by the caller prior to to calling this. 
	static Obj? toFantomObj(Variant var, Type type) {
		if (var.isNull)
			throw ArgErr("Variant is null!")
		
		// Note: nullablity effects '==' but not 'fits()' 
		// Num# == Num?#    -> false
		// Num#.fits(Num?#) -> true
		// Num?#.fits(Num#) -> true		

		// check for variant surrogacy first, as enums may also be surrogates
		surrogate := toVariantSurrogate(type, var) 
		if (surrogate != null)
			return surrogate
		
		// return FANCOM objects
		if (type.fits(Variant#))
			return var
		if (type.fits(Dispatch#) && var.isDispatch)
			return var.asDispatch

		// return JACOB objects
		if (type.fits(JVariant#))
			return var.variant
		if (type.fits(JDispatch#) && var.isDispatch)
			return var.variant.getDispatch

		// return FANTOM literals
		if (type.fits(Bool#) && var.isBool)
			return var.asBool
		if (type.fits(DateTime#) && var.isDateTime)
			return var.asDateTime
		if (type.fits(Decimal#) && var.isDecimal)
			return var.asDecimal
		if (type.fits(Float#) && var.isFloat)
			return var.asFloat
		if (type.fits(Int#) && var.isInt)
			return var.asInt
		if (type.fits(Str#) && var.isStr)
			return var.asStr

		// check for Enums next - using the ordinal
		if (type.isEnum && var.isEnum(type))
			return toEnum(type, var)
		
		// last resort... is it a dispatch surrogate?
		if (var.isDispatch) {
			surrogate = toDispatchSurrogate(type, var.asDispatch)
			if (surrogate != null)
				return surrogate
		}
		
		// you loose!
		runSurrogateDiagnostics(type)
		return null
	}

	static Variant? fromVariantSurrogate(Obj surrogate) {
		method := ReflectUtils.findMethod(surrogate.typeof, "toVariant", [,], false, Variant#)
		if (method != null) 
			return method.callOn(surrogate, null) as Variant ?: throw FancomErr(Messages.nullSurrogateMethod(method))
		
		field := ReflectUtils.findField(surrogate.typeof, "variant", Variant#)
		if (field != null) 
			return field.get(surrogate) ?: throw FancomErr(Messages.nullSurrogateField(field))
		
		return null
	}

	static Dispatch? fromDispatchSurrogate(Obj surrogate) {
		method := ReflectUtils.findMethod(surrogate.typeof, "toDispatch", [,], false, Dispatch#)
		if (method != null)  
			return method.callOn(surrogate, null) as Dispatch ?: throw FancomErr(Messages.nullSurrogateMethod(method))
		
		field := ReflectUtils.findField(surrogate.typeof, "dispatch", Dispatch#)
		if (field != null) 
			return field.get(surrogate) ?: throw FancomErr(Messages.nullSurrogateField(field))
		
		return null
	}

	static Obj? toVariantSurrogate(Type surrogateType, Variant variant) {
		method := ReflectUtils.findMethod(surrogateType, "fromVariant", [Variant#], true)
		if (method != null) 
			return method.call(variant) ?: throw FancomErr(Messages.nullSurrogateMethod(method))

		ctor := ReflectUtils.findCtor(surrogateType, "makeFromVariant", [Variant#])
		if (ctor != null) 
			return ctor.call(variant)

		return null
	}

	static Obj? toDispatchSurrogate(Type surrogateType, Dispatch dispatch) {
		method := ReflectUtils.findMethod(surrogateType, "fromDispatch", [Dispatch#], true)
		if (method != null) 
			return method.call(dispatch) ?: throw FancomErr(Messages.nullSurrogateMethod(method))

		ctor := ReflectUtils.findCtor(surrogateType, "makeFromDispatch", [Dispatch#])
		if (ctor != null) 
			return ctor.call(dispatch)

		return null
	}

	static Variant fromEnum(Enum? obj) {
		Variant((obj as Enum).ordinal)
	}
	
	static Enum toEnum(Type enumType, Variant variant) {
		vals := enumType.field("vals").get as Obj[]
		ordinal := variant.asInt
		if (ordinal >= vals.size)
			throw FancomErr(Messages.enumOrdinalOutOfRange(enumType, vals.size, ordinal))
		return vals[ordinal] 
	}

	static Void runSurrogateDiagnostics(Type surrogateType) {
		method := ReflectUtils.findMethod(surrogateType, "makeFromVariant", [Variant#], true)
		if (method != null) 
			log.warn("$surrogateType.qname has a static factory method called 'makeFromVariant', did you want the surrogate method 'fromVariant'?")

		ctor := ReflectUtils.findCtor(surrogateType, "fromVariant", [Variant#])
		if (ctor != null) 
			log.warn("$surrogateType.qname has a ctor method called 'fromVariant', did you want the surrogate ctor 'makeFromVariant'?")

		// Gawd Damn Typos!
		method = ReflectUtils.findMethod(surrogateType, "fromVaraint", [Variant#], true)
		if (method != null)
			log.warn("$surrogateType.qname has a static factory method called 'fromVaraint', is this a typo for the surrogate method 'fromVariant'?")

		ctor = ReflectUtils.findCtor(surrogateType, "makeFromVaraint", [Variant#])
		if (ctor != null) 
			log.warn("$surrogateType.qname has a ctor method called 'makeFromVaraint', is this a typo for the surrogate ctor 'makeFromVariant'?")

		method = ReflectUtils.findMethod(surrogateType, "makeFromDispatch", [Dispatch#], true)
		if (method != null) 
			log.warn("$surrogateType.qname has a static factory method called 'makeFromDispatch', did you want the surrogate method 'fromDispatch'?")

		ctor = ReflectUtils.findCtor(surrogateType, "fromDispatch", [Dispatch#])
		if (ctor != null) 
			log.warn("$surrogateType.qname has a ctor method called 'fromDispatch', did you want the surrogate ctor 'makeFromDispatch'?")		
	}
}


