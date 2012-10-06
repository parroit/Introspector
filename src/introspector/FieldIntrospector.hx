package introspector;

class FieldIntrospector<ObjectType,FieldType>  {
	public var name(default,null) : String;
	public var type(default,null) : Class<Dynamic>;
	public var isPublic(default,null) : Bool;
	public var meta(default,null) : Dynamic;
	public var doc(default,null) : Null<String>;

	public dynamic function set(instance:ObjectType,value:FieldType){}
	public dynamic function get(instance:ObjectType):FieldType{return null;}


	public function new(name,type,isPublic,meta: Dynamic,doc,set,get){
		
		this.name=name;
		this.type=type;
		this.isPublic=isPublic;
		this.meta=meta;
		this.doc=doc;
		this.set=set;
		this.get=get;
	}
}