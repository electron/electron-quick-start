// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

/**
 * Test suite for RectangularArrayBuilder 
 */
public class RectangularArrayBuilder_Test {

	private static int[] dim1d = {10} ;
	private static int[] dim2d = {5,2} ;
	private static int[] dim3d = {5,3,2} ;
	
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
		
		// {{{ 1d 
		System.out.println( " >> 1 d" );
		System.out.print( "fill int[]" );     fill_int_1();     System.out.println( " :  ok" ); 
		System.out.print( "fill boolean[]" ); fill_boolean_1(); System.out.println( " :  ok" );
		System.out.print( "fill byte[]" ); fill_byte_1(); System.out.println( " :  ok" );
		System.out.print( "fill long[]" ); fill_long_1(); System.out.println( " :  ok" );
		System.out.print( "fill short[]" ); fill_short_1(); System.out.println( " :  ok" );
		System.out.print( "fill double[]" ); fill_double_1(); System.out.println( " :  ok" );
		System.out.print( "fill char[]" ); fill_char_1(); System.out.println( " :  ok" );
		System.out.print( "fill float[]" ); fill_float_1(); System.out.println( " :  ok" );
		System.out.print( "fill String[]" ); fill_String_1(); System.out.println( " :  ok" );
		System.out.print( "fill Point[]" ); fill_Point_1(); System.out.println( " :  ok" );
		// }}}
		
		// {{{ 2d 
		System.out.println( " >> 2 d" );
		System.out.print( "fill int[][]" );     fill_int_2();     System.out.println( " :  ok" ); 
		System.out.print( "fill boolean[][]" ); fill_boolean_2(); System.out.println( " :  ok" );
		System.out.print( "fill byte[][]" ); fill_byte_2(); System.out.println( " :  ok" );
		System.out.print( "fill long[][]" ); fill_long_2(); System.out.println( " :  ok" );
		System.out.print( "fill short[][]" ); fill_short_2(); System.out.println( " :  ok" );
		System.out.print( "fill double[][]" ); fill_double_2(); System.out.println( " :  ok" );
		System.out.print( "fill char[][]" ); fill_char_2(); System.out.println( " :  ok" );
		System.out.print( "fill float[][]" ); fill_float_2(); System.out.println( " :  ok" );
		System.out.print( "fill String[][]" ); fill_String_2(); System.out.println( " :  ok" );
		System.out.print( "fill Point[][]" ); fill_Point_2(); System.out.println( " :  ok" );
		// }}}
		
