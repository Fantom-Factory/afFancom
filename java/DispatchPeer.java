package fan.afFancom;

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import com.jacob.com.Variant;
import com.jacob.com.VariantUtilities;
import fan.sys.List;
import fan.sys.Type;

public class DispatchPeer {
	
	public static DispatchPeer make(Dispatch self) {
		return new DispatchPeer();
	}

	public static List toVariantArray(List objs) throws Throwable {
		Method method  = VariantUtilities.class.getDeclaredMethod("objectsToVariants", Object[].class);
		Object[] array = new Object[] { objs.toArray() };
		method.setAccessible(true);
		try {
			Variant[] vars = (Variant[]) method.invoke(null, array);
			return new List(Type.of(new Variant()), vars);
		} catch (InvocationTargetException e) {
			throw e.getCause();
		}
	}
}
