import java.lang.reflect.Array ;

public abstract class RJavaArrayIterator {

	protected int[] dimensions; 
	protected int nd ; 
	protected int[] index ;
	protected int[] dimprod ;
	protected Object array ;
	protected int increment; 
	protected int position ;
	protected int start ;
	
	public Object getArray(){
		return array ; 
	}
	
	/**
	 * @return the class name of the array
	 */
	public String getArrayClassName(){
		return array.getClass().getName();
	}
	
	public int[] getDimensions(){
		return dimensions; 
	}
	
	public RJavaArrayIterator(){
		dimensions = null; 
		index = null ;
		dimprod = null ;
		array = null ;
	}
	
	public RJavaArrayIterator(int[] dimensions){
		this.dimensions = dimensions ; 
		nd = dimensions.length ;
		if( nd > 1){
			index = new int[ nd-1 ] ;
			dimprod = new int[ nd-1 ] ;
			for( int i=0; i<(nd-1); i++){
				index[i] = 0 ;
				dimprod[i] = (i==0) ? dimensions[i] : ( dimensions[i]*dimprod[i-1] );
				increment = dimprod[i] ;
			}
		}
		position = 0 ;
		start = 0; 
	}
	public RJavaArrayIterator(int d1){
		this( new int[]{ d1} ) ;
	}
	
	protected Object next( ){
		
		/* get the next array and the position of the first elemtn in the flat array */
		Object o = array ;
		for( int i=0; i<index.length; i++){
			o = Array.get( o, index[i] ) ;
			if( i == 0 ) {
				start = index[i]; 
			} else {
				start += index[i] * dimprod[i-1] ;
			}
		}
		
		/* increment the index */
		for( int i=index.length-1; i>=0; i--){
			if( (index[i] + 1) == dimensions[i] ){
				index[i] = 0 ; 
			} else{
				index[i] = index[i] + 1 ;
			}
		}
				
		position++ ;
		return o; 
	}
	
	protected boolean hasNext( ){
		return position < increment ;
	}
	
	
}
