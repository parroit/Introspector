package test;
import thx.validation.StringLengthValidator;
import test.Person;



import utest.Assert;
import utest.Runner;
import utest.ui.Report;




class TestIntrospector{
	 public static function main() {
        var runner = new Runner();
        runner.addCase(new TestIntrospector());
        Report.create(runner);
        runner.run();
    }
        
    public function new(){}

	public function testSetter() {
		var user=new Person();
		
		Person.introspector.username.set(user,"Andrea Parodi");
		Person.introspector.age.set(user,36);

		Assert.equals("Andrea Parodi",user.username);
		Assert.equals(36,user.age);

	}

	public function testGetter() {
		var user=new Person();

		user.username="Andrea Parodi";
		user.age=36;
		

		Assert.equals("Andrea Parodi",Person.introspector.username.get(user));
		Assert.equals(36,Person.introspector.age.get(user));

	}


	public function testIndexedFields() {
		var user=new Person();

		Assert.equals("username",Person.introspector.fields.get("username").name);
		Assert.equals(Type.resolveClass("String"),Person.introspector.fields.get("username").type);

	}


	public function testModelClassName() {
		
		Assert.equals("Person",Person.introspector.name);
		

	}

	public function testModelClass() {
		var clazz=Type.getClassName(Type.getClass(new Person()));
		
		Assert.equals(clazz,Type.getClassName(Person.introspector.type));
		

	}

	public function testMetadata() {
		
		Assert.equals("Person name",Person.introspector.username.meta.someMeta[0].title);
		Assert.equals("Your age",Person.introspector.age.meta.someMeta[0].description);

	}


	public function testTypeName() {
		

		Assert.equals(Type.getClass(""),Person.introspector.username.type);
		Assert.equals(Type.resolveClass("Int"),Person.introspector.age.type);

	}


	/** Return a random string with length between 'from' and 'to', inclusive. */
	public static function randomString(from:Int, to:Int):String
	{
		var len=Random.int(from,to);
		var randomString="";
		var charsArr=new Array<String>();
		for (c in 0...chars.length)
			charsArr.push(chars.charAt(c));
		for (l in 0...len){
			randomString+=Random.fromArray(charsArr);
		}
		return randomString;
	}


	static var chars:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

	public function testPerformance() {
		var users=new Array<Person>();
		for (i in 0...100){
			var user=new Person();
			
			user.username=randomString(1,50);
			user.password=randomString(1,50);
			user.age=Random.int(1,50);
			user.confirmationId=randomString(1,50);
			user.email=randomString(1,50);
			user.remember=Random.bool();

			users.push(user);
		}
		var start=Date.now().getTime();
		
		for (i in 0...10000){
			for (user in users){
				var result="";
				result+=user.username+"\t";
				result+=user.password+"\t";
				result+=user.age+"\t";
				result+=user.confirmationId+"\t";
				result+=user.email+"\t";
				result+=user.remember+"\t";
				
			}
		}
		var end=Date.now().getTime();
		Sys.println(Std.format("Static: ${end-start} ms"));
		






		var rttiString  = untyped Type.getClass(new Person()).__rtti;
		
        var rtti = Xml.parse(rttiString);
		
		start=Date.now().getTime();
		var fieldNames=new Array<String>();
		var fields=rtti.firstElement().elements();		
		for (field in fields) {
    		if (field.nodeName!="implements" && field.nodeName!="new" && field.nodeName!="meta") 
				fieldNames.push(field.nodeName);
		}

		var result="";
		for (i2 in 0...10000) {
			for (user in users){
				result="!!";
				
				for (field in fieldNames) {
	        		result+=Reflect.field(user,field)+"\t";
				}
				//Sys.println("\t"+result);
			}
		}

		end=Date.now().getTime();
		Sys.println(Std.format("Reflection: ${end-start} ms"));





		var start=Date.now().getTime();
		
		var result="";
		for (i2 in 0...10000) {
			for (user in users){
				result="!!";
					
				for (field in Person.introspector.fields) {
	        		result+=field.get(user)+"\t";
				}
				
			}
		}

		var end=Date.now().getTime();
		Sys.println(Std.format("Introspection: ${end-start} ms"));

		

	}	

	public function testValidatorsCreation() {
		Assert.equals("thx.validation.StringLengthValidator",Type.getClassName(Type.getClass(Person.introspector.password.meta.someMeta[0].validation)));
		
	}



}

