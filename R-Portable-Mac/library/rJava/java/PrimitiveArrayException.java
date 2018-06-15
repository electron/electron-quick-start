/**
 * Generated when one tries to convert an arrays into 
 * a primitive array of the wrong type
 */
public class PrimitiveArrayException extends Exception{
	public PrimitiveArrayException(String type){
		super( "cannot convert to single dimension array of primitive type" + type ) ; 
	}
	
}
