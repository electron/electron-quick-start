// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

import java.lang.reflect.Array ; 

/** 
 * Utility class to deal with arrays
 */
public class ArrayWrapper extends RJavaArrayIterator {

	/**
	 * is this array rectangular
	 */ 
	private boolean isRect ;
	
	/**
	 * The type name of the objects stored
	 */
	private String typeName ;
	
	/**
	 * true if the array stores primitive types
	 */
	private boolean primitive ;
	
	private int length ; 
	
	/**
	 * Constructor
	 *
	 * @param array the array to check
	 * @throws NotAnArrayException if array is not an array
	 */
	public ArrayWrapper(Object array) throws NotAnArrayException {
		super( RJavaArrayTools.getDimensions(array) );
		this.array = array ;
		typeName = RJavaArrayTools.getObjectTypeName(array );
		primitive = RJavaArrayTools.isPrimitiveTypeName( typeName ) ;
		if( dimensions.length == 1){
			isRect = true ;
		} else{
			isRect = isRectangular_( array, 0 );
		}
		// reset the dimensions if the array is not rectangular
		if( !isRect ){
			dimensions = null ;
			length = -1; 
		} else{
			length = 1; 
			for( int i=0; i<dimensions.length; i++) {
				length *= dimensions[i] ;
			}
		}
	}
	
