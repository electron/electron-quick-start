// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

/**
 * Test suite for ArrayWrapper 
 */
public class ArrayWrapper_Test {

	// {{{ main
	public static void main(String[] args ){
		try{
			runtests() ;
		} catch( TestException e){
			e.printStackTrace(); 
			System.exit(1); 
		}
		System.out.println( "\nALL PASSED\n" ) ; 
		System.exit( 0 ); 
	}
	// }}}
	
	// {{{ runtests
	public static void runtests() throws TestException {
		
		// {{{ multi dim array of primitives 
		
		// {{{ flat_int
		System.out.println( "flatten int[]" ); 
		flatten_int_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten int[][]" ); 
		flatten_int_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten int[][][]" ); 
		flatten_int_3(); 
		System.out.println( "PASSED" );
		// }}}
		
		// {{{ flat_boolean
		System.out.println( "flatten boolean[]" ); 
		flatten_boolean_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten boolean[][]" ); 
		flatten_boolean_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten boolean[][][]" ); 
		flatten_boolean_3(); 
		System.out.println( "PASSED" );
		// }}}
		
		// {{{ flat_byte
		System.out.println( "flatten byte[]" ); 
		flatten_byte_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten byte[][]" ); 
		flatten_byte_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten byte[][][]" ); 
		flatten_byte_3(); 
		System.out.println( "PASSED" );
		// }}}
		
		// {{{ flat_long
		System.out.println( "flatten long[]" ); 
		flatten_long_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten long[][]" ); 
		flatten_long_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten long[][][]" ); 
		flatten_long_3(); 
		System.out.println( "PASSED" );
		// }}}
		
		// {{{ flat_long
		System.out.println( "flatten short[]" ); 
		flatten_short_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten short[][]" ); 
		flatten_short_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten short[][][]" ); 
		flatten_short_3(); 
		System.out.println( "PASSED" );
		// }}}

		// {{{ flat_double
		System.out.println( "flatten double[]" ); 
		flatten_double_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten double[][]" ); 
		flatten_double_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten double[][][]" ); 
		flatten_double_3(); 
		System.out.println( "PASSED" );
		// }}}

		// {{{ flat_char
		System.out.println( "flatten char[]" ); 
		flatten_char_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten char[][]" ); 
		flatten_char_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten char[][][]" ); 
		flatten_char_3(); 
		System.out.println( "PASSED" );
		// }}}
		
		// {{{ flat_float
		System.out.println( "flatten float[]" ); 
		flatten_float_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten float[][]" ); 
		flatten_float_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten float[][][]" ); 
		flatten_float_3(); 
		System.out.println( "PASSED" );
		// }}}
		// }}}
		
		// {{{ multi dim array of Object
		// {{{ flat_String
		System.out.println( "flatten String[]" ); 
		flatten_String_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten String[][]" ); 
		flatten_String_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten String[][][]" ); 
		flatten_String_3(); 
		System.out.println( "PASSED" );
		// }}}
		
			// {{{ flat_String
		System.out.println( "flatten Point[]" ); 
		flatten_Point_1(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten Point[][]" ); 
		flatten_Point_2(); 
		System.out.println( "PASSED" ); 
		
		System.out.println( "flatten Point[][][]" ); 
		flatten_Point_3(); 
		System.out.println( "PASSED" );
		// }}}
	
		// }}}
	}
	//}}}
	
	// {{{ flat multi dimen array of java primitives
	
	// {{{ flatten_int_1
	private static void flatten_int_1() throws TestException{
		
		int[] o = new int[5] ;
		for( int i=0;i<5;i++) o[i] = i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( int[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(int[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(int[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("I") ){
			throw new TestException( "ArrayWrapper(int[]).getObjectTypeName() != 'I'" ) ;
		}
		System.out.println( " I : ok" ); 
		
		System.out.print( "  >> flat_int()" ) ;
		int[] flat;
		try{
			flat = wrapper.flat_int() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(int[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_int_2
	private static void flatten_int_2() throws TestException{
		
		int[][] o = RectangularArrayExamples.getIntDoubleRectangularArrayExample(); 
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( int[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(int[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(int[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("I") ){
			throw new TestException( "ArrayWrapper(int[][]).getObjectTypeName() != 'I'" ) ;
		}
		System.out.println( " I : ok" ); 
		
		System.out.print( "  >> flat_int()" ) ;
		int[] flat;
		try{
			flat = wrapper.flat_int() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(int[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_int_3
	private static void flatten_int_3() throws TestException{
		
		int[][][] o = RectangularArrayExamples.getIntTripleRectangularArrayExample(); 
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( int[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(int[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(int[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("I") ){
			throw new TestException( "ArrayWrapper(int[][][]).getObjectTypeName() != 'I'" ) ;
		}
		System.out.println( " I : ok" ); 
		
		System.out.print( "  >> flat_int()" ) ;
		int[] flat;
		try{
			flat = wrapper.flat_int() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(int[][][]) >> FlatException") ;
		}
		
		for( int i=0; i<30; i++){
			if( flat[i] != i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}

	
	
		
	// {{{ flatten_boolean_1
	private static void flatten_boolean_1() throws TestException{
		
		boolean[] o = new boolean[5] ; 
		boolean current = false; 
		for( int i=0;i<5;i++){
			o[i] = current ;
			current = !current ;
		}
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( boolean[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(boolean[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(boolean[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("Z") ){
			throw new TestException( "ArrayWrapper(boolean[]).getObjectTypeName() != 'Z'" ) ;
		}
		System.out.println( " Z : ok" ); 
		
		System.out.print( "  >> flat_boolean()" ) ;
		boolean[] flat;
		try{
			flat = wrapper.flat_boolean() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(int[]) >> FlatException") ;
		}
		
		current = false ;
		for( int i=0; i<5; i++){
			if( flat[i] != current ) throw new TestException( "flat[" + i + "] = " + flat [i] );
			current = !current ;
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}

	// {{{ flatten_boolean_2
	private static void flatten_boolean_2() throws TestException{
		
		boolean[][] o = RectangularArrayExamples.getBooleanDoubleRectangularArrayExample();
			
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( boolean[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(boolean[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(boolean[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("Z") ){
			throw new TestException( "ArrayWrapper(boolean[][]).getObjectTypeName() != 'Z'" ) ;
		}
		System.out.println( " Z : ok" ); 
		
		System.out.print( "  >> flat_boolean()" ) ;
		boolean[] flat;
		try{
			flat = wrapper.flat_boolean() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(boolean[][]) >> FlatException") ;
		}
		
		boolean current = false ;
		for( int i=0; i<10; i++){
			if( flat[i] != current ) throw new TestException( "flat[" + i + "] = " + flat [i] );
			current = !current ;
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_boolean_3
	private static void flatten_boolean_3() throws TestException{
		
		boolean[][][] o = RectangularArrayExamples.getBooleanTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( boolean[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(boolean[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(boolean[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("Z") ){
			throw new TestException( "ArrayWrapper(int[][][]).getObjectTypeName() != 'Z'" ) ;
		}
		System.out.println( " Z : ok" ); 
		
		System.out.print( "  >> flat_boolean()" ) ;
		boolean[] flat;
		try{
			flat = wrapper.flat_boolean() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(boolean[][][]) >> FlatException") ;
		}
		
		boolean current = false ;
		for( int i=0; i<30; i++){
			if( flat[i] != current ) throw new TestException( "flat[" + i + "] = " + flat [i] );
			current = !current ;
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}


	
	
	// {{{ flatten_byte_1
	private static void flatten_byte_1() throws TestException{
		
		byte[] o = new byte[5] ;
		for( int i=0;i<5;i++) o[i] = (byte)i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( byte[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(byte[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(byte[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("B") ){
			throw new TestException( "ArrayWrapper(byte[]).getObjectTypeName() != 'I'" ) ;
		}
		System.out.println( " B : ok" ); 
		
		System.out.print( "  >> flat_byte()" ) ;
		byte[] flat;
		try{
			flat = wrapper.flat_byte() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(byte[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (byte)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_byte_2
	private static void flatten_byte_2() throws TestException{
		
		byte[][] o = RectangularArrayExamples.getByteDoubleRectangularArrayExample();
		
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( byte[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(byte[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(byte[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("B") ){
			throw new TestException( "ArrayWrapper(byte[][]).getObjectTypeName() != 'B'" ) ;
		}
		System.out.println( " B : ok" ); 
		
		System.out.print( "  >> flat_byte()" ) ;
		byte[] flat;
		try{
			flat = wrapper.flat_byte() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(byte[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (byte)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_byte_3
	private static void flatten_byte_3() throws TestException{
		
		byte[][][] o = RectangularArrayExamples.getByteTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( byte[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(byte[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(byte[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("B") ){
			throw new TestException( "ArrayWrapper(int[][][]).getObjectTypeName() != 'B'" ) ;
		}
		System.out.println( " B : ok" ); 
		
		System.out.print( "  >> flat_byte()" ) ;
		byte[] flat;
		try{
			flat = wrapper.flat_byte() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(byte[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (byte)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
  
	
	// {{{ flatten_long_1
	private static void flatten_long_1() throws TestException{
		
		long[] o = new long[5] ;
		for( int i=0;i<5;i++) o[i] = (long)i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( long[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(long[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(long[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("J") ){
			throw new TestException( "ArrayWrapper(long[]).getObjectTypeName() != 'J'" ) ;
		}
		System.out.println( " J : ok" ); 
		
		System.out.print( "  >> flat_long()" ) ;
		long[] flat;
		try{
			flat = wrapper.flat_long() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(long[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (long)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_long_2
	private static void flatten_long_2() throws TestException{
		
		long[][] o = RectangularArrayExamples.getLongDoubleRectangularArrayExample();
		
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( long[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(long[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(long[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("J") ){
			throw new TestException( "ArrayWrapper(long[][]).getObjectTypeName() != 'J'" ) ;
		}
		System.out.println( " J : ok" ); 
		
		System.out.print( "  >> flat_long()" ) ;
		long[] flat;
		try{
			flat = wrapper.flat_long() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(long[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (long)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_long_3
	private static void flatten_long_3() throws TestException{
		
		long[][][] o = RectangularArrayExamples.getLongTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( long[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(long[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(long[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("J") ){
			throw new TestException( "ArrayWrapper(long[][][]).getObjectTypeName() != 'J'" ) ;
		}
		System.out.println( " J : ok" ); 
		
		System.out.print( "  >> flat_long()" ) ;
		long[] flat;
		try{
			flat = wrapper.flat_long() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(long[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (long)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}



	// {{{ flatten_short_1
	private static void flatten_short_1() throws TestException{
		
		short[] o = new short[5] ;
		for( int i=0;i<5;i++) o[i] = (short)i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( short[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(short[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(short[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("S") ){
			throw new TestException( "ArrayWrapper(long[]).getObjectTypeName() != 'S'" ) ;
		}
		System.out.println( " S : ok" ); 
		
		System.out.print( "  >> flat_short()" ) ;
		short[] flat;
		try{
			flat = wrapper.flat_short() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(short[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (double)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_short_2
	private static void flatten_short_2() throws TestException{
		
		short[][] o = RectangularArrayExamples.getShortDoubleRectangularArrayExample();
		
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( short[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(short[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(short[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("S") ){
			throw new TestException( "ArrayWrapper(short[][]).getObjectTypeName() != 'S'" ) ;
		}
		System.out.println( " S : ok" ); 
		
		System.out.print( "  >> flat_short()" ) ;
		short[] flat;
		try{
			flat = wrapper.flat_short() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(short[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (double)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_short_3
	private static void flatten_short_3() throws TestException{
		
		short[][][] o = RectangularArrayExamples.getShortTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( short[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(short[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(short[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("S") ){
			throw new TestException( "ArrayWrapper(short[][][]).getObjectTypeName() != 'S'" ) ;
		}
		System.out.println( " S : ok" ); 
		
		System.out.print( "  >> flat_short()" ) ;
		short[] flat;
		try{
			flat = wrapper.flat_short() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(short[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (double)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}

	

	// {{{ flatten_double_1
	private static void flatten_double_1() throws TestException{
		
		double[] o = new double[5] ;
		for( int i=0;i<5;i++) o[i] = i+0.0 ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( double[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(double[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(double[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("D") ){
			throw new TestException( "ArrayWrapper(double[]).getObjectTypeName() != 'D'" ) ;
		}
		System.out.println( " D : ok" ); 
		
		System.out.print( "  >> flat_double()" ) ;
		double[] flat;
		try{
			flat = wrapper.flat_double() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(double[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_double_2
	private static void flatten_double_2() throws TestException{
		
		double[][] o = RectangularArrayExamples.getDoubleDoubleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( double[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(double[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(double[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("D") ){
			throw new TestException( "ArrayWrapper(double[][]).getObjectTypeName() != 'D'" ) ;
		}
		System.out.println( " D : ok" ); 
		
		System.out.print( "  >> flat_double()" ) ;
		double[] flat;
		try{
			flat = wrapper.flat_double() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(double[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_double_3
	private static void flatten_double_3() throws TestException{
		
		double[][][] o = RectangularArrayExamples.getDoubleTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( double[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(double[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(double[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("D") ){
			throw new TestException( "ArrayWrapper(double[][][]).getObjectTypeName() != 'D'" ) ;
		}
		System.out.println( " D : ok" ); 
		
		System.out.print( "  >> flat_double()" ) ;
		double[] flat;
		try{
			flat = wrapper.flat_double() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(double[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	
	// {{{ flatten_char_1
	private static void flatten_char_1() throws TestException{
		
		char[] o = new char[5] ;
		for( int i=0;i<5;i++) o[i] = (char)i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( char[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(char[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(char[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("C") ){
			throw new TestException( "ArrayWrapper(char[]).getObjectTypeName() != 'C'" ) ;
		}
		System.out.println( " C : ok" ); 
		
		System.out.print( "  >> flat_char()" ) ;
		char[] flat;
		try{
			flat = wrapper.flat_char() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(char[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (char)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_char_2
	private static void flatten_char_2() throws TestException{
		
		char[][] o = RectangularArrayExamples.getCharDoubleRectangularArrayExample();
		
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( char[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(char[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(char[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("C") ){
			throw new TestException( "ArrayWrapper(char[][]).getObjectTypeName() != 'C'" ) ;
		}
		System.out.println( " C : ok" ); 
		
		System.out.print( "  >> flat_char()" ) ;
		char[] flat;
		try{
			flat = wrapper.flat_char() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(char[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_char_3
	private static void flatten_char_3() throws TestException{
		
		char[][][] o = RectangularArrayExamples.getCharTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( char[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(char[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(char[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("C") ){
			throw new TestException( "ArrayWrapper(char[][][]).getObjectTypeName() != 'C'" ) ;
		}
		System.out.println( " C : ok" ); 
		
		System.out.print( "  >> flat_char()" ) ;
		char[] flat;
		try{
			flat = wrapper.flat_char() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(char[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (char)i ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}

	

	// {{{ flatten_float_1
	private static void flatten_float_1() throws TestException{
		
		float[] o = new float[5] ;
		for( int i=0;i<5;i++) o[i] = (float)(i+0.0) ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( float[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(float[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(float[]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("F") ){
			throw new TestException( "ArrayWrapper(float[]).getObjectTypeName() != 'F'" ) ;
		}
		System.out.println( " F : ok" ); 
		
		System.out.print( "  >> flat_float()" ) ;
		float[] flat;
		try{
			flat = wrapper.flat_float() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(float[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_float_2
	private static void flatten_float_2() throws TestException{
		
		float[][] o = RectangularArrayExamples.getFloatDoubleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( float[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(float[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(float[][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("F") ){
			throw new TestException( "ArrayWrapper(float[][]).getObjectTypeName() != 'F'" ) ;
		}
		System.out.println( " F : ok" ); 
		
		System.out.print( "  >> flat_float()" ) ;
		float[] flat;
		try{
			flat = wrapper.flat_float() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(float[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( flat[i] != (i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_float_3
	private static void flatten_float_3() throws TestException{
		
		float[][][] o = RectangularArrayExamples.getFloatTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( float[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(float[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( !wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(float[][][]) not primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("F") ){
			throw new TestException( "ArrayWrapper(float[][][]).getObjectTypeName() != 'F'" ) ;
		}
		System.out.println( " F : ok" ); 
		
		System.out.print( "  >> flat_float()" ) ;
		float[] flat;
		try{
			flat = wrapper.flat_float() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(float[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( flat[i] != (float)(i+0.0) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
		
	// }}}

	// {{{ flat array of String
	
	// {{{ flatten_String_1
	private static void flatten_String_1() throws TestException{
		
		String[] o = new String[5] ;
		for( int i=0;i<5;i++) o[i] = ""+i ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( String[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(String[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(String[]) is primitive" ) ; 
		}
		System.out.println( " false : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("java.lang.String") ){
			throw new TestException( "ArrayWrapper(float[]).getObjectTypeName() != 'java.lang.String'" ) ;
		}
		System.out.println( " java.lang.String : ok" ); 
		
		System.out.print( "  >> flat_String()" ) ;
		String[] flat;
		try{
			flat = wrapper.flat_String() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(String[]) >> FlatException") ;
		}
		
		for( int i=0; i<5; i++){
			if( ! flat[i].equals(""+i) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_String_2
	private static void flatten_String_2() throws TestException{
		
		String[][] o = RectangularArrayExamples.getStringDoubleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( String[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(String[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(String[][]) is primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("java.lang.String") ){
			throw new TestException( "ArrayWrapper(float[][]).getObjectTypeName() != 'java.lang.String'" ) ;
		}
		System.out.println( " java.lang.String : ok" ); 
		
		System.out.print( "  >> flat_String()" ) ;
		String[] flat;
		try{
			flat = wrapper.flat_String() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(String[][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<10; i++){
			if( ! flat[i].equals( ""+i) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_String_3
	private static void flatten_String_3() throws TestException{
		
		String[][][] o = RectangularArrayExamples.getStringTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( String[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(String[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(String[][][]) is primitive" ) ; 
		}
		System.out.println( " true : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("java.lang.String") ){
			throw new TestException( "ArrayWrapper(String[][][]).getObjectTypeName() != 'java.lang.String'" ) ;
		}
		System.out.println( " java.lang.String : ok" ); 
		
		System.out.print( "  >> flat_String()" ) ;
		String[] flat;
		try{
			flat = wrapper.flat_String() ; 
		} catch( PrimitiveArrayException e){
			throw new TestException( "PrimitiveArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(String[][][]) >> FlatException") ;
		}
		
		
		for( int i=0; i<30; i++){
			if( !flat[i].equals( ""+i) ) throw new TestException( "flat[" + i + "] = " + flat [i] + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	// }}}
	
	// {{{ flat array of Point
	// {{{ flatten_Point_1
	private static void flatten_Point_1() throws TestException{
		
		DummyPoint[] o = new DummyPoint[5] ;
		for( int i=0;i<5;i++) o[i] = new DummyPoint(i,i) ;
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( DummyPoint[] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(DummyPoint[]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(DummyPoint[]) is primitive" ) ; 
		}
		System.out.println( " false : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("DummyPoint") ){
			throw new TestException( "ArrayWrapper(DummyPoint[]).getObjectTypeName() != 'DummyPoint'" ) ;
		}
		System.out.println( " DummyPoint : ok" ); 
		
		System.out.print( "  >> flat_Object()" ) ;
		DummyPoint[] flat ;
		try{
			flat = (DummyPoint[])wrapper.flat_Object() ;
		} catch( ObjectArrayException e){
			throw new TestException( "ObjectArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(DummyPoint[]) >> FlatException") ;
		}
		
		DummyPoint p ; 
		for( int i=0; i<5; i++){
			p = flat[i] ;
			if( p.x != i || p.y != i) throw new TestException( "flat[" + i + "].x = " + p.x + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// {{{ flatten_Point_2
	private static void flatten_Point_2() throws TestException{
		
		DummyPoint[][] o = RectangularArrayExamples.getDummyPointDoubleRectangularArrayExample(); 
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( DummyPoint[][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(DummyPoint[][]) >> NotAnArrayException ") ; 
		} 
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(DummyPoint[][]) is primitive" ) ; 
		}
		System.out.println( " false : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("DummyPoint") ){
			throw new TestException( "ArrayWrapper(DummyPoint[][]).getObjectTypeName() != 'DummyPoint'" ) ;
		}
		System.out.println( " DummyPoint : ok" ); 
		
		System.out.print( "  >> flat_Object()" ) ;
		DummyPoint[] flat;
		try{
			flat = (DummyPoint[])wrapper.flat_Object() ; 
		} catch( ObjectArrayException e){
			throw new TestException( "ObjectArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(DummyPoint[][]) >> FlatException") ;
		}
		
		DummyPoint p; 
		for( int i=0; i<10; i++){
			p = flat[i] ;
			if( p.x != i || p.y != i) throw new TestException( "flat[" + i + "].x = " + p.x + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
  // {{{ flatten_Point_3
	private static void flatten_Point_3() throws TestException{
		
		DummyPoint[][][] o = RectangularArrayExamples.getDummyPointTripleRectangularArrayExample();
		
		ArrayWrapper wrapper = null ; 
		System.out.print( "  >> new ArrayWrapper( DummyPoint[][][] ) " ); 
		try{
			wrapper = new ArrayWrapper(o); 
		} catch( NotAnArrayException e){
			throw new TestException("new ArrayWrapper(DummyPoint[][][]) >> NotAnArrayException ") ; 
		}
		System.out.println( "ok"); 
		
		System.out.print( "  >> isPrimitive()" ) ;
		if( wrapper.isPrimitive() ){
			throw new TestException( "ArrayWrapper(DummyPoint[][][]) is primitive" ) ; 
		}
		System.out.println( " false : ok" ); 
		
		System.out.print( "  >> getObjectTypeName()" ) ;
		if( !wrapper.getObjectTypeName().equals("DummyPoint") ){
			throw new TestException( "ArrayWrapper(DummyPoint[][][]).getObjectTypeName() != 'DummyPoint'" ) ;
		}
		System.out.println( " DummyPoint : ok" ); 
		
		System.out.print( "  >> flat_Object()" ) ;
		DummyPoint[] flat;
		try{         
			flat = (DummyPoint[])wrapper.flat_Object() ; 
		} catch( ObjectArrayException e){
			throw new TestException( "ObjectArrayException" ) ;
		} catch( FlatException e){
			throw new TestException("new ArrayWrapper(Object[][][]) >> FlatException") ;
		}
		
		DummyPoint p; 
		for( int i=0; i<30; i++){
			p = flat[i]; 
			if( p.x != i || p.y != i ) throw new TestException( "flat[" + i + "].x = " + p.x + "!=" + i); 
		}
		System.out.println( "  ok" ) ;
		
	}
	// }}}
	
	// }}}

	
}
