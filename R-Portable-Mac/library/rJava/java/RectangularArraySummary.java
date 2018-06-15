// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

import java.lang.reflect.Array ; 

/** 
 * Utility class to extract something from a rectangular array
 */
public class RectangularArraySummary extends RJavaArrayIterator {
	
	private int length ; 
	
	private String typeName ;
	
	private boolean isprimitive ;
	
	private Class componentType ;
	
	/**
	 * Constructor
	 *
	 * @param array the array to check
	 * @throws NotAnArrayException if array is not an array
	 */
	public RectangularArraySummary(Object array, int[] dimensions) throws NotAnArrayException, NotComparableException {
		super( dimensions );
		this.array = array ;
		typeName = RJavaArrayTools.getObjectTypeName(array );
		isprimitive = RJavaArrayTools.isPrimitiveTypeName( typeName ) ;
		try{
			componentType = RJavaArrayTools.getClassForSignature( typeName , array.getClass().getClassLoader() ) ;
		} catch( ClassNotFoundException e){}
		checkComparableObjects() ;
	}
	
	public RectangularArraySummary(Object array, int length ) throws NotAnArrayException, NotComparableException{
		this( array, new int[]{ length } ); 
	}
	
	/** 
	 * Iterates over the array to find the minimum value
	 * (in the sense of the Comparable interface)
	 */
	public Object min( boolean narm ) {
		if( isprimitive ){
			return null ; // TODO :implement
		}
		Object smallest = null ;
		Object current ;
		boolean found = false ;
		
		if( dimensions.length == 1 ){
			return( min( (Object[])array, narm ) ) ;
		} else{
			
			/* need to iterate */
			while( hasNext() ){
				current = min( (Object[])next(), narm ) ;
				if( current == null ){
					if( !narm ) return null ;
				} else{
					if( !found ){
						smallest = current ;
						found = true ;
					} else if( smaller( current, smallest ) ) {
						smallest = current ;
					}					
				}
			}
			return smallest ;
		}
		
	}
	
	/** 
	 * Iterates over the array to find the maximum value
	 * (in the sense of the Comparable interface)
	 */
	public Object max( boolean narm )  {
		if( isprimitive ){
			return null ; // TODO :implement
		}
		
		Object biggest = null ;
		Object current ;
		boolean found = false ;
		
		if( dimensions.length == 1 ){
			return( max( (Object[])array, narm ) ) ;
		} else{
			
			/* need to iterate */
			while( hasNext() ){
				current = max( (Object[])next(), narm ) ;
				if( current == null ){
					if( !narm ) return null ;
				} else{
					if( !found ){
						biggest = current ;
						found = true ;
					} else if( bigger( current, biggest) ){ 
						biggest = current ;
					}					
				}
			}
			return biggest ;
		}
		
	}

	/** 
	 * Iterates over the array to find the range of the java array
	 * (in the sense of the Comparable interface)
	 */
	public Object[] range( boolean narm )  {
		if( isprimitive ){
			return null ; // TODO :implement
		}
		
		if( dimensions.length == 1 ){
			return( range( (Object[])array, narm ) ) ;
		} else{
			
			Object[] range = null ;
			Object[] current ;
			boolean found = false ;
		
			/* need to iterate */
			while( hasNext() ){
				current = range( (Object[])next(), narm ) ;
				if( current == null ){
					if( !narm ) return null ;
				} else{
					if( !found ){
						range = current ;
						found = true ;
					} else {
						if( bigger( current[1], range[1] ) ){
							range[1] = current[1] ;
						}
						if( smaller( current[0], range[0] ) ){
							range[0] = current[0] ;
						}	
						
					}
				}
			}
			return range ;
		}
		
	}

	
	
	
	/**
	 * returns the minimum (in the sense of Comparable) of the 
	 * objects in the one dimensioned array
	 */ 
	private static Object min( Object[] x, boolean narm ){
		
		int n = x.length ;
		Object smallest = null ; 
		Object current ;
		boolean found_min = false; 
		
		// find somewhere to start from ()
		for( int i=0; i<n; i++){
			current = x[i] ;
			if( current == null ){
				if( !narm ) return null ;
			} else{
				if( !found_min ){
					smallest = current ;
					found_min = true ;
				} else if( ((Comparable)smallest).compareTo(current) > 0 ) {
					smallest = current ;
				}
			}
		}
		return smallest ; 
		
	}
	
	/**
	 * returns the minimum (in the sense of Comparable) of the 
	 * objects in the one dimensioned array
	 */ 
	private static Object max( Object[] x, boolean narm ){
		
		int n = x.length ;
		Object biggest = null ; 
		Object current ;
		boolean found_min = false; 
		
		// find somewhere to start from ()
		for( int i=0; i<n; i++){
			current = x[i] ;
			if( current == null ){
				if( !narm ) return null ;
			} else{
				if( !found_min ){
					biggest = current ;
					found_min = true ;
				} else if( ((Comparable)biggest).compareTo(current) < 0 ) {
					biggest = current ;
				}
			}
		}
		return biggest ; 
		
	}

	/**
	 * returns the range (in the sense of Comparable) of the 
	 * objects in the one dimensioned array
	 */ 
	private static Object[] range( Object[] x, boolean narm ){
		
		int n = x.length ;
		Object[] range = (Object[])Array.newInstance( x.getClass().getComponentType(), 2) ; 
		Object current ;
		boolean found = false; 
		
		// find somewhere to start from ()
		for( int i=0; i<n; i++){
			current = x[i] ;
			if( current == null ){
				if( !narm ) return null ;
			} else{
				if( !found ){
					range[0] = current ;
					range[1] = current ;
					found = true ;
				} else {
					// max
					if( ((Comparable)range[1]).compareTo(current) < 0 ) {
						range[1] = current ;
					}
					// min
					if( ((Comparable)range[0]).compareTo(current) > 0 ) {
						range[0] = current ;
					}
					
				}
			}
		}
		return range ; 
		
	}
	
	public void checkComparableObjects() throws NotComparableException {
		if( ! containsComparableObjects() ) throw new NotComparableException( typeName ) ;
	}
	
	public boolean containsComparableObjects(){
		return Comparable.class.isAssignableFrom( componentType ) ;
	}
	
	// TODO : use these
	private static boolean smaller( Object x, Object y){
		return ( (Comparable)x ).compareTo(y) < 0 ;
	}
	private static boolean bigger( Object x, Object y){
		return ( (Comparable)x ).compareTo(y) > 0 ;
	}
	
	
}

