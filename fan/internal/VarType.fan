
internal enum class VarType {
	VT_EMPTY             (0), 
	VT_NULL              (1), 
	VT_I2                (2), 
	VT_I4                (3), 
	VT_R4                (4), 
	VT_R8                (5), 
	VT_CY                (6), 
	VT_DATE              (7), 
	VT_BSTR              (8), 
	VT_DISPATCH          (9), 
	VT_ERROR             (10), 
	VT_BOOL              (11), 
	VT_VARIANT           (12), 
	VT_UNKNOWN           (13), 
	VT_DECIMAL           (14), 
	VT_I1                (16), 
	VT_UI1               (17), 
	VT_UI2               (18), 
	VT_UI4               (19), 
	VT_I8                (20), 
	VT_UI8               (21), 
	VT_INT               (22), 
	VT_UINT              (23), 
	VT_VOID              (24), 
	VT_HRESULT           (25), 
	VT_PTR               (26), 
	VT_SAFEARRAY         (27), 
	VT_CARRAY            (28), 
	VT_USERDEFINED       (29), 
	VT_LPSTR             (30), 
	VT_LPWSTR            (31), 
	VT_RECORD            (36), 
	VT_INT_PTR           (37), 
	VT_UINT_PTR          (38), 
	VT_FILETIME          (64), 
	VT_BLOB              (65), 
	VT_STREAM            (66), 
	VT_STORAGE           (67), 
	VT_STREAMED_OBJECT   (68), 
	VT_STORED_OBJECT     (69), 
	VT_BLOB_OBJECT       (70), 
	VT_CF                (71), 
	VT_CLSID             (72), 
	VT_VERSIONED_STREAM  (73), 
	VT_BSTR_BLOB         (0xfff);
	
	const Int vt
	
	private new make(Int vt) {
		this.vt = vt
	}
	
	static VarType fromVt(Int vt) {
		// mask out ByRef, Array and Vector flags
		value := vt.and(0x0FFF)
		return VarType.vals.find {
			it.vt == value
		} ?: throw ArgErr("Could not find ${VarType#.qname} with value '$value'")
	}
	
	Bool isFantomBool() {
		this == VT_BOOL
	}

	Bool isFantomDateTime() {
		this == VT_DATE
	}
	
	Bool isFantomDecimal() {
		this == VT_DECIMAL
	}

	Bool isFantomDispatch() {
		this == VT_DISPATCH
	}

	Bool isFantomFloat() {
		this == VT_R4 ||
		this == VT_R8
	}

	Bool isFantomInt() {
		this == VT_UI1 ||
		this == VT_UI2 ||
		this == VT_UI4 ||
		this == VT_UI8 ||
		this == VT_I1  ||
		this == VT_I2  ||
		this == VT_I4  ||
		this == VT_I8  ||
		this == VT_INT ||
		this == VT_UINT
	}

	Bool isFantomStr() {
		this == VT_BSTR  ||
		this == VT_LPSTR ||
		this == VT_LPWSTR
	}

	Bool isFantomVoid() {
		this == VT_VOID  ||
		this == VT_ERROR ||
		this == VT_HRESULT	// FIXME: err on hresult
	}
}