		// {{{ 3d 
		System.out.println( " >> 3 d" );
		System.out.print( "fill int[][][]" );     fill_int_3();     System.out.println( " :  ok" ); 
		System.out.print( "fill boolean[][][]" ); fill_boolean_3(); System.out.println( " :  ok" );
		System.out.print( "fill byte[][][]" ); fill_byte_3(); System.out.println( " :  ok" );
		System.out.print( "fill long[][][]" ); fill_long_3(); System.out.println( " :  ok" );
		System.out.print( "fill short[][][]" ); fill_short_3(); System.out.println( " :  ok" );
		System.out.print( "fill double[][][]" ); fill_double_3(); System.out.println( " :  ok" );
		System.out.print( "fill char[][][]" ); fill_char_3(); System.out.println( " :  ok" );
		System.out.print( "fill float[][][]" ); fill_float_3(); System.out.println( " :  ok" );
		System.out.print( "fill String[][][]" ); fill_String_3(); System.out.println( " :  ok" );
		System.out.print( "fill Point[][][]" ); fill_Point_3(); System.out.println( " :  ok" );
		// }}}
		
	}
	//}}}

	// {{{ 1d
	private static void fill_int_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( ints(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		int[] data = (int[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_boolean_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( booleans(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array boolean[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		boolean[] data = (boolean[])builder.getArray();
		boolean current = false; 
	
		for( int i=0; i<dim1d[0]; i++, current=!current){
				if( data[i] != current ){
					throw new TestException( "data["+i+"] != " + current ) ;
				}
		}
		
	}
	
	private static void fill_byte_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( bytes(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array byte[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		byte[] data = (byte[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_long_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( longs(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array long[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		long[] data = (long[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_short_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( shorts(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array short[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		short[] data = (short[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_double_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( doubles(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array double[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		double[] data = (double[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_char_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( chars(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array char[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		char[] data = (char[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_float_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( floats(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array float[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		float[] data = (float[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( data[i] != current ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}
	
	private static void fill_String_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( strings(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array String[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		String[] data = (String[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			if( !data[i].equals(current+"") ){
				throw new TestException( "data["+i+"] != " + current ) ;
			}
		}
		
	}

	private static void fill_Point_1() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( points(10), dim1d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array DummyPoint[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		DummyPoint[] data = (DummyPoint[])builder.getArray();
		int current = 0; 
		for( int i=0; i<dim1d[0]; i++, current++){
			DummyPoint p = data[i] ;
			if( p.x != current || p.y != current ){
				throw new TestException( "data["+i+"].x != " + current ) ;
			}
		}
		
	}
	
	// }}}
	
	// {{{ 2d 
	private static void fill_int_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( ints(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		int[][] data = (int[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_boolean_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( booleans(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array boolean[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		boolean[][] data = (boolean[][])builder.getArray();
		boolean current = false; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current=!current){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}
	
	private static void fill_byte_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( bytes(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array byte[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		byte[][] data = (byte[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_long_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( longs(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array long[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		long[][] data = (long[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_short_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( shorts(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array short[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		short[][] data = (short[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_double_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( doubles(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array double[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		double[][] data = (double[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_char_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( chars(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array char[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		char[][] data = (char[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

	private static void fill_float_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( floats(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array float[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		float[][] data = (float[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( data[i][j] != current ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}
	
	private static void fill_String_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( strings(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array String[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		String[][] data = (String[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				if( !data[i][j].equals(current+"") ){
					throw new TestException( "data["+i+"]["+j+"] != " + current ) ;
				}
			}
		}
		
	}

		private static void fill_Point_2() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( points(10), dim2d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Point[10]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		DummyPoint[][] data = (DummyPoint[][])builder.getArray();
		int current = 0; 
		for( int j=0; j<dim2d[1]; j++){
			for( int i=0; i<dim2d[0]; i++, current++){
				DummyPoint p = data[i][j] ;
				if( p.x != current || p.y != current ){
					throw new TestException( "data["+i+"]["+j+"].x != " + current ) ;
				}
			}
		}
		
	}

	// }}}

	// {{{ 3d
	private static void fill_int_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( ints(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array int[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		int[][][] data = (int[][][])builder.getArray();
		int current = 0;
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
		
	}

	private static void fill_boolean_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( booleans(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array boolean[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		boolean[][][] data = (boolean[][][])builder.getArray();
		boolean current = false; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current=!current){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}
	
	private static void fill_byte_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( bytes(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array byte[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		byte[][][] data = (byte[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_long_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( longs(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array long[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		long[][][] data = (long[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_short_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( shorts(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array short[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		short[][][] data = (short[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_double_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( doubles(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array double[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		double[][][] data = (double[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_char_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( chars(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array char[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		char[][][] data = (char[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_float_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( floats(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array float[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		float[][][] data = (float[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( data[i][j][k] != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}
	
	private static void fill_String_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( strings(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array String[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		String[][][] data = (String[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					if( !data[i][j][k].equals(current+"") ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"]  != " + current ) ;
					}
				}
			}
		}
	}

	private static void fill_Point_3() throws TestException{
		RectangularArrayBuilder builder = null; 
		try{
			builder = new RectangularArrayBuilder( points(30), dim3d );
		} catch( NotAnArrayException e){
			throw new TestException( "not an array Point[30]" ) ;
		} catch( ArrayDimensionException e){
			throw new TestException( "array dimensionexception" ) ;
		}
		
		DummyPoint[][][] data = (DummyPoint[][][])builder.getArray();
		int current = 0; 
		for( int k=0; k<dim3d[2] ; k++ ){
			for( int j=0; j<dim3d[1]; j++){
				for( int i=0; i<dim3d[0]; i++, current++){
					DummyPoint p = data[i][j][k] ;
					if( p.x != current || p.y != current ){
						throw new TestException( "data["+i+"]["+j+"]["+k+"].x != " + current ) ;
					}
				}
			}
		}
	}
	// }}}
	
	// {{{ 1d array generators 
	private static int[] ints(int n){
		int[] x = new int[n];
		for( int i=0; i<n; i++){
			x[i] = i ;
		}
		return x; 
	}
	
	private static boolean[] booleans(int n){
		boolean[] x = new boolean[n];
		boolean current = false; 
		for( int i=0; i<n; i++, current = !current){
			x[i] = current ;
		}
		return x; 
	}
	
	private static byte[] bytes(int n){
		byte[] x = new byte[n];
		for( int i=0; i<n; i++){
			x[i] = (byte)i ;
		}
		return x; 
	}
	
	private static long[] longs(int n){
		long[] x = new long[n];
		for( int i=0; i<n; i++){
			x[i] = (long)i ;
		}
		return x; 
	}
	
	private static short[] shorts(int n){
		short[] x = new short[n];
		for( int i=0; i<n; i++){
			x[i] = (short)i ;
		}
		return x; 
	}
	
	private static double[] doubles(int n){
		double[] x = new double[n];
		for( int i=0; i<n; i++){
			x[i] = 0.0 + i ;
		}
		return x; 
	}
	
	private static char[] chars(int n){
		char[] x = new char[n];
		for( int i=0; i<n; i++){
			x[i] = (char)i ;
		}
		return x; 
	}
	
	private static float[] floats(int n){
		float[] x = new float[n];
		for( int i=0; i<n; i++){
			x[i] = 0.0f + i ;
		}
		return x; 
	}
	
	private static String[] strings(int n){
		String[] x = new String[n];
		for( int i=0; i<n; i++){
			x[i] = ""+i ;
		}
		return x; 
	}
	
	private static DummyPoint[] points(int n){
		DummyPoint[] x = new DummyPoint[n];
		for( int i=0; i<n; i++){
			x[i] = new DummyPoint( i, i ) ;
		}
		return x; 
	}
	// }}}
	
}
