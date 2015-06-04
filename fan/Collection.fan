
**
** A utility class that emulates a COM Collection object. 'Collection' is designed to be subclassed.
** 
** For Fancom to instantiate the collection subclass it needs a ctor similar to:
** 
**   new makeFromDispatch(Dispatch dispatch) : super(dispatch, MyCollectionType#) { }
** 
** The collection type should be a valid Fancom type or a Fancom surrogate.
** 
** Subclasses my override methods to narrow the return types:
** 
**   override MyType? item(Int index) {
**     super.item(index)
**   }
** 
** When doing so, ensure the return type is declared as nullable. See 
** [Covariance, value types, and nullability]`http://fantom.org/sidewalk/topic/611#c13742`
** 
** If calculated properties are ever allowed to be in Mixins, this class could be converted to a 
** Mixin. See [Mixin Calculated Fields]`http://fantom.org/sidewalk/topic/2110`
** 
abstract class Collection {
	** The COM Collection component
	protected Dispatch dispatch		{ private set }
	
	** The type of the collection
	protected Type collectionType
	
	** The name of the COM property which returns the collection count
	protected Str countPropertyName	:= "Count"
	
	** The name of the COM method which returns an item in the collection
	protected Str itemMethodName	:= "Item"

	** Set to '1' for collections that are 1 based 
	private Int countOffset
	
	** Makes a COM Collection of the given type 
	protected new makeFromDispatch(Dispatch dispatch, Type collectionType, Bool oneBased := false) {
		this.dispatch = dispatch
		this.collectionType = collectionType
		countOffset = oneBased ? 1 : 0
	}

	// ---- Properties ----------------------------------------------------------------------------
	
	** Returns the count of objects in the collection.
	Int? count {
		get { dispatch.getProperty(countPropertyName).asInt }
		private set { }
	}
	
	// ---- Methods -------------------------------------------------------------------------------
	
	** Returns a member of the collection specified by its index.
	** 
	** Override to provide a narrowed return type:
	** 
	** 
	**   
	virtual Obj? item(Int index) {
		return dispatch.call(itemMethodName, index).asType(collectionType)
	}

	** Calls the specified function for every item in the collection
	virtual Void each(|Obj? item, Int index| callback) {
		count := this.count
		if (count == null) return
		min := countOffset
		max := countOffset + count
		for (i := min; i < max; ++i) {
			
			callback(item(i), i)			
			
		}
	}
	
	** Returns the first item in the collection for which 'callback' returns 'true'. If 'callback' 
	** returns 'false' for every item, then return 'null'.
	** 
	** This method is lazy and *does not* pre-call `#item` for every member in the collection. 
	virtual Obj? find(|Obj? v, Int index-> Bool| callback) {
		count := this.count
		if (count == null) return null
		min := countOffset
		max := countOffset + count
		for (i := min; i < max; ++i) {
			
			obj := item(i)
			if (callback(obj, i))
				return obj
			
		}
		return null
	}

	** Returns the collection as a fully resolved `sys::List`. The list is a list of 'collectionType'.
	virtual Obj?[] asList() {
		list := [,]
		each |item| {
			list.add(item)
		}
		// #findType creates a List of Type 'collectionType'
		return list.findType(collectionType)
	}
}

