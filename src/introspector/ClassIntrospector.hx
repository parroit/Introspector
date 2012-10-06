package introspector;

class ClassIntrospector<ObjectType>  {
	public var name(default,null) : String;
	public var type(default,null) : Class<Dynamic>;
	public var meta(default,null) : Dynamic;
	public var doc(default,null) : Null<String>;
	public var fields(default,null) : Hash<FieldIntrospector<ObjectType,Dynamic>>;

	public function new(name,type,meta,doc){
		this.name=name;
		this.type=type;
		this.meta=meta;
		this.doc=doc;
		this.fields=new Hash<FieldIntrospector<ObjectType,Dynamic>>(); 	
	}
}