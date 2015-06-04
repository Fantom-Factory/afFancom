package fan.afFancom;

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import com.jacob.com.VariantUtilities;
import fan.sys.List;
import fan.sys.Type;

/**
 * @See [Java FFI :: How to differentiate between a long and an int ]`http://fantom.org/sidewalk/topic/2107`
 */
public class VariantPeer {

	public static VariantPeer make(Variant self) {
		return new VariantPeer();
	}

	public static com.jacob.com.Variant fromInt(long value) {
		return new com.jacob.com.Variant((int) value);
	}

	public static com.jacob.com.Variant fromLong(long value) {
		return new com.jacob.com.Variant(value);
	}
}
