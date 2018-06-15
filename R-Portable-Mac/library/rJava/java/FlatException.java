
/**
 * Generated when one attemps to flatten an array that is not rectangular
 */
public class FlatException extends Exception{
	public FlatException(){
		super( "Can only flatten rectangular arrays" ); 
	}
}
