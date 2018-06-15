/**
 * Generated when one tries to access an array of primitive
 * values as an array of Objects
 */
public class ObjectArrayException extends Exception{
	public ObjectArrayException(String type){
		super( "array is of primitive type : " + type ) ; 
	}
	
}
