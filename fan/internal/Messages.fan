
internal const class Messages {
	private new make() { }

	// FUTURE: Move msgs in to locale/en.props and create a MsgFormatter like this:
	// 
	// static Str methodNotFound(Type type, Str signature) {
	//	 format("$<bar.baz>", "param1")
	// }
	//
	// http://fantom.org/sidewalk/topic/701
	// http://www.slf4j.org/api/org/slf4j/helpers/MessageFormatter.html
	
//	static Str intsMustBeWrapped(Obj param, Int index) {
//		"Int value '$param' at index $index must be explicitly wrapped in a Variant, of either Int or a Long type?"		
//	}

	static Str methodNotFound(Type type, Str signature) {
		"Type '$type' does not have method with signature $signature"
	}
	
	static Str methodParamSizeMismatch(Method method, Int eventParamsSize, Str debugText) {
		"Method $method should have $eventParamsSize params - it has $method.params.size!
		   Event details - $debugText"
	}
	
	static Str methodReturnTypeMismatch(Method method, Type[] compatibleTypes) {
		types := compatibleTypes.join(", ")
		return "Method $method must return on of $types - but it returns $method.returns"
	}
	
	static Str variantTypeNotFound(Variant variant, Type objType, Method forMethod, Int i, Str debugText) {
		"Could not convert '$variant' to '$objType' 
		   Method        - $forMethod - $forMethod.signature
		   Param Index   - $i (zero based)
		   Event details - $debugText"
	}
	
	static Str variantIsNull(Variant variant, Type objType, Method forMethod, Int i, Str debugText) {
		"Could not convert '$variant' to '$objType' as it is NOT nullable
		   Method        - $forMethod - $forMethod.signature
		   Param Index   - $i (zero based)
		   Event details - $debugText"
	}

	static Str wrongVariantType(Variant variant, Type to) {
		"Variant '$variant' can not be converted into a $to"
	}

	static Str wrongJacobType(Obj obj) {
		"Object $obj.typeof can not be converted to a JACOB type"
	}

	** Any underlying Fantom trace gets lost, presumably in the Fantom -> Java -> Fancom 
	** translation, so we embed the trace in the message.  
	static Str errInEventHandler(Method method, Err err) {
		"Event Handler '$method.qname' threw $err.typeof.qname -> \n$err.traceToStr"
	}
	
	static Str wrongType(Type wrong, Type correct) {
		"Type '$wrong.qname' does not fit '$correct.qname'"
	}
	
	static Str enumOrdinalOutOfRange(Type enumType, Int size, Int asInt) {
		"The ordinal '$asInt' is invalid for Enum type '$enumType' which only has $size values"
	}
	
	static Str nullSurrogateMethod(Method method) {
		"Surrogate method '$method.qname' is not allowed to return null"
	}

	static Str nullSurrogateField(Field field) {
		"Surrogate field '$field.qname' is not allowed to return null"
	}

	static Str dispatchCallReturnedError(Int error) {
		"Dispatch call returned a VT_ERROR with value: $error"
	}

	static Str dispatchCallReturnedInvalidHresult(Int hresult) {
		"Dispatch call returned an invalid VT_HRESULT of value: $hresult"
	}
}
