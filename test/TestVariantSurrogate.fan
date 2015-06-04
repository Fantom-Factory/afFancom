
class TestVariantSurrogate : Test {
	
	Void testFromVariantSurrogate() {
		variant 		:= Variant(69)
		
		verifyNull(Helper.fromVariantSurrogate(69))

		surrogateS 		:= MyVariantSurrogate_Simple(variant)
		fromSurrogateS 	:= Helper.fromVariantSurrogate(surrogateS)
		verifyEq(variant, fromSurrogateS)

		surrogateC 		:= MyVariantSurrogate_Complex { it.blah = variant }
		fromSurrogateC 	:= Helper.fromVariantSurrogate(surrogateC)
		verifyEq(variant, fromSurrogateC)

		surrogateS 		= MyVariantSurrogate_Simple(null)
		verifyErr(FancomErr#) {   
			Helper.fromVariantSurrogate(surrogateS)
		}

		surrogateC 		= MyVariantSurrogate_Complex { it.blah = null }
		verifyErr(FancomErr#) {   
			Helper.fromVariantSurrogate(surrogateC)
		}
	}

	Void testToVariantSurrogate() {
		variant 		:= Variant(69)
		
		verifyNull(Helper.toVariantSurrogate(Int#, variant))

		surrogateS 		:= Helper.toVariantSurrogate(MyVariantSurrogate_Simple#, variant) as MyVariantSurrogate_Simple
		fromSurrogateS 	:= surrogateS.variant
		verifyEq(variant, fromSurrogateS)

		surrogateC 		:= Helper.toVariantSurrogate(MyVariantSurrogate_Complex#, variant) as MyVariantSurrogate_Complex
		fromSurrogateC 	:= surrogateC.blah as Variant
		verifyEq(variant, fromSurrogateC)

		verifyErr(FancomErr#) {   
			Helper.toVariantSurrogate(MyVariantSurrogate_Complex2#, variant)
		}
	}
}

internal class MyVariantSurrogate_Simple {
	internal Variant? variant

	internal new makeFromVariant(Variant? variant) {
		this.variant = variant
	}
}

internal class MyVariantSurrogate_Complex {
	internal Obj? blah
	
	new make(|This|f) {
		f(this)
	}
	
	private static MyVariantSurrogate_Complex fromVariant(Variant variant) {
		MyVariantSurrogate_Complex() { it.blah = variant }
	}
	
	private Variant? toVariant() {
		(Variant?) blah
	}
}

internal class MyVariantSurrogate_Complex2 {
	private static MyVariantSurrogate_Complex2? fromVariant(Variant variant) {
		return null
	}
}