
// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:
import java.lang.reflect.Constructor ;
import java.lang.reflect.* ;
import java.util.Map ;
import java.util.Set ;
import java.util.HashMap; 

public class RJavaTools_Test {

	private static class ExampleClass {
		public ExampleClass( Object o1, String o2, boolean o3, boolean o4){}
		public ExampleClass( Object o1, String o2, boolean o3){}
		public ExampleClass(){}
	}

	/* so that we can check about access to private fields and methods */
	private int bogus = 0 ; 
	private int getBogus(){ return bogus ; }
	private static int staticbogus ;
	private static int getStaticBogus(){ return staticbogus ; } 
	
	public int x = 0 ; 
	public static int static_x = 0; 
	public int getX(){ return x ; }
	public static int getStaticX(){ return static_x ; }
	public void setX( Integer x ){ this.x = x.intValue();  } 
	
	// {{{ main 
	public static void main( String[] args){
		
		try{
			runtests() ; 
		} catch( TestException e){
			fails( e ) ; 
			System.exit(1); 
		}
	}
	
	public static void runtests() throws TestException {
		System.out.println( "Testing RJavaTools.getConstructor" ) ;
			constructors() ;
			success() ; 
			
			System.out.println( "Testing RJavaTools.classHasField" ) ;
			classhasfield() ;
			success(); 
			
			System.out.println( "Testing RJavaTools.classHasMethod" ) ;
			classhasmethod() ;
			success() ;
			
			System.out.println( "Testing RJavaTools.classHasClass" ) ;
			classhasclass() ;
			success(); 
		
			System.out.println( "Testing RJavaTools.hasField" ) ;
			hasfield() ;
			success(); 
			
			System.out.println( "Testing RJavaTools.hasClass" ) ;
			hasclass() ;
			success(); 
			
			System.out.println( "Testing RJavaTools.getClass" ) ;
			getclass() ;
			success() ;
			
			System.out.println( "Testing RJavaTools.hasMethod" ) ;
			hasmethod() ;
			success() ;
		
			System.out.println( "Testing RJavaTools.isStatic" ) ;
			isstatic() ;
			success() ; 
			
			System.out.println( "Testing RJavaTools.getCompletionName" ) ;
			getcompletionname() ;
			success(); 
			
			System.out.println( "Testing RJavaTools.getFieldNames" ) ;
			getfieldnames() ;
			success() ;
			
			System.out.println( "Testing RJavaTools.getMethodNames" ) ;
			getmethodnames() ;
			success() ;
			
			System.out.println( "Testing RJavaTools.getStaticFields" ) ;
			getstaticfields() ;
			success() ;
		
			System.out.println( "Testing RJavaTools.getStaticMethods" ) ;
			getstaticmethods() ;
			success() ;

			System.out.println( "Testing RJavaTools.getStaticClasses" ) ;
			getstaticclasses() ;
			success() ;
	
			System.out.println( "Testing RJavaTools.invokeMethod" ) ;
			invokemethod() ;
			success() ;
			
			System.out.println( "Testing RJavaTools.getFieldTypeName" ) ;
			getfieldtypename(); 
			success() ;
			
			System.out.println( "Testing RJavaTools.getMethod" ) ;
			System.out.println( "NOT YET AVAILABLE" ) ;
			
			System.out.println( "Testing RJavaTools.newInstance" ) ;
			System.out.println( "NOT YET AVAILABLE" ) ;
			
	}
	
	// }}}

	// {{{ fails 
	private static void fails( TestException e ){
		System.err.println( "\n" ) ;
		e.printStackTrace() ;
		System.err.println( "FAILED" ) ; 
	}
	// }}}
	
	// {{{ success
	private static void success(){
		System.out.println( "PASSED" ) ;    
	}
	// }}}
	
