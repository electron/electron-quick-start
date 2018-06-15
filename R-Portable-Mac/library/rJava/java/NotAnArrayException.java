/**
 * Exception indicating that an object is not a java array
 */
public class NotAnArrayException extends Exception{
	public NotAnArrayException(Class clazz){
		super( "not an array : " + clazz.getName() ) ;
	}
	public NotAnArrayException(String message){
		super( message ) ;
	}
}
	
