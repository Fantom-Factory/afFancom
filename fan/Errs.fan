
** As thrown by Fancom.
const class FancomErr : Err {
	new make(Str msg, Err? cause := null) : super(msg, cause) {}
}

** Thrown when a Dispatch call returns an 'VT_ERROR' value
const class FancomErrorErr : FancomErr {
	const Int errorValue 
	new make(Str msg, Int errorValue) : super(msg) {
		this.errorValue = errorValue
	}
}

** Thrown when a Dispatch call returns an invalid 'VT_HRESULT' value
const class FancomHResultErr : FancomErr {
	const Int hresult
	new make(Str msg, Int hresult) : super(msg) {
		this.hresult = hresult
	}
}