	// {{{ @Test getFieldNames
	private static void getfieldnames() throws TestException{
		String[] names; 
		
		// {{{ getFieldNames(DummyPoint, false) -> c('x', 'y' )
		System.out.print( "    * getFieldNames(DummyPoint, false)" ) ;
		names = RJavaTools.getFieldNames( DummyPoint.class, false ) ;
		if( names.length != 2 ){
			throw new TestException( "getFieldNames(DummyPoint, false).length != 2" ) ;
		}
		for( int i=0; i<2; i++){
			if( !( "x".equals(names[i]) || "y".equals(names[i] ) ) ){
				throw new TestException( "getFieldNames(DummyPoint, false).length != c('x','y') " ) ;
			}
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// {{{ getFieldNames(Point, true ) --> character(0)
		System.out.print( "    * getFieldNames(DummyPoint, true )" ) ;
		names = RJavaTools.getFieldNames( DummyPoint.class, true ) ;
		if( names.length != 0 ){
			throw new TestException( "getFieldNames(DummyPoint, true ) != character(0)" ); 
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// {{{ getFieldNames(RJavaTools_Test, true ) --> static_x 
		System.out.print( "    * getFieldNames(RJavaTools_Test, true )" ) ;
		names = RJavaTools.getFieldNames( RJavaTools_Test.class, true ) ;
		if( names.length != 1 ){
			throw new TestException( "getFieldNames(RJavaTools_Test, true ).length != 1" ); 
		}
		if( ! "static_x".equals( names[0] ) ){
			throw new TestException( "getFieldNames(RJavaTools_Test, true )[0] != 'static_x' " );
		}
		System.out.println( " : ok " ) ; 
		// }}}
		
		// {{{ getFieldNames(RJavaTools_Test, false ) --> c('x', 'static_x') 
		System.out.print( "    * getFieldNames(RJavaTools_Test, false )" ) ;
		names = RJavaTools.getFieldNames( RJavaTools_Test.class, false ) ;
		if( names.length != 2 ){
			throw new TestException( "getFieldNames(RJavaTools_Test, false ).length != 2" ); 
		}
		for( int i=0; i<2; i++){
			if( ! ( "x".equals( names[i] ) || "static_x".equals(names[i]) ) ){
				throw new TestException( "getFieldNames(RJavaTools_Test, false ) != c('x', 'static_x') " );
			}
		}
		System.out.println( " : ok " ) ;
		// }}}
		
	}
	// }}}
	
	// {{{ @Test getMethodNames
	private static void getmethodnames() throws TestException{
		String[] names ; 
		String[] expected ;
		int cpt = 0;
		
		// {{{ getMethodNames(RJavaTools_Test, true) -> c('getStaticX()', 'main(', 'runtests' )
		System.out.print( "    * getMethodNames(RJavaTools_Test, true)" ) ;
		names = RJavaTools.getMethodNames( RJavaTools_Test.class, true ) ;
		if( names.length != 3 ){
			throw new TestException( "getMethodNames(RJavaTools_Test, true).length != 3 (" + names.length + ")" ) ;
		}
		expected= new String[]{ "getStaticX()", "main(", "runtests()" };
		cpt = 0; 
		for( int i=0; i<names.length; i++){
			for( int j=0; j<expected.length; j++ ){
				if( names[i].equals( expected[j] ) ){
					cpt++ ;
					break; // j loop
				}
			}
		}
		if( cpt != expected.length ){
			throw new TestException( "getMethodNames(RJavaTools_Test, true) != {'getStaticX()','main(', 'runtests()' }" + cpt ) ;
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// {{{ getMethodNames(Object, true) -> character(0) )
		System.out.print( "    * getMethodNames(Object, true)" ) ;
		names = RJavaTools.getMethodNames( Object.class, true ) ;
		if( names.length != 0 ){
			throw new TestException( "getMethodNames(Object, true).length != 0 (" + names.length + ")" ) ;
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// {{{ getMethodNames(RJavaTools_Test, false) %contains% { "getX()", "getStaticX()", "setX(", "main(" }
		System.out.print( "    * getMethodNames(RJavaTools_Test, false)" ) ;
		names = RJavaTools.getMethodNames( RJavaTools_Test.class, false ) ;
		cpt = 0;
		expected = new String[]{ "getX()", "getStaticX()", "setX(", "main(" }; 
		for( int i=0; i<names.length; i++){
			for( int j=0; j<expected.length; j++ ){
				if( names[i].equals( expected[j] ) ){
						cpt++; 
						break ; /* the j loop */
				}
			}
		}
		if( cpt != expected.length ){
			throw new TestException( "getMethodNames(RJavaTools_Test, false) did not contain expected methods " ) ; 
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		
	}
	// }}}
	
	// {{{ @Test getCompletionName
	private static void getcompletionname() throws TestException{
		
		Field f ; 
		Method m ; 
		String name ; 
		
		// {{{ getCompletionName( RJavaTools_Test.x )
		try{
			System.out.print( "    * getCompletionName(RJavaTools_Test.x)" ) ;
			f = RJavaTools_Test.class.getField("x") ;
			if( ! "x".equals(RJavaTools.getCompletionName( f ) ) ){
				throw new TestException( "getCompletionName(RJavaTools_Test.x) != 'x' " ) ; 
			}
			System.out.println( " == 'x' : ok " ) ;
		} catch( NoSuchFieldException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
		// {{{ getCompletionName( RJavaTools_Test.static_x )
		try{
			System.out.print( "    * getCompletionName(RJavaTools_Test.static_x)" ) ;
			f = RJavaTools_Test.class.getField("static_x") ;
			if( ! "static_x".equals(RJavaTools.getCompletionName( f ) ) ){
				throw new TestException( "getCompletionName(RJavaTools_Test.static_x) != 'static_x' " ) ; 
			}
			System.out.println( " == 'static_x' : ok " ) ;
		} catch( NoSuchFieldException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
		// {{{ getCompletionName( RJavaTools_Test.getX() )
		try{
			System.out.print( "    * getCompletionName(RJavaTools_Test.getX() )" ) ;
			m = RJavaTools_Test.class.getMethod("getX", (Class[])null ) ;
			if( ! "getX()".equals(RJavaTools.getCompletionName( m ) ) ){
				System.err.println( RJavaTools.getCompletionName( m ) );  
				throw new TestException( "getCompletionName(RJavaTools_Test.getX() ) != ''getX()' " ) ; 
			}
			System.out.println( " == 'getX()' : ok " ) ;
		} catch( NoSuchMethodException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
		// {{{ getCompletionName( RJavaTools_Test.setX( Integer ) )
		try{
			System.out.print( "    * getCompletionName(RJavaTools_Test.setX( Integer ) )" ) ;
			m = RJavaTools_Test.class.getMethod("setX", new Class[]{ Integer.class } ) ;
			if( ! "setX(".equals(RJavaTools.getCompletionName( m ) ) ){
				System.err.println( RJavaTools.getCompletionName( m ) );  
				throw new TestException( "getCompletionName(RJavaTools_Test.setX(Integer) ) != 'setX(' " ) ; 
			}
			System.out.println( " == 'setX(' : ok " ) ;
		} catch( NoSuchMethodException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
	}
	// }}}
	
	// {{{ @Test isStatic
	private static void isstatic() throws TestException{
		Field f ; 
		Method m ; 
		
		// {{{ isStatic(RJavaTools_Test.x) -> false
		try{
			System.out.print( "    * isStatic(RJavaTools_Test.x)" ) ;
			f = RJavaTools_Test.class.getField("x") ;
			if( RJavaTools.isStatic( f) ){
				throw new TestException( "isStatic(RJavaTools_Test.x) == true" ) ; 
			}
			System.out.println( " = false : ok " ) ;
		} catch( NoSuchFieldException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
		// {{{ isStatic(RJavaTools_Test.getX) -> true
		try{
			System.out.print( "    * isStatic(RJavaTools_Test.getX() )" ) ;
			m = RJavaTools_Test.class.getMethod("getX", (Class[])null ) ;
			if( RJavaTools.isStatic( m ) ){
				throw new TestException( "isStatic(RJavaTools_Test.getX() ) == false" ) ; 
			}
			System.out.println( " = false : ok " ) ;
		} catch( NoSuchMethodException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
		
		// {{{ isStatic(RJavaTools_Test.static_x) -> true
		try{
			System.out.print( "    * isStatic(RJavaTools_Test.static_x)" ) ;
			f = RJavaTools_Test.class.getField("static_x") ;
			if( ! RJavaTools.isStatic( f) ){
				throw new TestException( "isStatic(RJavaTools_Test.static_x) == false" ) ; 
			}
			System.out.println( " = true  : ok " ) ;
		} catch( NoSuchFieldException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}
	
		// {{{ isStatic(RJavaTools_Test.getStaticX) -> true
		try{
			System.out.print( "    * isStatic(RJavaTools_Test.getStaticX() )" ) ;
			m = RJavaTools_Test.class.getMethod("getStaticX", (Class[])null ) ;
			if( ! RJavaTools.isStatic( m ) ){
				throw new TestException( "isStatic(RJavaTools_Test.getStaticX() ) == false" ) ; 
			}
			System.out.println( " = true  : ok " ) ;
		} catch( NoSuchMethodException e){
			throw new TestException( e.getMessage() ) ;
		}
		// }}}

		/* classes */
		
		// {{{ isStatic(RJavaTools_Test.TestException) -> true 
		System.out.print( "    * isStatic(RJavaTools_Test.TestException )" ) ;
		Class cl = RJavaTools_Test.TestException.class ; 
		if( ! RJavaTools.isStatic( cl ) ){
			throw new TestException( "isStatic(RJavaTools_Test.TestException) == false" ) ; 
		}
		System.out.println( " = true  : ok " ) ;
		// }}}
		
		// {{{ isStatic(RJavaTools_Test.DummyNonStaticClass) -> false 
		System.out.print( "    * isStatic(RJavaTools_Test.DummyNonStaticClass )" ) ;
		cl = RJavaTools_Test.DummyNonStaticClass.class ; 
		if( RJavaTools.isStatic( cl ) ){
			throw new TestException( "isStatic(RJavaTools_Test.DummyNonStaticClass) == true" ) ; 
		}
		System.out.println( " = false : ok " ) ;
		// }}}
	}
	// }}}
	
  // {{{ @Test constructors 
	private static void constructors() throws TestException {
		/* constructors */ 
		Constructor cons ;
		boolean error ; 
		
		// {{{ getConstructor( String, null )
		System.out.print( "    * getConstructor( String, null )" ) ;
		try{
			cons = RJavaTools.getConstructor( String.class, (Class[])null, (boolean[])null ) ;
		} catch( Exception e ){
			throw new TestException( "getConstructor( String, null )" ) ; 
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// {{{ getConstructor( Integer, { String.class } ) 
		System.out.print( "    * getConstructor( Integer, { String.class } )" ) ;
		try{
			cons = RJavaTools.getConstructor( Integer.class, new Class[]{ String.class }, new boolean[]{false} ) ;
		} catch( Exception e){
			throw new TestException( "getConstructor( Integer, { String.class } )" ) ; 
		}
		System.out.println( " : ok " ) ;
		// }}}
		
		// disabled for now
		// // {{{ getConstructor( JButton, { String.class, ImageIcon.class } )
		// System.out.print( "    * getConstructor( JButton, { String.class, ImageIcon.class } )" ) ;
		// try{
		// 	cons = RJavaTools.getConstructor( JButton.class, 
		// 		new Class[]{ String.class, ImageIcon.class }, 
		// 		new boolean[]{ false, false} ) ;
		// } catch( Exception e){
		// 	throw new TestException( "getConstructor( JButton, { String.class, ImageIcon.class } )" ) ; 
		// }
		// System.out.println( " : ok " ) ;
		// // }}}
		
		// {{{ getConstructor( Integer, null ) -> exception 
		error = false ; 
		System.out.print( "    * getConstructor( Integer, null )" ) ;
		try{
			cons = RJavaTools.getConstructor( Integer.class, (Class[])null, (boolean[])null ) ;
		} catch( Exception e){
			 error = true ; 
		}
		if( !error ){
			throw new TestException( "getConstructor( Integer, null ) did not generate error" ) ;
		}
		System.out.println( " -> exception : ok " ) ;
		// }}}
		
		// disabled for now
		// // {{{ getConstructor( JButton, { String.class, JButton.class } ) -> exception
		// error = false ; 
		// System.out.print( "    * getConstructor( JButton, { String.class, JButton.class } )" ) ;
		// try{
		// 	cons = RJavaTools.getConstructor( JButton.class, 
		// 		new Class[]{ String.class, JButton.class }, 
		// 		new boolean[]{ false, false } ) ;
		// } catch( Exception e){
		// 	 error = true ; 
		// }
		// if( !error ){
		// 	throw new TestException( "getConstructor( JButton, { String.class, JButton.class } ) did not generate error" ) ;
		// }
		// System.out.println( " -> exception : ok " ) ;
		// // }}}


		Object o1 = null ;
		Object o2 = null ;
		ExampleClass foo = new ExampleClass(o1,(String)o2,false) ;
		// {{{ getConstructor( ExampleClass, { null, null, false } 
		error = false ;
		System.out.print( "    * getConstructor( ExampleClass, {Object.class, Object.class, boolean}) : " ) ;
		try{
			cons = RJavaTools.getConstructor( ExampleClass.class, 
				new Class[]{ Object.class, Object.class, Boolean.TYPE}, 
				new boolean[]{ true, true, false} );
		} catch(Exception e){
			error = true ;
			e.printStackTrace() ;
		}
		if( error ){
			throw new TestException( "getConstructor( ExampleClass, {Object.class, Object.class, boolean}) : exception " ) ;
		}
		System.out.println( " ok" ) ;
		// }}}
		
	
	}
	// }}}
	
	// {{{ @Test methods
	private static void methods() throws TestException{
		
	}
	// }}}
	
	// {{{ @Test hasfields
	private static void hasfield() throws TestException{
		
		DummyPoint p = new DummyPoint() ; 
		System.out.println( "    java> DummyPoint p = new DummyPoint()" ) ; 
		System.out.print( "    * hasField( p, 'x' ) " ) ; 
		if( !RJavaTools.hasField( p, "x" ) ){
			throw new TestException( " hasField( DummyPoint, 'x' ) == false" ) ;
		}
		System.out.println( " true : ok" ) ;
		
		System.out.print( "    * hasField( p, 'iiiiiiiiiiiii' ) " ) ; 
		if( RJavaTools.hasField( p, "iiiiiiiiiiiii" ) ){
			throw new TestException( " hasField( DummyPoint, 'iiiiiiiiiiiii' ) == true" ) ;
		}
		System.out.println( "  false : ok" ) ;
		
		/* testing a private field */
		RJavaTools_Test ob = new RJavaTools_Test(); 
		System.out.print( "    * testing a private field " ) ; 
		if( RJavaTools.hasField( ob, "bogus" ) ){
			throw new TestException( " hasField returned true on private field" ) ;
		}
		System.out.println( "  false : ok" ) ;
		
		
	}
	// }}}
	
	// {{{ @Test hasmethod
	private static void hasmethod() throws TestException{
		
		DummyPoint p = new DummyPoint() ; 
		System.out.println( "    java> DummyPoint p = new DummyPoint()" ) ; 
		System.out.print( "    * hasMethod( p, 'move' ) " ) ; 
		if( !RJavaTools.hasMethod( p, "move" ) ){
			throw new TestException( " hasField( DummyPoint, 'move' ) == false" ) ;
		}
		System.out.println( " true : ok" ) ;
		
		System.out.print( "    * hasMethod( p, 'iiiiiiiiiiiii' ) " ) ; 
		if( RJavaTools.hasMethod( p, "iiiiiiiiiiiii" ) ){
			throw new TestException( " hasMethod( Point, 'iiiiiiiiiiiii' ) == true" ) ;
		}
		System.out.println( "  false : ok" ) ;
		
		/* testing a private method */
		RJavaTools_Test ob = new RJavaTools_Test(); 
		System.out.print( "    * testing a private method " ) ; 
		if( RJavaTools.hasField( ob, "getBogus" ) ){
			throw new TestException( " hasMethod returned true on private method" ) ;
		}
		System.out.println( "  false : ok" ) ;

	}
	// }}}

	// {{{ @Test hasclass
	private static void hasclass() throws TestException{
		
		RJavaTools_Test ob = new RJavaTools_Test(); 
		
		System.out.print( "    * hasClass( RJavaTools_Test, 'TestException' ) " ) ; 
		if( ! RJavaTools.hasClass( ob, "TestException" ) ){
			throw new TestException( " hasClass( RJavaTools_Test, 'TestException' ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

		System.out.print( "    * hasClass( RJavaTools_Test, 'DummyNonStaticClass' ) " ) ; 
		if( ! RJavaTools.hasClass( ob, "DummyNonStaticClass" ) ){
			throw new TestException( " hasClass( RJavaTools_Test, 'DummyNonStaticClass' ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

	}
	// }}}
	
	// {{{ @Test hasclass
	private static void getclass() throws TestException{
		Class cl ; 
		
		System.out.print( "    * getClass( RJavaTools_Test, 'TestException', true ) " ) ; 
		cl = RJavaTools.getClass( RJavaTools_Test.class, "TestException", true ); 
		if( cl != RJavaTools_Test.TestException.class ){
			throw new TestException( " getClass( RJavaTools_Test, 'TestException', true ) != TestException" ) ;
		}
		System.out.println( "  : ok" ) ;

		System.out.print( "    * getClass( RJavaTools_Test, 'DummyNonStaticClass', true ) " ) ; 
		cl = RJavaTools.getClass( RJavaTools_Test.class, "DummyNonStaticClass", true ); 
		if( cl != null ){
			throw new TestException( " getClass( RJavaTools_Test, 'DummyNonStaticClass', true ) != null" ) ;
		}
		System.out.println( "  : ok" ) ;

		System.out.print( "    * getClass( RJavaTools_Test, 'DummyNonStaticClass', false ) " ) ; 
		cl = RJavaTools.getClass( RJavaTools_Test.class, "DummyNonStaticClass", false ); 
		if( cl != RJavaTools_Test.DummyNonStaticClass.class ){
			throw new TestException( " getClass( RJavaTools_Test, 'DummyNonStaticClass', true ) != null" ) ;
		}
		System.out.println( "  : ok" ) ;

	}
	// }}}
	
	// {{{ @Test classhasfield
	private static void classhasfield() throws TestException{

	}
	// }}}
	
	// {{{ @Test classhasclass
	private static void classhasclass() throws TestException{
		System.out.print( "    * classHasClass( RJavaTools_Test, 'TestException', true ) " ) ; 
		if( ! RJavaTools.classHasClass( RJavaTools_Test.class , "TestException", true ) ){
			throw new TestException( " classHasClass( RJavaTools_Test, 'TestException', true ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

		System.out.print( "    * classHasClass( RJavaTools_Test, 'DummyNonStaticClass', true ) " ) ; 
		if( RJavaTools.classHasClass( RJavaTools_Test.class , "DummyNonStaticClass", true ) ){
			throw new TestException( " classHasClass( RJavaTools_Test, 'DummyNonStaticClass', true ) == true" ) ;
		}
		System.out.println( "  false : ok" ) ;

		System.out.print( "    * classHasClass( RJavaTools_Test, 'DummyNonStaticClass', false ) " ) ; 
		if( ! RJavaTools.classHasClass( RJavaTools_Test.class , "DummyNonStaticClass", false ) ){
			throw new TestException( " classHasClass( RJavaTools_Test, 'DummyNonStaticClass', false ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

	}
	// }}}
	
	// {{{ @Test classhasmethod
	private static void classhasmethod() throws TestException{

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getX', false ) " ) ;
		if( ! RJavaTools.classHasMethod( RJavaTools_Test.class, "getX", false ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getX', false ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getStaticX', false ) " ) ;
		if( ! RJavaTools.classHasMethod( RJavaTools_Test.class, "getStaticX", false ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getStaticX', false ) == false" ) ;
		}
		System.out.println( "  true : ok" ) ;

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getX', true ) " ) ;
		if( RJavaTools.classHasMethod( RJavaTools_Test.class, "getX", true ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getX', true ) == true (non static method)" ) ;
		}
		System.out.println( "  false : ok" ) ;

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getStaticX', true ) " ) ;
		if( ! RJavaTools.classHasMethod( RJavaTools_Test.class, "getStaticX", true ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getStaticX', true ) == false (static)" ) ;
		}
		System.out.println( "  true : ok" ) ;

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getBogus', false ) " ) ;
		if( RJavaTools.classHasMethod( RJavaTools_Test.class, "getBogus", false ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getBogus', false ) == true (private method)" ) ;
		}
		System.out.println( "  false : ok" ) ;

		System.out.print( "    * classHasMethod( RJavaTools_Test, 'getStaticBogus', true ) " ) ;
		if( RJavaTools.classHasMethod( RJavaTools_Test.class, "getStaticBogus", true ) ){
			throw new TestException( " classHasMethod( RJavaTools_Test, 'getBogus', true ) == true (private method)" ) ;
		}
		System.out.println( "  false : ok" ) ;

	}
	// }}}
	
	// {{{ @Test getstaticfields
	private static void getstaticfields() throws TestException{
		Field[] f ;
		
		System.out.print( "    * getStaticFields( RJavaTools_Test ) " ) ;
		f = RJavaTools.getStaticFields( RJavaTools_Test.class ) ;
		if( f.length != 1 ){
			throw new TestException( " getStaticFields( RJavaTools_Test ).length != 1" ) ;
		}
		if( ! "static_x".equals( f[0].getName() ) ){
			throw new TestException( " getStaticFields( RJavaTools_Test )[0] != 'static_x'" ) ;
		}
		System.out.println( "  : ok" ) ;
		
		System.out.print( "    * getStaticFields( Object ) " ) ;
		f = RJavaTools.getStaticFields( Object.class ) ;
		if( f != null ){
			throw new TestException( " getStaticFields( Object ) != null" ) ;
		}
		System.out.println( "  : ok" ) ;
		
	}
	// }}}
	 
	// {{{ @Test getstaticmethods
	private static void getstaticmethods() throws TestException{
		Method[] m ;
		
		// {{{ getStaticMethods( RJavaTools_Test )
		System.out.print( "    * getStaticMethods( RJavaTools_Test ) " ) ;
		m = RJavaTools.getStaticMethods( RJavaTools_Test.class ) ;
		String[] expected = new String[]{ "getStaticX" , "main", "runtests" };
		int count = 0; 
		if( m.length != expected.length ){
			throw new TestException( " getStaticMethods( RJavaTools_Test ).length != 2" ) ;
		}
		for( int i=0; i<m.length; i++){
			for( int j=0; j<expected.length; j++ ){
				if( m[i].getName().equals( expected[j] ) ){
					count++; 
					break ; // the j loop
				}
			}
		}
		if( count != expected.length ){
			throw new TestException( " getStaticMethods( RJavaTools_Test ) != c('main', 'getStaticX', 'runtests' ) " ) ;
		}
		System.out.println( "  : ok" ) ;
		// }}}
		
		// {{{ getStaticMethods( Object )
		System.out.print( "    * getStaticMethods( Object ) " ) ;
		m = RJavaTools.getStaticMethods( Object.class ) ;
		if( m != null ){
			throw new TestException( " getStaticMethods( Object ) != null" ) ;
		}
		System.out.println( "  : ok" ) ;
		// }}}
		
	}
	// }}}
	
	// {{{ @Test getstaticclasses
	private static void getstaticclasses() throws TestException{
		Class[] clazzes ;
		
		// {{{ getStaticClasses( Object )
		System.out.print( "    * getStaticClasses( Object ) " ) ;
		clazzes = RJavaTools.getStaticClasses( Object.class ) ;
		if( clazzes != null ){
			throw new TestException( " getStaticClasses( Object ) != null" ) ;
		}
		System.out.println( "  : ok" ) ;
		// }}}
		
		// {{{ getStaticClasses( RJavaTools_Test )
		System.out.print( "    * getStaticClasses( RJavaTools_Test ) " ) ;
		clazzes = RJavaTools.getStaticClasses( RJavaTools_Test.class ) ;
		if( clazzes.length != 1 ){
			throw new TestException( " getStaticClasses( RJavaTools_Test ).length != 1" ) ;
		}
		if( clazzes[0] != RJavaTools_Test.TestException.class ){
			throw new TestException( " getStaticClasses( RJavaTools_Test ) != RJavaTools_Test.TestException" ) ;
		}
		System.out.println( "  : ok" ) ;
		// }}}
		
	}
	// }}}
	
	// {{{ @Test invokeMethod
	private static void invokemethod() throws TestException{
		
		// {{{ enforcing accessibility
		System.out.print( "  * testing enforcing accessibility (bug# 128)" ) ; 
		Map map = new HashMap(); 
		map.put( "x", "x" ) ; 
		Set set = map.entrySet() ; 
		try{
			Object o = RJavaTools.invokeMethod( set.getClass(), set, "iterator", (Object[])null, (Class[])null );
		} catch( Throwable e){
			throw new TestException( "not able to enforce accessibility" ) ; 
		}
		System.out.println( " : ok " ) ;
		// }}}
	}
	// }}}
	
	// {{{ @Test getFieldTypeName
	private static void getfieldtypename() throws TestException{
		System.out.print( "  * getFieldTypeName( DummyPoint, x )" ) ;
		String s = RJavaTools.getFieldTypeName( DummyPoint.class, "x" ) ;
		if( !s.equals("int") ){
			throw new TestException("getFieldTypeName( DummyPoint, x ) != int") ;
		}
		System.out.println( ": ok" ) ;
	}
	// }}}
	
	// {{{ TestException class
	public static class TestException extends Exception{
		public TestException( String message ){
			super( message ) ;
		}
	}
	// }}}
	
	// {{{ Dummy
	public class DummyNonStaticClass{}
	// }}}
	
}
