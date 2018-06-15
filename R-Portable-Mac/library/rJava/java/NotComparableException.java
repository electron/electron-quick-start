/**
 * Exception generated when two objects cannot be compared
 * 
 * Such cases happen when an object does not implement the Comparable 
 * interface or when the comparison produces a ClassCastException
 */
public class NotComparableException extends Exception{
	public NotComparableException(Object a, Object b){
		super( "objects of class " + a.getClass().getName() + 
			" and " + b.getClass().getName() + " are not comparable"  ) ;
	}
	public NotComparableException( Object o){
		this( o.getClass().getName() ) ;
	}
	
	public NotComparableException( Class cl){
		this( cl.getName() ) ;
	}
	
	public NotComparableException( String type ){
		super( "class " + type + " does not implement java.util.Comparable" ) ; 
	}
	
}
