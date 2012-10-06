package test;
import introspector.ClassIntrospector;
import introspector.FieldIntrospector;
import introspector.Persistent;




@:id(username)
@:table("users")
class Person implements Persistent , implements  haxe.rtti.Infos{
	public function new(){}
	@someMeta({
		"title" : "Person name", 
		"description" : "Your account login."}
	)
	public var username:String;

	@someMeta({
		"widget" : "password", 
		"title" : "Password", 
		"description" : "Your account password.",
		"validation": "!new thx.validation.StringLengthValidator(1, 100)"
	},"ciao")
	public var password:String;

	@someMeta({
		"title" : "E-mail", 
		"description" : "Your account primary email."
	})
	public var email:String;


	@someMeta({
		"title" : "Age", 
		"description" : "Your age"
	})
	public var age:Int;
	

	@someMeta({
		"widget" : "checkbox",
		"title" : "Remember", 
		"description" : "Remember login status."
	})	
	public var remember:Bool;
	

	/**
	 *	This is confirmation
	 */
	public var confirmationId:String;
	
}
