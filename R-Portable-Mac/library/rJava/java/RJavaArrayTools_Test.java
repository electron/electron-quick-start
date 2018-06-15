// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

public class RJavaArrayTools_Test {
	
	// {{{ main 
	public static void main(String[] args){
		System.out.println( "Test suite for RJavaArrayTools" ) ;
		
		try{
			runtests() ; 
		} catch( TestException e){
			fails( e ) ; 
			System.exit(1); 
		}
		System.exit(0);
	}
	// }}}
	
	// {{{ runtests
	public static void runtests() throws TestException {
		System.out.println( "Test suite for RJavaArrayTools" ) ;
		
		System.out.println( "Testing RJavaArrayTools.isArray" ) ;
		isarray(); 
		success() ; 
		
		System.out.println( "Testing RJavaArrayTools.isRectangularArray" ) ;
		isrect();                                
		success() ; 
		
		System.out.println( "Testing RJavaArrayTools.getDimensionLength" ) ;
		getdimlength();                                
		success() ; 
		
		System.out.println( "Testing RJavaArrayTools.getDimensions" ) ;
		getdims();                                
		success() ; 
		
		System.out.println( "Testing RJavaArrayTools.getTrueLength" ) ;
		gettruelength();                                
		success() ;
		
		System.out.println( "Testing RJavaArrayTools.getObjectTypeName" ) ;
		gettypename();                                
		success() ;
		
		System.out.println( "Testing RJavaArrayTools.isPrimitiveTypeName" ) ;
		isprim();                                
		success() ;
	
		System.out.println( "Testing RJavaTools.rep" ) ;
		rep();                                
		success() ;
	
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

	// {{{ isarray
	private static void isarray() throws TestException {
		
		// {{{ int
		System.out.print( " isArray( int )" ) ;
		if( RJavaArrayTools.isArray( 0 ) ){
			throw new TestException( " isArray( int ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( " isArray( boolean )" ) ;
		if( RJavaArrayTools.isArray( true ) ){
			throw new TestException( " isArray( boolean ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( " isArray( byte )" ) ;
		if( RJavaArrayTools.isArray( (byte)0 ) ){
			throw new TestException( " isArray( byte ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( " isArray( long )" ) ;
		if( RJavaArrayTools.isArray( (long)0 ) ){
			throw new TestException( " isArray( long ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( " isArray( short )" ) ;
		if( RJavaArrayTools.isArray( (double)0 ) ){
			throw new TestException( " isArray( short ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( " isArray( double )" ) ;
		if( RJavaArrayTools.isArray( 0.0 ) ){
			throw new TestException( " isArray( double ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( " isArray( char )" ) ;
		if( RJavaArrayTools.isArray( 'a' ) ){
			throw new TestException( " isArray( char ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( " isArray( float )" ) ;
		if( RJavaArrayTools.isArray( 0.0f ) ){
			throw new TestException( " isArray( float ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ String
		System.out.print( " isArray( String )" ) ;
		if( RJavaArrayTools.isArray( "dd" ) ){
			throw new TestException( " isArray( String ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ int[]
		int[] x = new int[2] ;
		System.out.print( " isArray( int[] )" ) ;
		if( ! RJavaArrayTools.isArray( x ) ){
			throw new TestException( " !isArray( int[] ) " ) ;
		}
		System.out.println( " true : ok" ) ;
		// }}}
		
		// {{{ Object o = new double[2]
		Object o = new double[2]; 
		System.out.print( " isArray( double[]   (but declared as 0bject) )" ) ;
		if( ! RJavaArrayTools.isArray( o ) ){
			throw new TestException( " !isArray( Object o = new double[2]; ) " ) ;
		}
		System.out.println( " true : ok" ) ;
		// }}}
		
		// {{{ null
		System.out.print( " isArray( null )" ) ;
		if( RJavaArrayTools.isArray( null ) ){
			throw new TestException( " isArray( null) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		
	}
	// }}}
	
	// {{{ getdimlength
	private static void getdimlength() throws TestException{
		
		System.out.println( "  >> actual arrays" ) ;
		
		// {{{ int[] o = new int[10] ;
		int[] o = new int[10] ;
		System.out.print( "  int[] o = new int[10] ;" ) ;
		try{
			if( RJavaArrayTools.getDimensionLength( o ) != 1 ){
				throw new TestException( "getDimensionLength( int[10] ) != 1" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		}
		System.out.println( " 1 : ok " ); 
		// }}}           

		// {{{ int[] o = new int[0] ;
		o = new int[0] ;
		System.out.print( "  int[] o = new int[0] ;" ) ;
		try{
			if( RJavaArrayTools.getDimensionLength( o ) != 1 ){
				throw new TestException( "getDimensionLength( int[0] ) != 1" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[0]" ) ;
		}
		System.out.println( " 1 : ok " ); 
		// }}}           

		// {{{ Object[][] = new Object[10][10] ;
		Object[][] ob = new Object[10][10] ;
		System.out.print( "  new Object[10][10]" ) ;
		try{
			if( RJavaArrayTools.getDimensionLength( ob ) != 2 ){
				throw new TestException( "getDimensionLength( new Object[10][10] ) != 2" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10]" ) ;
		}
		System.out.println( " 2 : ok " ); 
		// }}}

		// {{{ Object[][] = new Object[10][10][10] ;
		Object[][][] obj = new Object[10][10][10] ;
		System.out.print( "  new Object[10][10][10]" ) ;
		try{
			if( RJavaArrayTools.getDimensionLength( obj ) != 3 ){
				throw new TestException( "getDimensionLength( new Object[10][10][3] ) != 3" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][3]" ) ;
		}
		System.out.println( " 3 : ok " ); 
		// }}}
		
		// {{{ Object 
		System.out.println( "  >> Object" ) ;
		
		System.out.print( "  new Double('10.2') " ) ;
		boolean ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( new Double("10.3") ) ;
		} catch( NotAnArrayException e){
			ok = true ; 
		}
		if( !ok ){
			throw new TestException( "getDimensionLength(Double) did not throw exception" ); 
		}
		System.out.println( " -> NotAnArrayException : ok " ); 
		// }}}
		
		// {{{ primitives
		System.out.println( "  >> Testing primitive types" ) ;
		// {{{ int
		
		System.out.print( "  getDimensionLength( int )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( 0 ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( int ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( "  getDimensionLength( boolean )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( true ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( boolean ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( "  getDimensionLength( byte )" ) ;
		ok = false;
		try{
			RJavaArrayTools.getDimensionLength( (byte)0 ) ;
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( byte ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( "  getDimensionLength( long )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( (long)0 ); 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok) throw new TestException( " getDimensionLength( long ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( "  getDimensionLength( short )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( (double)0 ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( short ) not throwing exception" );
		System.out.println( "  : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( "  getDimensionLength( double )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( 0.0 ); 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( double ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( "  getDimensionLength( char )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( 'a' ) ; 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( char ) not throwing exception " );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( "  getDimensionLength( float )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( 0.0f ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( float ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		// }}}

		// }}}
		
		// {{{ null 
		System.out.print( "  getDimensionLength( null )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensionLength( null ) ;
		} catch( NullPointerException e ){
			ok = true; 
		} catch( NotAnArrayException e ){
			throw new TestException("getDimensionLength( null ) throwing wrong kind of exception") ; 
		}
		if( !ok ) throw new TestException( " getDimensionLength( null ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		
		// }}}
	}
	// }}}
	
	// {{{ getdims
	private static void getdims() throws TestException{
		int[] res = null ;
		
		// {{{ actual arrays
		// {{{ int[] o = new int[10] ;
		int[] o = new int[10] ;
		System.out.print( "  int[] o = new int[10] ;" ) ;
		try{
			res = RJavaArrayTools.getDimensions( o ); 
			if( res.length != 1 ){
				throw new TestException( "getDimensions( int[10]).length != 1" );  
			}
			if( res[0] != 10 ){
				throw new TestException( "getDimensions( int[10])[0] != 10" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		}
		System.out.println( " c( 10 ) : ok " ); 
		// }}}           

		// {{{ Object[][] = new Object[10][10] ;
		Object[][] ob = new Object[10][10] ;
		System.out.print( "  new Object[10][10]" ) ;
		try{
			res = RJavaArrayTools.getDimensions( ob ) ;
			if( res.length != 2 ){
				throw new TestException( "getDimensions( Object[10][10] ).length != 2" ); 
			}
			if( res[0] != 10 ){
				throw new TestException( "getDimensions( Object[10][10] )[0] != 10" );
			}
			if( res[1] != 10 ){
				throw new TestException( "getDimensions( Object[10][10] )[1] != 10" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10]" ) ;
		}
		System.out.println( " c(10,10) : ok " ); 
		// }}}

		// {{{ Object[][] = new Object[10][10][10] ;
		Object[][][] obj = new Object[10][10][10] ;
		System.out.print( "  new Object[10][10][10]" ) ;
		try{
			res = RJavaArrayTools.getDimensions( obj ) ;
			if( res.length != 3 ){
				throw new TestException( "getDimensions( Object[10][10][10] ).length != 3" ); 
			}
			if( res[0] != 10 ){
				throw new TestException( "getDimensions( Object[10][10][10] )[0] != 10" );
			}
			if( res[1] != 10 ){
				throw new TestException( "getDimensions( Object[10][10][10] )[1] != 10" );
			}
			if( res[2] != 10 ){
				throw new TestException( "getDimensions( Object[10][10][10] )[1] != 10" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][10]" ) ;
		}
		System.out.println( " c(10,10,10) : ok " ); 
		// }}}
		// }}}

		// {{{ zeroes
		System.out.println( "  >> zeroes " ) ;
		
		// {{{ int[] o = new int[0] ;
		o = new int[0] ;
		System.out.print( "  int[] o = new int[0] ;" ) ;
		try{
			res = RJavaArrayTools.getDimensions( o ) ; 
			if( res.length != 1 ){
				throw new TestException( "getDimensions( int[0]).length != 1" ); 
			}
			if( res[0] != 0){
				throw new TestException( "getDimensions( int[0])[0] != 0" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[0]" ) ;
		}
		System.out.println( " c(0) : ok " ); 
		// }}}      
		
		// {{{ Object[][] = new Object[10][10][0] ;
		obj = new Object[10][10][0] ;
		System.out.print( "  new Object[10][10][0]" ) ;
		try{
			res = RJavaArrayTools.getDimensions( obj ) ;
			if( res.length != 3 ){
				throw new TestException( "getDimensions( Object[10][10][0] ).length != 3" ); 
			}
			if( res[0] != 10 ){
				throw new TestException( "getDimensions( Object[10][10][0] )[0] != 10" );
			}
			if( res[1] != 10 ){
				throw new TestException( "getDimensions( Object[10][10][0] )[1] != 10" );
			}
			if( res[2] != 0 ){
				throw new TestException( "getDimensions( Object[10][10][0] )[1] != 0" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][0]" ) ;
		}
		System.out.println( " c(10,10,0) : ok " ); 
		// }}}
		
		// {{{ Object[][] = new Object[10][0][10] ;
		obj = new Object[10][0][10] ;
		System.out.print( "  new Object[10][0][10]" ) ;
		try{
			res = RJavaArrayTools.getDimensions( obj ) ;
			if( res.length != 3 ){
				throw new TestException( "getDimensions( Object[10][0][0] ).length != 3" ); 
			}
			if( res[0] != 10 ){
				throw new TestException( "getDimensions( Object[10][0][0] )[0] != 10" );
			}
			if( res[1] != 0 ){
				throw new TestException( "getDimensions( Object[10][0][0] )[1] != 0" );
			}
			if( res[2] != 0 ){
				throw new TestException( "getDimensions( Object[10][0][0] )[1] != 0" );
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][0][10]" ) ;
		}
		System.out.println( " c(10,0,0) : ok " ); 
		// }}}
		
		// }}}

		// {{{ Object 
		System.out.println( "  >> Object" ) ;
		
		System.out.print( "  new Double('10.2') " ) ;
		boolean ok = false; 
		try{
			res = RJavaArrayTools.getDimensions( new Double("10.3") ) ;
		} catch( NotAnArrayException e){
			ok = true ; 
		}
		if( !ok ){
			throw new TestException( "getDimensions(Double) did not throw exception" ); 
		}
		System.out.println( " -> NotAnArrayException : ok " ); 
		// }}}
		
		// {{{ primitives
		System.out.println( "  >> Testing primitive types" ) ;
		// {{{ int
		
		System.out.print( "  getDimensions( int )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( 0 ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( int ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( "  getDimensions( boolean )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( true ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( boolean ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( "  getDimensions( byte )" ) ;
		ok = false;
		try{
			RJavaArrayTools.getDimensions( (byte)0 ) ;
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( byte ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( "  getDimensions( long )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( (long)0 ); 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok) throw new TestException( " getDimensions( long ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( "  getDimensions( short )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( (double)0 ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( short ) not throwing exception" );
		System.out.println( "  : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( "  getDimensions( double )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( 0.0 ); 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( double ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( "  getDimensions( char )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( 'a' ) ; 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( char ) not throwing exception " );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( "  getDimensions( float )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( 0.0f ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getDimensions( float ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		// }}}

		// }}}
		
		// {{{ null 
		System.out.print( "  getDimensions( null )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getDimensions( null ) ;
		} catch( NullPointerException e ){
			ok = true; 
		} catch( NotAnArrayException e ){
			throw new TestException("getDimensions( null ) throwing wrong kind of exception") ; 
		}
		if( !ok ) throw new TestException( " getDimensions( null ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		
		// }}}
		
	}
	// }}}
	
	// {{{ gettruelength
	private static void gettruelength() throws TestException{
		int res = 0 ;
		
		// {{{ actual arrays
		// {{{ int[] o = new int[10] ;
		int[] o = new int[10] ;
		System.out.print( "  int[] o = new int[10] ;" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( o ); 
			if( res != 10 ){
				throw new TestException( "getTrueLength( int[10]) != 10" );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		}
		System.out.println( " 10 : ok " ); 
		// }}}           

		// {{{ Object[][] = new Object[10][10] ;
		Object[][] ob = new Object[10][10] ;
		System.out.print( "  new Object[10][10]" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( ob ) ;
			if( res != 100 ){
				throw new TestException( "getTrueLength( Object[10][10] ) != 100" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10]" ) ;
		}
		System.out.println( " 100 : ok " ); 
		// }}}

		// {{{ Object[][] = new Object[10][10][10] ;
		Object[][][] obj = new Object[10][10][10] ;
		System.out.print( "  new Object[10][10][10]" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( obj ) ;
			if( res != 1000 ){
				throw new TestException( "getTrueLength( Object[10][10][10] ) != 1000" ); 
			}
			
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][10]" ) ;
		}
		System.out.println( " 1000 : ok " ); 
		// }}}
		// }}}

		// {{{ zeroes
		System.out.println( "  >> zeroes " ) ;
		
		// {{{ int[] o = new int[0] ;
		o = new int[0] ;
		System.out.print( "  int[] o = new int[0] ;" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( o ) ; 
			if( res != 0 ){
				throw new TestException( "getTrueLength( int[0]) != 0" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[0]" ) ;
		}
		System.out.println( " c(0) : ok " ); 
		// }}}      
		
		// {{{ Object[][] = new Object[10][10][0] ;
		obj = new Object[10][10][0] ;
		System.out.print( "  new Object[10][10][0]" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( obj ) ;
			if( res != 0 ){
				throw new TestException( "getTrueLength( Object[10][10][0] ) != 0" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][0]" ) ;
		}
		System.out.println( " 0 : ok " ); 
		// }}}
		
		// {{{ Object[][] = new Object[10][0][10] ;
		obj = new Object[10][0][10] ;
		System.out.print( "  new Object[10][0][10]" ) ;
		try{
			res = RJavaArrayTools.getTrueLength( obj ) ;
			if( res != 0){
				throw new TestException( "getTrueLength( Object[10][0][0] ) != 0" ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][0][10]" ) ;
		}
		System.out.println( " 0 : ok " ); 
		// }}}
		
		// }}}

		// {{{ Object 
		System.out.println( "  >> Object" ) ;
		
		System.out.print( "  new Double('10.2') " ) ;
		boolean ok = false; 
		try{
			res = RJavaArrayTools.getTrueLength( new Double("10.3") ) ;
		} catch( NotAnArrayException e){
			ok = true ; 
		}
		if( !ok ){
			throw new TestException( "getTrueLength(Double) did not throw exception" ); 
		}
		System.out.println( " -> NotAnArrayException : ok " ); 
		// }}}
		
		
		// {{{ primitives
		System.out.println( "  >> Testing primitive types" ) ;
		// {{{ int
		
		System.out.print( "  getTrueLength( int )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( 0 ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( int ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( "  getTrueLength( boolean )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( true ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( boolean ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( "  getTrueLength( byte )" ) ;
		ok = false;
		try{
			RJavaArrayTools.getTrueLength( (byte)0 ) ;
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( byte ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( "  getTrueLength( long )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( (long)0 ); 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok) throw new TestException( " getTrueLength( long ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( "  getTrueLength( short )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( (double)0 ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( short ) not throwing exception" );
		System.out.println( "  : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( "  getTrueLength( double )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( 0.0 ); 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( double ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( "  getTrueLength( char )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( 'a' ) ; 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( char ) not throwing exception " );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( "  getTrueLength( float )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( 0.0f ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getTrueLength( float ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		// }}}

		// }}}
		
		// {{{ null 
		System.out.print( "  getTrueLength( null )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getTrueLength( null ) ;
		} catch( NullPointerException e ){
			ok = true; 
		} catch( NotAnArrayException e ){
			throw new TestException("getTrueLength( null ) throwing wrong kind of exception") ; 
		}
		if( !ok ) throw new TestException( " getTrueLength( null ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		
		// }}}
		
	}
	// }}}
	
	// {{{ isRectangular
	private static void isrect() throws TestException {
						
		// {{{ int
		System.out.print( " isRectangularArray( int )" ) ;
		if( RJavaArrayTools.isRectangularArray( 0 ) ){
			throw new TestException( " isRectangularArray( int ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( " isRectangularArray( boolean )" ) ;
		if( RJavaArrayTools.isRectangularArray( true ) ){
			throw new TestException( " isRectangularArray( boolean ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( " isRectangularArray( byte )" ) ;
		if( RJavaArrayTools.isRectangularArray( (byte)0 ) ){
			throw new TestException( " isRectangularArray( byte ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( " isRectangularArray( long )" ) ;
		if( RJavaArrayTools.isRectangularArray( (long)0 ) ){
			throw new TestException( " isRectangularArray( long ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( " isRectangularArray( short )" ) ;
		if( RJavaArrayTools.isRectangularArray( (double)0 ) ){
			throw new TestException( " isRectangularArray( short ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( " isRectangularArray( double )" ) ;
		if( RJavaArrayTools.isRectangularArray( 0.0 ) ){
			throw new TestException( " isRectangularArray( double ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( " isRectangularArray( char )" ) ;
		if( RJavaArrayTools.isRectangularArray( 'a' ) ){
			throw new TestException( " isRectangularArray( char ) " );
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( " isRectangularArray( float )" ) ;
		if( RJavaArrayTools.isRectangularArray( 0.0f ) ){
			throw new TestException( " isRectangularArray( float ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}

		// {{{ String
		System.out.print( " isRectangularArray( String )" ) ;
		if( RJavaArrayTools.isRectangularArray( "dd" ) ){
			throw new TestException( " isRectangularArray( String ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ int[]
		int[] x = new int[2] ;
		System.out.print( " isRectangularArray( int[] )" ) ;
		if( ! RJavaArrayTools.isRectangularArray( x ) ){
			throw new TestException( " !isRectangularArray( int[] ) " ) ;
		}
		System.out.println( " true : ok" ) ;
		// }}}
		
		// {{{ Object o = new double[2]
		Object o = new double[2]; 
		System.out.print( " isRectangularArray( double[]   (but declared as 0bject) )" ) ;
		if( ! RJavaArrayTools.isRectangularArray( o ) ){
			throw new TestException( " !isRectangularArray( Object o = new double[2]; ) " ) ;
		}
		System.out.println( " true : ok" ) ;
		// }}}
		
		// {{{ null
		System.out.print( " isRectangularArray( null )" ) ;
		if( RJavaArrayTools.isRectangularArray( null ) ){
			throw new TestException( " isRectangularArray( null) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ 2d rectangular
		int[][] x2d = new int[3][4]; 
		System.out.print( " isRectangularArray( new int[3][4] )" ) ;
		if( ! RJavaArrayTools.isRectangularArray( x2d ) ){
			throw new TestException( " !isRectangularArray( new int[3][4] ) " ) ;
		}
		System.out.println( " true : ok" ) ;
		// }}}
		
		// {{{ 2d not rectangular
		int[][] x2d_not = new int[2][] ;
		x2d_not[0] = new int[2] ;
		x2d_not[1] = new int[3] ;
		
		System.out.print( " isRectangularArray( new int[2][2,4] )" ) ;
		if( RJavaArrayTools.isRectangularArray( x2d_not ) ){
			throw new TestException( " !isRectangularArray( new int[2][2,4] ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
		
		// {{{ 3d not rectangular
		int[][][] x3d_not = new int[1][][] ;
		x3d_not[0] = new int[2][];
		x3d_not[0][0] = new int[1] ;
		x3d_not[0][1] = new int[2] ;
		
		System.out.print( " isRectangularArray( new int[2][2][10,25] )" ) ;
		if( RJavaArrayTools.isRectangularArray( x3d_not ) ){
			throw new TestException( " !isRectangularArray( new int[2][2][10,25] ) " ) ;
		}
		System.out.println( " false : ok" ) ;
		// }}}
	}
	// }}}
	
	// {{{ getObjectTypeName
	private static void gettypename() throws TestException {
		String res ;
		
		// {{{ actual arrays
		// {{{ int[] o = new int[10] ;
		System.out.print( "  int[] o = new int[10] ;" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new int[1] ); 
			if( !res.equals("I") ){
				throw new TestException( "getObjectTypeName(int[]) != 'I' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		}
		System.out.println( " I : ok " ); 
		// }}}           

		// {{{ boolean[] ;
		System.out.print( "  boolean[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new boolean[1] ); 
			if( !res.equals("Z") ){
				throw new TestException( "getObjectTypeName(boolean[]) != 'Z' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array boolean[10]" ) ;
		}
		System.out.println( " Z : ok " ); 
		// }}}           
		
		// {{{ byte[] ;
		System.out.print( "  byte[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new byte[1] ); 
			if( !res.equals("B") ){
				throw new TestException( "getObjectTypeName(byte[]) != 'B' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array byte[10]" ) ;
		}
		System.out.println( " B : ok " ); 
		// }}}           
		
				// {{{ long[] ;
		System.out.print( "  long[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new long[1] ); 
			if( !res.equals("J") ){
				throw new TestException( "getObjectTypeName(long[]) != 'J' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array long[10]" ) ;
		}
		System.out.println( " J : ok " ); 
		// }}}           

		// {{{ short[] ;
		System.out.print( "  short[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new short[1] ); 
			if( !res.equals("S") ){
				throw new TestException( "getObjectTypeName(short[]) != 'S' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array short[10]" ) ;
		}
		System.out.println( " S : ok " ); 
		// }}}           
		
				// {{{ double[] ;
		System.out.print( "  double[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new double[1] ); 
			if( !res.equals("D") ){
				throw new TestException( "getObjectTypeName(double[]) != 'D' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array double[10]" ) ;
		}
		System.out.println( " D : ok " ); 
		// }}}           

				// {{{ char[] ;
		System.out.print( "  char[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new char[1] ); 
			if( !res.equals("C") ){
				throw new TestException( "getObjectTypeName(char[]) != 'C' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array char[10]" ) ;
		}
		System.out.println( " C : ok " ); 
		// }}}
		
				// {{{ float[] ;
		System.out.print( "  float[]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new float[1] ); 
			if( !res.equals("F") ){
				throw new TestException( "getObjectTypeName(float[]) != 'F' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array float[10]" ) ;
		}
		System.out.println( " F : ok " ); 
		// }}}           

		System.out.println("  >> multi dim primitive arrays" ) ;
		
		// {{{ int[] o = new int[10] ;
		System.out.print( "  int[][] ;" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new int[1][1] ); 
			if( !res.equals("I") ){
				throw new TestException( "getObjectTypeName(int[]) != 'I' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		}
		System.out.println( " I : ok " ); 
		// }}}           

		// {{{ boolean[] ;
		System.out.print( "  boolean[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new boolean[1][1] ); 
			if( !res.equals("Z") ){
				throw new TestException( "getObjectTypeName(boolean[]) != 'Z' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array boolean[10]" ) ;
		}
		System.out.println( " Z : ok " ); 
		// }}}           
		
		// {{{ byte[] ;
		System.out.print( "  byte[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new byte[1][1] ); 
			if( !res.equals("B") ){
				throw new TestException( "getObjectTypeName(byte[]) != 'B' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array byte[10]" ) ;
		}
		System.out.println( " B : ok " ); 
		// }}}           
		
				// {{{ long[] ;
		System.out.print( "  long[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new long[1][1] ); 
			if( !res.equals("J") ){
				throw new TestException( "getObjectTypeName(long[]) != 'J' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array long[10]" ) ;
		}
		System.out.println( " J : ok " ); 
		// }}}           

		// {{{ short[] ;
		System.out.print( "  short[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new short[1][1] ); 
			if( !res.equals("S") ){
				throw new TestException( "getObjectTypeName(short[]) != 'S' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array short[10]" ) ;
		}
		System.out.println( " S : ok " ); 
		// }}}           
		
				// {{{ double[] ;
		System.out.print( "  double[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new double[1][1] ); 
			if( !res.equals("D") ){
				throw new TestException( "getObjectTypeName(double[]) != 'D' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array double[10]" ) ;
		}
		System.out.println( " D : ok " ); 
		// }}}           

				// {{{ char[] ;
		System.out.print( "  char[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new char[1][1] ); 
			if( !res.equals("C") ){
				throw new TestException( "getObjectTypeName(char[]) != 'C' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array char[10]" ) ;
		}
		System.out.println( " C : ok " ); 
		// }}}
		
				// {{{ float[] ;
		System.out.print( "  float[][]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( new float[1][1] ); 
			if( !res.equals("F") ){
				throw new TestException( "getObjectTypeName(float[]) != 'F' " );  
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array float[10]" ) ;
		}
		System.out.println( " F : ok " ); 
		// }}}           

		
		
		// {{{ Object[][] = new Object[10][10] ;
		Object[][] ob = new Object[10][10] ;
		System.out.print( "  new Object[10][10]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( ob ) ;
			if( !res.equals("java.lang.Object") ){
				throw new TestException( "getObjectTypeName(Object[][]) != 'java.lang.Object' " ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10]" ) ;
		}
		System.out.println( " : ok " ); 
		// }}}

		// {{{ Object[][] = new Object[10][10][10] ;
		Object[][][] obj = new Object[10][10][10] ;
		System.out.print( "  new Object[10][10][10]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( obj ) ;
			if( !res.equals("java.lang.Object") ){
				throw new TestException( "getObjectTypeName( Object[10][10][10] ) != 'java.lang.Object' " ); 
			}
			
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][10]" ) ;
		}
		System.out.println( " 1000 : ok " ); 
		// }}}
		// }}}

		// {{{ zeroes
		System.out.println( "  >> zeroes " ) ;
		
		// {{{ int[] o = new int[0] ;
		int[] o = new int[0] ;
		System.out.print( "  int[] o = new int[0] ;" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( o ) ; 
			if( !res.equals("I") ){
				throw new TestException( "getObjectTypeName(int[0]) != 'I' " ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[0]" ) ;
		}
		System.out.println( " : ok " ); 
		// }}}
		
		// {{{ Object[][] = new Object[10][10][0] ;
		obj = new Object[10][10][0] ;
		System.out.print( "  new Object[10][10][0]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( obj ) ;
			if( !res.equals("java.lang.Object") ){
				throw new TestException( "getObjectTypeName( Object[10][10][0] ) != 'java.lang.Object' " ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][10][0]" ) ;
		}
		System.out.println( " : ok " ); 
		// }}}
		
		// {{{ Object[][] = new Object[10][0][10] ;
		obj = new Object[10][0][10] ;
		System.out.print( "  new Object[10][0][10]" ) ;
		try{
			res = RJavaArrayTools.getObjectTypeName( obj ) ;
			if( !res.equals("java.lang.Object") ){
				throw new TestException( "getObjectTypeName( Object[10][0][0] ) != 'java.lang.Object' " ); 
			}
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Object[10][0][10]" ) ;
		}
		System.out.println( " 0 : ok " ); 
		// }}}
		
		// }}}

		// {{{ Object 
		System.out.println( "  >> Object" ) ;
		
		System.out.print( "  new Double('10.2') " ) ;
		boolean ok = false; 
		try{
			res = RJavaArrayTools.getObjectTypeName( new Double("10.3") ) ;
		} catch( NotAnArrayException e){
			ok = true ; 
		}
		if( !ok ){
			throw new TestException( "getObjectTypeName(Double) did not throw exception" ); 
		}
		System.out.println( " -> NotAnArrayException : ok " ); 
		// }}}
		
		// {{{ primitives
		System.out.println( "  >> Testing primitive types" ) ;
		// {{{ int
		
		System.out.print( "  getObjectTypeName( int )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( 0 ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( int ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ boolean
		System.out.print( "  getObjectTypeName( boolean )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( true ) ; 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( boolean ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ byte
		System.out.print( "  getObjectTypeName( byte )" ) ;
		ok = false;
		try{
			RJavaArrayTools.getObjectTypeName( (byte)0 ) ;
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( byte ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}

		// {{{ long
		System.out.print( "  getObjectTypeName( long )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( (long)0 ); 
		} catch( NotAnArrayException e){
			ok = true; 
		}
		if( !ok) throw new TestException( " getObjectTypeName( long ) not throwing exception" );
		System.out.println( " ok" ) ;
		// }}}
		
		// {{{ short
		System.out.print( "  getObjectTypeName( short )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( (double)0 ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( short ) not throwing exception" );
		System.out.println( "  : ok" ) ;
		// }}}

		// {{{ double
		System.out.print( "  getObjectTypeName( double )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( 0.0 ); 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( double ) not throwing exception" );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ char
		System.out.print( "  getObjectTypeName( char )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( 'a' ) ; 
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( char ) not throwing exception " );
		System.out.println( " : ok" ) ;
		// }}}
		
		// {{{ float
		System.out.print( "  getObjectTypeName( float )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( 0.0f ) ;
		} catch( NotAnArrayException e ){
			ok = true; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( float ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		// }}}

		// }}}
		
		// {{{ null 
		System.out.print( "  getObjectTypeName( null )" ) ;
		ok = false; 
		try{
			RJavaArrayTools.getObjectTypeName( null ) ;
		} catch( NullPointerException e ){
			ok = true; 
		} catch( NotAnArrayException e ){
			throw new TestException("getObjectTypeName( null ) throwing wrong kind of exception") ; 
		}
		if( !ok ) throw new TestException( " getObjectTypeName( null ) not throwing exception " ) ;
		System.out.println( " : ok" ) ;
		
		// }}}

	}
	// }}}
	
	// {{{ isPrimitiveTypeName
	private static void isprim() throws TestException{
		
		System.out.print( " isPrimitiveTypeName( 'I' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("I") ) throw new TestException("I not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'Z' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("Z") ) throw new TestException("Z not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'B' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("B") ) throw new TestException("B not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'J' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("J") ) throw new TestException("J not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'S' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("S") ) throw new TestException("S not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'D' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("D") ) throw new TestException("D not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'C' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("C") ) throw new TestException("C not primitive") ; System.out.println( " true : ok " );
		System.out.print( " isPrimitiveTypeName( 'F' ) " ) ; if( !RJavaArrayTools.isPrimitiveTypeName("F") ) throw new TestException("F not primitive") ; System.out.println( " true : ok " );
		  
		System.out.print( " isPrimitiveTypeName( 'java.lang.Object' ) " ) ;
		if( RJavaArrayTools.isPrimitiveTypeName("java.lang.Object") ) throw new TestException("Object  primitive") ;
		System.out.println( " false : ok " );
	}
	// }}}
	
	// {{{ rep
	private static void rep() throws TestException{
		DummyPoint p = new DummyPoint(10, 10) ;
		
		DummyPoint[] res = null;
		System.out.print( "  rep( DummyPoint, 10)" ); 
		try{
			res = (DummyPoint[])RJavaArrayTools.rep( p, 10 );
		} catch( Throwable e){
			throw new TestException( "rep(DummyPoint, 10) failed" ) ;
		}
		if( res.length != 10 ){
			throw new TestException( "rep(DummyPoint, 10).length != 10" ) ;
		}
		if( res[5].getX() != 10.0 ){
			throw new TestException( "rep(DummyPoint, 10)[5].getX() != 10" ) ;
		}
		System.out.println( ": ok " );
		
	}
	/// }}}
		
}

