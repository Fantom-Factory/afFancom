using [java] com.jacob.com::Dispatch as JDispatch
using [java] com.jacob.com::DispatchEvents as JDispatchEvents 
using [java] com.jacob.com::Variant as JVariant

**
** Communicates to COM objects.
** 
** Dispatch Surrogates [#surrogate]
** ================================
** Dispatch Surrogates allow classes to mimic the behaviour of their peer COM components - they 
** ensure compilation type safety and consistent reuse. 
** 
** A Dispatch Surrogate is any object that conforms to the following rules. (Think of it as an 
** *implied* interface.)
** 
** A Dispatch Surrogate **must** have either:
**  - a ctor with the signature 'new makeFromDispatch(Dispatch dispatch)' or
**  - a static factory method with the signature 'static MyClass fromDispatch(Dispatch dispatch)'
** 
** A Dispatch Surrogate **must** also have either:
**  - a method with the signature 'Dispatch toDispatch()' or
**  - a field with the signature 'Dispatch dispatch'
**
** An example surrogate would look like:
**
** pre>
**   using afFancom
**
**   class SpVoice {
**     internal Dispatch dispatch
**
**     new makeFromDispatch(Dispatch dispatch) {
**       this.dispatch = dispatch
**     }
**
**     SpObjectToken? voice {
**       get { dispatch.getProperty("Voice").asType(SpObjectToken#) }
**       set { dispatch.setProperty("Voice", it) }
**     }
** 
**     Int speak(Str text, SpeechVoiceSpeakFlags flags := SpeechVoiceSpeakFlags.SVSFDefault) {
**       dispatch.call("Speak", text, flags).asInt
**     }
**   }
** <pre
** 
** The `Variant.asType` method will happily instantiate and return Dispatch Surrogates, such as 
** 'SpObjectToken' above. 
**
** COM Events [#comEvents]
** =======================
** You can register any class to receive events from COM objects by passing it into the
** [registerForEvents()]`#registerForEvents` method. When a COM event is received, Fancom will 
** look for a method on your event sink with the same name as the COM event, prefixed with 'on'.
** 
** Example: If COM fires an event called 'Recognition' your event sink should have a method called
** 'onRecognition()'. The parameters on the event handler should match those raised by COM. 
** Parameters can be the Fantom equivalents including surrogates. A detailed error message is given
** should they not match.
**
** See [Variant Types]`Variant#variantTypes` for parameter mappings.
** 
** pre>
**    ...
**    dispatch.registerForEvents(this)
**    ...
** 
**    Void onRecognition(Int streamNumber, Variant streamPosition, SpeechRecognitionType recognitionType, ISpeechRecoResult result) {
**      Obj.echo(result.phraseInfo.getText)
**    }
** <pre
** 
** Event handlers may optionally return a Variant that will be 
**   
class Dispatch {
	private const static Log 	log 		:= Utils.getLog(Dispatch#)
	
	** The JACOB Dispatch this object wraps
	JDispatch dispatch { private set }
	
	private InvocationProxy? invocationProxy

	// ---- Constructors --------------------------------------------------------------------------
	
	internal new makeFromDispatch(JDispatch dispatch) {
		this.dispatch = dispatch
	}

	new makeFromProgId(Str programId) {
		this.dispatch = JDispatch(programId)
	}

	// ---- Properties ----------------------------------------------------------------------------
	
	** Gets a property from the COM object. 
	Variant getProperty(Str propertyName) {
		return Variant(JDispatch.get(dispatch, propertyName)) 
	}

	// Can't use a field 'cos the get and set types are different
	** Sets a property on the COM object.
	Void setProperty(Str propertyName, Obj? propertyValue) {
		obj := Helper.toJacobObj(propertyValue) ?: throw FancomErr(Messages.wrongJacobType(propertyValue))
		if (obj is JDispatch)
			// dunno if this is the right logic or not, but it's defo needed for 
			// ISpeechRecognizer.audioInput setProperty
			JDispatch.putRef(dispatch, propertyName, obj)
		else
			JDispatch.put(dispatch, propertyName, obj)
	}

	// ---- Methods -------------------------------------------------------------------------------

	** Convenience for 'callList()'.
	Variant call(Str methodName, 
		Obj? a := null, Obj? b := null, Obj? c := null, Obj? d := null,
		Obj? e := null, Obj? f := null, Obj? g := null, Obj? h := null) {
		params := [a, b, c, d, e, f, g, h]
		// remove nulls from the end of the list
		while (!params.isEmpty && params.peek == null)
			params.pop
		return callList(methodName, params)
	}
	
	** Calls a method on the COM object.
	Variant callList(Str methodName, Obj?[] params := [,]) {
		objs := params.map |param| {
			Helper.toJacobObj(param) ?: throw FancomErr(Messages.wrongJacobType(param))
		}
		vars := toVariantArray(objs)
		retVal := Variant(JDispatch.callN(dispatch, methodName, vars))
		
		if (retVal.varType == VarType.VT_ERROR) {
			error := retVal.variant.changeType(VarType.VT_I8.vt).getLong
			throw FancomErrorErr(Messages.dispatchCallReturnedError(error), error)
		}

		// see http://en.wikipedia.org/wiki/HRESULT#Using_HRESULTs
		if (retVal.varType == VarType.VT_HRESULT) {
			hresult := retVal.variant.changeType(VarType.VT_I8.vt).getLong
			if (hresult < 0)
				throw FancomHResultErr(Messages.dispatchCallReturnedInvalidHresult(hresult), hresult)
		}
		
		return retVal
	}
	
	** Registers the given event sink to receive events from this 'Dispatch' object. Ensure your
	** sink defines a method called 'onEventName()' for each event you wish to receive. 
	** 
	** Note method this will sometimes fail if this Dispatch object was not created via the 
	** 'makeFromProgId' ctor. 
	Void registerForEvents(Obj eventSink) {
		// TODO: if ProgId was not supplied, try looking it up in from the registry
		// http://stackoverflow.com/questions/8328090/does-anyone-know-any-good-tool-to-convert-clsid-and-progid
		log.info("Registering $eventSink.typeof to receive events")
		
		if (invocationProxy == null) {
			invocationProxy = InvocationProxy()
			events := JDispatchEvents(dispatch, invocationProxy)
		}
		invocationProxy.addEventSink(eventSink)
	}
	
	// ---- Helpers -------------------------------------------------------------------------------

	internal static native JVariant[] toVariantArray(Obj[] objs)

}
