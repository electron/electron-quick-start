// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

import java.lang.reflect.Array ; 

/**
 * Builds rectangular java arrays
 */
public class RectangularArrayBuilder extends RJavaArrayIterator {
	
	// {{{ constructors
	/**
	 * constructor
	 *
	 * @param payload one dimensional array
	 * @param dimensions target dimensions
	 * @throws NotAnArrayException if payload is not an array
	 */
	public RectangularArrayBuilder( Object payload, int[] dimensions) throws NotAnArrayException, ArrayDimensionException {
		
		super( dimensions ) ; 
		if( !RJavaArrayTools.isArray(payload) ){
			throw new NotAnArrayException( payload.getClass() ) ;
		}
		if( !RJavaArrayTools.isSingleDimensionArray(payload)){
			throw new ArrayDimensionException( "not a single dimension array : " + payload.getClass() ) ;
		}
		
		if( dimensions.length == 1 ){
			array = payload ;
		} else{
			
			String typeName = RJavaArrayTools.getObjectTypeName( payload ); 
			Class clazz = null ;
			try{
				clazz = RJavaArrayTools.getClassForSignature( typeName, payload.getClass().getClassLoader() );  
			} catch( ClassNotFoundException e){/* should not happen */}
			
			array = Array.newInstance( clazz , dimensions ) ;
		  if( typeName.equals( "I" ) ){
		  	fill_int( (int[])payload ) ;
		  } else if( typeName.equals( "Z" ) ){
		  	fill_boolean( (boolean[])payload ) ;
		  } else if( typeName.equals( "B" ) ){
		  	fill_byte( (byte[])payload ) ;
		  } else if( typeName.equals( "J" ) ){
		  	fill_long( (long[])payload ) ;
		  } else if( typeName.equals( "S" ) ){
		  	fill_short( (short[])payload ) ;
		  } else if( typeName.equals( "D" ) ){
		  	fill_double( (double[])payload ) ;
		  } else if( typeName.equals( "C" ) ){
		  	fill_char( (char[])payload ) ;
		  } else if( typeName.equals( "F" ) ){
		  	fill_float( (float[])payload ) ;
		  } else{
		  	fill_Object( (Object[])payload ) ;
		  }
			
		}
	}
	public RectangularArrayBuilder( Object payload, int length ) throws NotAnArrayException, ArrayDimensionException{
		this( payload, new int[]{ length } ) ;
	}

	// java < 1.5 kept happy
	public RectangularArrayBuilder(int x    , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public RectangularArrayBuilder(boolean x, int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public RectangularArrayBuilder(byte x   , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public RectangularArrayBuilder(long x   , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public RectangularArrayBuilder(short x  , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public RectangularArrayBuilder(double x , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public RectangularArrayBuilder(char x   , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public RectangularArrayBuilder(float x  , int[] dim ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }

	public RectangularArrayBuilder(int x    , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public RectangularArrayBuilder(boolean x, int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public RectangularArrayBuilder(byte x   , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public RectangularArrayBuilder(long x   , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public RectangularArrayBuilder(short x  , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public RectangularArrayBuilder(double x , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public RectangularArrayBuilder(char x   , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public RectangularArrayBuilder(float x  , int length ) throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }
	// }}}
	
	// {{{ fill_**
	private void fill_int( int[] payload ){
		int k; 
		while( hasNext() ){
			int[] current = (int[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}
	
	private void fill_boolean( boolean[] payload ){
		int k; 
		while( hasNext() ){
			boolean[] current = (boolean[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}
	
	private void fill_byte( byte[] payload ){
		int k; 
		while( hasNext() ){
			byte[] current = (byte[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}
	
	private void fill_long( long[] payload ){
		int k; 
		while( hasNext() ){
			long[] current = (long[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}

	private void fill_short( short[] payload ){
		int k; 
		while( hasNext() ){
			short[] current = (short[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}

	private void fill_double( double[] payload ){
		int k; 
		while( hasNext() ){
			double[] current = (double[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}

	private void fill_char( char[] payload ){
		int k; 
		while( hasNext() ){
			char[] current = (char[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}

	private void fill_float( float[] payload ){
		int k; 
		while( hasNext() ){
			float[] current = (float[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}
	
	private void fill_Object( Object[] payload ){
		int k; 
		while( hasNext() ){
			Object[] current = (Object[])next() ;
			k = start ; 
			for( int j=0; j<current.length; j++, k+=increment){
				current[j] = payload[k];
			}
		}
	}

	// }}}

}

