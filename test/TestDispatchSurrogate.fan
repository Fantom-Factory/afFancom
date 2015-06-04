using [java] com.jacob.com::Dispatch as JDispatch

class TestDispatchSurrogate : Test {
	
	Void testFromDispatchSurrogate() {
		dispatch 		:= Dispatch(JDispatch())
		
		verifyNull(Helper.fromDispatchSurrogate(69))

		surrogateS 		:= MyDispatchSurrogate_Simple(dispatch)
		fromSurrogateS 	:= Helper.fromDispatchSurrogate(surrogateS)
		verifyEq(dispatch, fromSurrogateS)

		surrogateC 		:= MyDispatchSurrogate_Complex { it.blah = dispatch }
		fromSurrogateC 	:= Helper.fromDispatchSurrogate(surrogateC)
		verifyEq(dispatch, fromSurrogateC)

		surrogateS 		= MyDispatchSurrogate_Simple(null)
		verifyErr(FancomErr#) {   
			Helper.fromDispatchSurrogate(surrogateS)
		}

		surrogateC 		= MyDispatchSurrogate_Complex { it.blah = null }
		verifyErr(FancomErr#) {   
			Helper.fromDispatchSurrogate(surrogateC)
		}
	}

	Void testToDispatchSurrogate() {
		dispatch 		:= Dispatch(JDispatch())
		
		verifyNull(Helper.toDispatchSurrogate(Int#, dispatch))

		surrogateS 		:= Helper.toDispatchSurrogate(MyDispatchSurrogate_Simple#, dispatch) as MyDispatchSurrogate_Simple
		fromSurrogateS 	:= surrogateS.dispatch
		verifyEq(dispatch, fromSurrogateS)

		surrogateC 		:= Helper.toDispatchSurrogate(MyDispatchSurrogate_Complex#, dispatch) as MyDispatchSurrogate_Complex
		fromSurrogateC 	:= surrogateC.blah as Dispatch
		verifyEq(dispatch, fromSurrogateC)

		verifyErr(FancomErr#) {   
			Helper.toDispatchSurrogate(MyDispatchSurrogate_Complex2#, dispatch)
		}
	}
}

internal class MyDispatchSurrogate_Simple {
	internal Dispatch? dispatch

	internal new makeFromDispatch(Dispatch? dispatch) {
		this.dispatch = dispatch
	}
}

internal class MyDispatchSurrogate_Complex {
	internal Obj? blah
	
	new make(|This|f) {
		f(this)
	}
	
	private static MyDispatchSurrogate_Complex fromDispatch(Dispatch dispatch) {
		MyDispatchSurrogate_Complex() { it.blah = dispatch }
	}
	
	private Dispatch? toDispatch() {
		(Dispatch?) blah
	}
}

internal class MyDispatchSurrogate_Complex2 {
	private static MyDispatchSurrogate_Complex2? fromDispatch(Dispatch dispatch) {
		return null
	}
}