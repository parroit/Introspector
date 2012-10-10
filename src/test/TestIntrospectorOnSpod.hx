package test;
import thx.validation.StringLengthValidator;
import test.PersonDb;



import utest.Assert;
import utest.Runner;
import utest.ui.Report;




class TestIntrospectorOnSpod{
	 public static function main() {
        var runner = new Runner();
        runner.addCase(new TestIntrospectorOnSpod());
        Report.create(runner);
        runner.run();
    }
        
    public function new(){}

	public function testSetter() {
		var user=new PersonDb();
		
		PersonDb.introspector.username.set(user,"Andrea Parodi");
		PersonDb.introspector.age.set(user,36);

		Assert.equals("Andrea Parodi",user.username);
		Assert.equals(36,user.age);

	}

	public function testGetter() {
		var user=new PersonDb();

		user.username="Andrea Parodi";
		user.age=36;
		

		Assert.equals("Andrea Parodi",PersonDb.introspector.username.get(user));
		Assert.equals(36,PersonDb.introspector.age.get(user));

	}


	public function testIndexedFields() {
		var user=new PersonDb();

		Assert.equals("username",PersonDb.introspector.fields.get("username").name);
		Assert.equals(Type.resolveClass("String"),PersonDb.introspector.fields.get("username").type);

	}


	public function testModelClassName() {
		
		Assert.equals("PersonDb",PersonDb.introspector.name);
		

	}

	public function testModelClass() {
		var clazz=Type.getClassName(Type.getClass(new PersonDb()));
		
		Assert.equals(clazz,Type.getClassName(PersonDb.introspector.type));
		

	}

	public function testMetadata() {
		
		Assert.equals("Person name",PersonDb.introspector.username.meta.someMeta[0].title);
		Assert.equals("Your age",PersonDb.introspector.age.meta.someMeta[0].description);

	}


	public function testTypeName() {
		

		Assert.equals(Type.getClass(""),PersonDb.introspector.username.type);
		Assert.equals(Type.resolveClass("Int"),PersonDb.introspector.age.type);

	}

	public function testClassTypeField() {
		

		Assert.equals("Parent",PersonDb.introspector.parent.meta.someMeta[0].title);
		

	}


	

	public function testValidatorsCreation() {
		Assert.equals("thx.validation.StringLengthValidator",Type.getClassName(Type.getClass(PersonDb.introspector.password.meta.someMeta[0].validation)));
		
	}



}

