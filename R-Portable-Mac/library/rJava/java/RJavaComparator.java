import java.lang.Comparable ; 

/**
 * Utility class to compare two objects in the sense
 * of the java.lang.Comparable interface
 *
 */
public class RJavaComparator {
	           
	/**
	 * compares a and b in the sense of the java.lang.Comparable if possible
	 *
	 * <p>instances of the Number interface are treated specially, in order to 
	 * allow comparing Numbers of different classes, for example it is allowed 
	 * to compare a Double with an Integer. if the Numbers have the same class,
	 * they are compared normally, otherwise they are first converted to Doubles
	 * and then compared</p>
	 * 
	 * @param a an object
	 * @param b another object 
	 * 
	 * @return the result of <code>a.compareTo(b)</code> if this makes sense
	 * @throws NotComparableException if the two objects are not comparable
	 */
	public static int compare( Object a, Object b ) throws NotComparableException{
		int res ; 
		if( a.equals( b ) ) return 0 ;
		
		// treat Number s separately
		if( a instanceof Number && b instanceof Number && !( a.getClass() == b.getClass() ) ){
			Double _a = new Double( ((Number)a).doubleValue() );
			Double _b = new Double( ((Number)b).doubleValue() );
			return _a.compareTo( _b ); 
		}
		
		if( ! ( a instanceof Comparable ) ) throw new NotComparableException( a ); 
		if( ! ( b instanceof Comparable ) ) throw new NotComparableException( b ); 
		
		try{
			res = ( (Comparable)a ).compareTo( b ) ; 
		} catch( ClassCastException e){
			try{
				res = - ((Comparable)b).compareTo( a ) ;
			} catch( ClassCastException f){
				throw new NotComparableException( a, b ); 
			}
		}
		return res ;
	}
	
}

