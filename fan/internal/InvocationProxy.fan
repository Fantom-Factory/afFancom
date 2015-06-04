using [java] com.jacob.com::InvocationProxy as JInvocationProxy
using [java] com.jacob.com::Variant as JVariant

**
** We handle multiple event sinks here in Fantom land as it's probably a damned sight faster 'n' 
** more reliable than using COM callbacks!
** 
internal class InvocationProxy : JInvocationProxy {
	private const static Log 	log 		:= Utils.getLog(InvocationProxy#)
	private static const Type[] returnTypes	:= [Void#, Variant#]
	
	private Obj[] eventSinks				:= [,]
	
	override JVariant? invoke(Str? eventName, JVariant?[]? eventParams) {
		eventName 	= eventName ?: "Buggered"
		eventParams = eventParams ?: [,]
		
		eventSigFunc := |->Str| {
			params := eventParams.map |param| { Variant(param).toStr }.join(", ")
			return "$eventName($params)"
		}

		if (log.isDebug) 
			log.debug("Received Event - $eventSigFunc.call")			

		Variant[] retValues := eventSinks
			.map |eventSink| {
				fireEvent(eventName, eventParams, eventSink, eventSigFunc)
			}
			.exclude |value| {
				value == null
			}

		// TODO: allow case where all the return values are the same. e.g. true
		if (retValues.size > 1)
			throw FancomErr("Only ONE return value is allowed from event handlers. Event=$eventName Handlers=$eventSinks")
		return retValues.getSafe(0, null)?.variant
	}
	
	Variant? fireEvent(Str eventName, JVariant?[] eventParams, Obj eventSink, |->Str| eventSigFunc) {
		methodName := "on$eventName"
		method := eventSink.typeof.method(methodName, false)
		
		if (method == null)
			return null

		if (!returnTypes.contains(method.returns))
			throw FancomErr(Messages.methodReturnTypeMismatch(method, returnTypes))

		if (eventParams.size != method.params.size)
			throw FancomErr(Messages.methodParamSizeMismatch(method, eventParams.size, eventSigFunc.call))

		params := [,]
		for (i := 0; i < eventParams.size; ++i) {
			paramType := method.params[i].type
			var		  := Variant(eventParams[i])
			
			if (var.isNull) {
				if (paramType.isNullable)
					params.add(null)
				else
					throw FancomErr(Messages.variantIsNull(var, paramType, method, i, eventSigFunc.call))
			} else {
				paramArg  := Helper.toFantomObj(var, paramType) ?: throw FancomErr(Messages.variantTypeNotFound(var, paramType, method, i, eventSigFunc.call))
				params.add(paramArg)
			}
		}
		
		if (log.isDebug) 
			log.debug("Calling method $method")
		
		try {
			return method.callOn(eventSink, params) as Variant
			
		} catch (Err err) {
			throw FancomErr(Messages.errInEventHandler(method, err), err)
		}
	}
	
	Void addEventSink(Obj eventSink) {
		eventSinks.add(eventSink)
	}
}
