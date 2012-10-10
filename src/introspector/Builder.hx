package introspector;
import haxe.macro.Expr;
import haxe.macro.Context;
import thx.validation.StringLengthValidator;
import tink.macro.tools.TypeTools;
using Arrays;
class Builder {
    private static function getVarTypeName(field:Field){
        if (field.name==null && !field.access.exists(APublic)) return null;
        var type="";
        switch (field.kind){
            case FVar( t , e):
                
                type=getTypeName(t);
              

            case FProp( get , set , t, e):
              
                type=getTypeName(t);
               
            default:
                type=null;
        }
        return type;
    }

    private static function getTypeName(runtimeType:ComplexType){
        var type="";    
        switch (runtimeType){
            case TPath(t2) :
                //if (t2.pack!=null){
               
                    type=t2.pack.join(".");
                    if (type!=null && type!="")
                        type+=".";
                //}
                
                if (t2.name=="StdTypes" && t2.sub!=null && t2.sub!=""){
                    type+= t2.sub;
                } else
                    type+= t2.name;
                
                
                if (t2.params.length>0){
                    type+= "<";
                    for (param in t2.params)    
                        switch (param){
                            case TPExpr(expr):
                                switch(expr.expr){
                                    case EConst(c):    
                                        switch(c){
                                            case CInt(v):
                                                type+=Std.string(v);
                                            default:    
                                        }
                                        
                                    default:
                                }
                                
                            default:    
                        }
                        type+=">";
                }
               
            default:   
        }
        return type;    
    }

    //build class constructor body, constructor create all fields
    private static function getConstructorBody(clazzName:String,clazzFullName:String){
        var fields:Array<Field> = Context.getBuildFields();
        var body:String=Std.format('{super("$clazzName",Type.resolveClass("$clazzFullName"),"","");');
        for (field in fields){
            var type=getVarTypeName(field);
                       

          
            if (type!=null){
                
                var tt=Context.typeof(Context.parse("{ var _:" + type +"; _; }", Context.currentPos()));
                        
                tt=Context.follow(tt,false);
                            
                type=getTypeName(TypeTools.toComplex(tt,true));
                
                        
                body+=Std.format('\nthis.${field.name} = new introspector.FieldIntrospector<$clazzFullName,$type>(
                        "${field.name}",
                        Type.resolveClass("$type"),
                        true,
                        ${metaDynamification(field.meta)},
                        "${field.doc}",
                        inline function(instance:$clazzFullName,value:$type){
                            instance.${field.name} = value;
                        },
                        inline function(instance:$clazzFullName):$type{
                            return instance.${field.name};
                        }
                    );
                    this.fields.set( "${field.name}",this.${field.name});
                ');
            }
        
        }
        body+="}";    
        return body;
    }
    
    private static function elabMetaObject(metaFields: Array<{ field : String, expr : Expr }>){
        
        var results="{";
        for (param in metaFields){
            switch (param.expr.expr){
                case EObjectDecl(fields):
                    results+=Std.format("${param.field}:${elabMetaObject(fields)},");
                case EConst(c):
                    results+=Std.format("${param.field}:${elabMetaConst(c)},");
                    
                    
                default:


            }
                
        }
        results+="}";
        return results;
    }
    private static function elabMetaConst(const:Constant){
      
       switch(const){
        case CInt( v  ):
            return v;
        case CFloat( f  ):
            return f;
        case CString( s ):
            if (s.charAt(0)!="!")
                return '"'+s+'"';
            else
                return s.substring(1);
        default:
            Context.warning("unsupported constant type:"+const,Context.currentPos());
            return "";
       }
    }


    private static function elabMetaParams(metaParams: Array<Expr>){
       
        var results=[];
        for (param in metaParams){
            switch (param.expr){
                case EObjectDecl(params):
                    results.push(elabMetaObject(params));
                case EConst(c):
                    results.push(elabMetaConst(c));
                    
                default:
            }
                
        }
        return Std.string(results);
    }

    private static function metaDynamification(meta:Metadata){
        var metaSource="{";
        for (singleMeta in meta){
            metaSource+=Std.format("${singleMeta.name}:${elabMetaParams(singleMeta.params)}");
        }
        metaSource+="}";
        //trace(metaSource);
        return metaSource;
    }

    private static function addConstructor (introspectorFields:Array<Field>,clazzName:String,clazzFullName:String){
        var body=getConstructorBody(clazzName,clazzFullName);
        
       

        var tVoid=TPath({ pack : [], name : "Void", params : [], sub : null });
        var pos=Context.currentPos();

        introspectorFields.push({
            name : "new",
            access : [Access.APublic],
            kind : FieldType.FFun( {
                args : [],
                ret : tVoid,
                expr : Context.parse(body,pos),
                params : []
            } ),
            pos : pos
            
        });
    }


    





    private static function addFieldDeclarations(introspectorFields:Array<Field>){
       
        var fields:Array<Field> = Context.getBuildFields();
        var modelClazz=Context.getLocalClass().get();

        var tClazz=TPath({ pack :modelClazz.pack, name : modelClazz.name, params : [], sub : null });
        var pos = Context.currentPos();
        for (field in fields){
            if (field.name!=null && field.access.exists(APublic)){
               
                    var type;
                    switch (field.kind){
                        case FVar( t , e):
                            
                            type=t;
                        case FProp( get , set , t, e):
                            
                            type=t;
                        default:
                            type=null;
                    }
                    if (type!=null){
                        
                        var tt=Context.typeof(Context.parse("{ var _:" + getTypeName(type) +"; _; }", pos));
                        
                        tt=Context.follow(tt,false);
                        
                        type=TypeTools.toComplex(tt,true);
                        


                         
                        introspectorFields.push({
                            name : field.name,
                            access : [Access.APublic],
                            kind : FieldType.FVar(TPath({ pack : ["introspector"], name : "FieldIntrospector", params : [TPType(tClazz),TPType(type)], sub : null })),
                            pos : pos
                            
                        });
                       
                    }
            }
        }
      
        return introspectorFields;
    }



    @:macro public static function build() : Array<Field> {
       
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        
        var modelClazz=Context.getLocalClass().get();
        var clazzFullName=modelClazz.pack.join('.')+"."+modelClazz.name;

        //add fields to class
        var tClazz=TPath({ pack :modelClazz.pack, name : modelClazz.name, params : [], sub : null });
        var tString=TPath({ pack : [], name : "String", params : [], sub : null });
        var introspectorFields=new Array<Field>();
        

        
        addFieldDeclarations(introspectorFields);
        
        addConstructor(introspectorFields,modelClazz.name,clazzFullName);
        
        //define new type

        Context.defineType({
            pack : modelClazz.pack,
            name : modelClazz.name+"Introspector",
            pos : pos,
            meta : [],
            params : [],
            isExtern : false,
            kind : TDClass({
                 pack : ["introspector"],
                 name : "ClassIntrospector",
                 params : [TPType(tClazz)]
            }),
            fields : introspectorFields
        });



        var tIntrospector=TPath({ pack : modelClazz.pack, name : modelClazz.name+"Introspector", params : [], sub : null });

        //add static field to class with introspector instance
   
        fields.push({ 
        	name : "introspector",
         	doc : null, 
         	meta : [], 
         	access : [AStatic , APublic], 
         	kind : FVar(
                    tIntrospector,
                    Context.parse(Std.format("new ${clazzFullName}Introspector()"),Context.currentPos())
                ), 
         	pos : pos
        });
        return fields;
    }
}