	// making java < 1.5 happy
	public ArrayWrapper(int x)      throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(boolean x)  throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(byte x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(long x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(short x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(double x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(char x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	public ArrayWrapper(float x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type") ; }
	
	
	/**
	 * @return true if the array is rectangular
	 */
	public boolean isRectangular( ){
		return isRect ;
	}
	
	/**
	 * Recursively check all dimensions to see if an array is rectangular
	 */
	private boolean isRectangular_(Object o, int depth){
		if( depth == dimensions.length ) return true ; 
		int n = Array.getLength(o) ;
		if( n != dimensions[depth] ) return false ;
		for( int i=0; i<n; i++){
			if( !isRectangular_(Array.get(o, i),  depth+1) ){
				return false;
			}
		}
		return true ;
	}
	
	/**
	 * @return the type name of the objects stored in the wrapped array
	 */
	public String getObjectTypeName(){
		return typeName; 
	}
	
	/** 
	 * @return true if the array contains java primitive types
	 */ 
	public boolean isPrimitive(){
		return primitive ; 
	}
	
	// {{{ flat_* methods
	
	// {{{ flat_int
	/**
	 * Flattens the array into a single dimensionned int array
	 */ 
	public int[] flat_int() throws PrimitiveArrayException,FlatException {
		
		if( ! "I".equals(typeName) ) throw new PrimitiveArrayException("int"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (int[])array ;
		} else{
			int[] payload = new int[length] ;
			
			int k; 
			while( hasNext() ){
				int[] current = (int[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ; 
		}
	}
	// }}}
	
	// {{{ flat_boolean
	/**
	 * Flattens the array into a single dimensionned boolean array
	 * 
	 */ 
	public boolean[] flat_boolean() throws PrimitiveArrayException,FlatException {
		
		if( ! "Z".equals(typeName) ) throw new PrimitiveArrayException("boolean"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (boolean[])array ;
		} else{
			boolean[] payload = new boolean[length] ;
			
			int k; 
			while( hasNext() ){
				boolean[] current = (boolean[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ;
		}
	}
	// }}}
	
	// {{{ flat_byte
	/**
	 * Flattens the array into a single dimensionned byte array
	 * 
	 */ 
	public byte[] flat_byte() throws PrimitiveArrayException,FlatException {
		
		if( ! "B".equals(typeName) ) throw new PrimitiveArrayException("byte"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (byte[])array ;
		} else{
			byte[] payload = new byte[length] ;
			int k; 
			while( hasNext() ){
				byte[] current = (byte[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ;  
		}
	}

	// }}}
	
	// {{{ flat_long
	/**
	 * Flattens the array into a single dimensionned long array
	 * 
	 */ 
	public long[] flat_long() throws PrimitiveArrayException,FlatException {
		
		if( ! "J".equals(typeName) ) throw new PrimitiveArrayException("long"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (long[])array ;
		} else{
			long[] payload = new long[length] ;
			int k; 
			while( hasNext() ){
				long[] current = (long[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ; 
		}
	}
	
	// }}}
	
	// {{{ flat_short
	/**
	 * Flattens the array into a single dimensionned short array
	 * 
	 */ 
		public short[] flat_short() throws PrimitiveArrayException,FlatException {
		
		if( ! "S".equals(typeName) ) throw new PrimitiveArrayException("short"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (short[])array ;
		} else{
			short[] payload = new short[length] ;
			int k; 
			while( hasNext() ){
				short[] current = (short[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ;
 		}
	}
// }}}

	// {{{ flat_double
	/**
	 * Flattens the array into a single dimensionned double array
	 * 
	 */ 
	public double[] flat_double() throws PrimitiveArrayException,FlatException {
		
		if( ! "D".equals(typeName) ) throw new PrimitiveArrayException("double"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (double[])array ;
		} else{
			double[] payload= new double[length] ;
			int k; 
			while( hasNext() ){
				double[] current = (double[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ;
 		}
	}

	// }}}
	
	// {{{ flat_char
	/**
	 * Flattens the array into a single dimensionned double array
	 * 
	 */ 
	public char[] flat_char() throws PrimitiveArrayException,FlatException {
		
		if( ! "C".equals(typeName) ) throw new PrimitiveArrayException("char"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (char[])array ;
		} else{
			char[] payload = new char[length] ;
			int k; 
			while( hasNext() ){
				char[] current = (char[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ; 
		}
	}
	
	// }}}

	// {{{ flat_float
	/**
	 * Flattens the array into a single dimensionned float array
	 * 
	 */ 
	public float[] flat_float() throws PrimitiveArrayException,FlatException {
		
		if( ! "F".equals(typeName) ) throw new PrimitiveArrayException("float"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (float[])array ;
		} else{
			float[] payload = new float[length] ;
			int k; 
			while( hasNext() ){
				float[] current = (float[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ; 
		}
	}
	
	// }}}
	
	// {{{ flat_Object
	public Object[] flat_Object() throws FlatException, ObjectArrayException {
		if( isPrimitive() ) throw new ObjectArrayException( typeName) ; 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (Object[])array ;
		} else{
			ClassLoader loader = array.getClass().getClassLoader() ;
			Class type = Object.class; 
			try{
				type = Class.forName( typeName, true, array.getClass().getClassLoader() );
			} catch( ClassNotFoundException e){}
			
			Object[] payload = (Object[])Array.newInstance( type,  length ) ; 
			int k; 
			while( hasNext() ){
				Object[] current = (Object[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = type.cast( current[j] );
				}
			}
			return payload ; 
		}
	}
	// }}}
	
	// {{{ flat_String
	/**
	 * Flattens the array into a single dimensionned String array
	 * 
	 */ 
	// this is technically not required as this can be handled
	// by flat_Object but this is slightly more efficient so ...
	public String[] flat_String() throws PrimitiveArrayException,FlatException {
		
		if( ! "java.lang.String".equals(typeName) ) throw new PrimitiveArrayException("java.lang.String"); 
		if( !isRect ) throw new FlatException(); 
		if( dimensions.length == 1 ){
			return (String[])array ;
		} else{
			String[] payload = new String[length] ;
			int k; 
			while( hasNext() ){
				String[] current = (String[])next() ;
				k = start ; 
				for( int j=0; j<current.length; j++, k+=increment){
					payload[k] = current[j] ;
				}
			}
			return payload ; 
		}
	}
	// }}}
	
	// }}}
	
}

