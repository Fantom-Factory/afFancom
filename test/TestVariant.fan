
class TestVariant : Test {

	// ---- Test Value Types ----------------------------------------------------------------------

	Void testNull() {
		var := Variant()
		verify(var.isNull)
		verifyFalse(var.isBool)
		verifyFalse(var.isDispatch)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)
		
		verifyNull(var.asBool)
		verifyNull(var.asDispatch)
		verifyNull(var.asFloat)
		verifyNull(var.asInt)
		verifyNull(var.asStr)
		verifyNull(var.asEnum(TestVariant#))
		verifyNull(var.asType(TestVariant#))
	}

	Void testBool() {
		// special test for 'false' as 'false' often represents other values
		// so wot I mean is, use 'false' for all the tests and have a few extra tests for 'true'
		verify(Variant(true).isBool)
		verify(Variant(true).asBool)
		
		var := Variant(false)

		verifyFalse(var.isNull)
		verify(var.isBool)
		verifyFalse(var.isDispatch)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)

		verifyFalse(var.asBool)
		verifyErr(FancomErr#) { var.asDispatch }
		verifyErr(FancomErr#) { var.asFloat }
		verifyErr(FancomErr#) { var.asInt }
		verifyErr(FancomErr#) { var.asStr }
	}

	Void testDateTime() {
		dt := DateTime.now
		var	:= Variant(dt)

		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verify(var.isDateTime)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verifyEq(var.asDateTime, dt)
		verifyErr(FancomErr#) { var.asFloat }
		verifyErr(FancomErr#) { var.asInt }
		verifyErr(FancomErr#) { var.asStr }
	}

	Void testDecimal() {
		Decimal dec := Decimal("69")
		var	:= Variant(dec)

		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verify(var.isDecimal)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verifyEq(var.asDecimal, dec)
		verifyErr(FancomErr#) { var.asFloat }
		verifyErr(FancomErr#) { var.asInt }
		verifyErr(FancomErr#) { var.asStr }
	}

	Void testDispatch() {
		spVoice := getSpVoice
		if (spVoice == null) return
		var	:= spVoice.getProperty("Voice")

		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verify(var.isDispatch)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verify(var.asDispatch.typeof == Dispatch#)
		verifyErr(FancomErr#) { var.asFloat }
		verifyErr(FancomErr#) { var.asInt }
		verifyErr(FancomErr#) { var.asStr }
	}
	
	Void testFloat() {
		var := Variant(69f)

		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verifyFalse(var.isDispatch)
		verify(var.isFloat)
		verifyFalse(var.isInt)
		verifyFalse(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verifyErr(FancomErr#) { var.asDispatch }
		verifyEq(var.asFloat, 69f)
		verifyErr(FancomErr#) { var.asInt }
		verifyErr(FancomErr#) { var.asStr }
	}

	Void testInt() {
		var := Variant(69)
		
		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verifyFalse(var.isDispatch)
		verifyFalse(var.isFloat)
		verify(var.isInt)
		verifyFalse(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verifyErr(FancomErr#) { var.asDispatch }
		verifyErr(FancomErr#) { var.asFloat }
		verifyEq(var.asInt, 69)
		verifyErr(FancomErr#) { var.asStr }
	}

	Void testStr() {
		var := Variant("Dude")
		
		verifyFalse(var.isNull)
		verifyFalse(var.isBool)
		verifyFalse(var.isDispatch)
		verifyFalse(var.isFloat)
		verifyFalse(var.isInt)
		verify(var.isStr)
		
		verifyErr(FancomErr#) { var.asBool }
		verifyErr(FancomErr#) { var.asDispatch }
		verifyErr(FancomErr#) { var.asFloat }
		verifyErr(FancomErr#) { var.asInt }		
		verifyEq(var.asStr, "Dude")
	}

	// ---- Test Obj Types ------------------------------------------------------------------------
	
	Void testEnum() {
		var := Variant(4)
		verifyErr(ArgErr#) { var.isEnum(Int#) }
		verifyFalse(var.isEnum(MyEnum#))
		var = Variant(3)
		verify(var.isEnum(MyEnum#))
		
		var = Variant(69)
		verifyErr(ArgErr#) { var.asEnum(Int#) }
		var = Variant(1)
		verifyEq(MyEnum.one, var.asEnum(MyEnum#))

		
		var = Variant(4)
		verifyErr(ArgErr#) { var.isEnum(Int#) }
		verifyFalse(var.isEnum(MyOtherEnum#))
		var = Variant(3)
		verify(var.isEnum(MyOtherEnum#))
		
		var = Variant(69)
		verifyErr(ArgErr#) { var.asEnum(Int#) }
		var = Variant(1)
		verifyEq(MyOtherEnum.one, var.asEnum(MyOtherEnum#))
	}

	private Dispatch? getSpVoice() {
		try {
			return Dispatch.makeFromProgId("SAPI.SpVoice")
		} catch (Err e) {
			Env.cur.err.printLine("Can not create SAPI.SpVoice COM instance -> can not run test")
			return null
		}
	}
}
