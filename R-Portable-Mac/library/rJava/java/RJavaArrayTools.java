// RJavaTools.java: rJava - low level R to java interface
//
// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:
//
// Copyright (C) 2009 - 2010	Simon Urbanek and Romain Francois
//
// This file is part of rJava.
//
// rJava is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// rJava is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with rJava.  If not, see <http://www.gnu.org/licenses/>.

import java.lang.reflect.Array ; 
import java.util.Map; 
import java.util.HashMap;
import java.util.Vector ;
import java.util.Arrays ;
import java.util.Iterator;

import java.lang.reflect.Method ;
import java.lang.reflect.InvocationTargetException ;

public class RJavaArrayTools {

	// TODO: maybe factor this out of this class
	private static Map primitiveClasses = initPrimitiveClasses() ;
	private static Map initPrimitiveClasses(){
		Map primitives = new HashMap(); 
		primitives.put( "I", Integer.TYPE ); 
		primitives.put( "Z", Boolean.TYPE );
		primitives.put( "B", Byte.TYPE );
		primitives.put( "J", Long.TYPE );
		primitives.put( "S", Short.TYPE );
		primitives.put( "D", Double.TYPE );
		primitives.put( "C", Character.TYPE );
		primitives.put( "F", Float.TYPE );
		return primitives; 
	}
	
	// {{{ getObjectTypeName
	/**
	 * Get the object type name of an multi dimensional array.
	 * 
	 * @param o object
	 * @throws NotAnArrayException if the object is not an array
	 */
	public static String getObjectTypeName(Object o) throws NotAnArrayException {
		Class o_clazz = o.getClass();
		if( !o_clazz.isArray() ) throw new NotAnArrayException( o_clazz ); 
		
		String cl = o_clazz.getName();
		return cl.replaceFirst("\\[+L?", "").replace(";", "") ; 
	}
	public static int getObjectTypeName(int x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public static int getObjectTypeName(boolean x) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public static int getObjectTypeName(byte x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public static int getObjectTypeName(long x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public static int getObjectTypeName(short x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public static int getObjectTypeName(double x)  throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public static int getObjectTypeName(char x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public static int getObjectTypeName(float x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }
	// }}}
	
	// {{{ makeArraySignature
	// TODO: test
	public static String makeArraySignature( String typeName, int depth ){
		StringBuffer buffer = new StringBuffer() ;
		for( int i=0; i<depth; i++){
			buffer.append( '[' ) ; 
		}
		buffer.append( typeName ); 
		if( ! isPrimitiveTypeName( typeName ) ){
			buffer.append( ';') ;
		}
		return buffer.toString(); 
	}
	// }}}
	
	// {{{ getClassForSignature
	public static Class getClassForSignature(String signature, ClassLoader loader) throws ClassNotFoundException {
		if( primitiveClasses.containsKey(signature) ){
			return (Class)primitiveClasses.get( signature ) ;
		}
		return Class.forName(signature, true, loader) ;
	}
	// }}}
	
	// {{{ isSingleDimensionArray
	public static boolean isSingleDimensionArray( Object o) throws NotAnArrayException{
		if( !isArray(o) ) throw new NotAnArrayException( o.getClass() ) ;
		
		String cn = o.getClass().getName() ; 
		if( cn.lastIndexOf('[') != 0 ) return false; 
		return true ; 
	}
	// }}}
	
	// {{{ isPrimitiveTypeName
	public static boolean isPrimitiveTypeName(String name){
		if( name.length() > 1 ) return false; 
		if( name.equals("I") ) return true ;
		if( name.equals("Z") ) return true ;
		if( name.equals("B") ) return true ;
		if( name.equals("J") ) return true ;
		if( name.equals("S") ) return true ;
		if( name.equals("D") ) return true ;
		if( name.equals("C") ) return true ;
		if( name.equals("F") ) return true ;
		return false; 
	}
	// }}}
	
	// {{{ isRectangularArray
	/**
	 * Indicates if o is a rectangular array
	 * 
	 * @param o an array
	 * @deprecated use new ArrayWrapper(o).isRectangular() instead
	 */
	public static boolean isRectangularArray(Object o) {
		if( !isArray(o) ) return false; 
		boolean res = false; 
		try{
			if( getDimensionLength( o ) == 1 ) return true ;
			res = ( new ArrayWrapper(o) ).isRectangular() ;
		} catch( NotAnArrayException e){
			res = false; 
		}
		return res ;
	}
	
	
	// thoose below make java < 1.5 happy and me unhappy ;-)
	public static boolean isRectangularArray(int x)      { return false ; }
	public static boolean isRectangularArray(boolean x)  { return false ; }
	public static boolean isRectangularArray(byte x)     { return false ; }
	public static boolean isRectangularArray(long x)     { return false ; }
	public static boolean isRectangularArray(short x)    { return false ; }
	public static boolean isRectangularArray(double x)   { return false ; }
	public static boolean isRectangularArray(char x)     { return false ; }
	public static boolean isRectangularArray(float x)    { return false ; }
	
	// }}}
	
	// {{{ getDimensionLength
	/** 
	 * Returns the number of dimensions of an array
	 *
	 * @param o an array
	 * @throws NotAnArrayException if this is not an array
	 */
	public static int getDimensionLength( Object o) throws NotAnArrayException, NullPointerException {
		if( o == null ) throw new NullPointerException( "array is null" ) ;
		Class clazz = o.getClass();
		if( !clazz.isArray() ) throw new NotAnArrayException(clazz) ;
		int n = 0; 
		while( clazz.isArray() ){
			n++ ; 
			clazz = clazz.getComponentType() ;
		}
		return n ; 
	}
	// thoose below make java < 1.5 happy and me unhappy ;-)
	public static int getDimensionLength(int x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public static int getDimensionLength(boolean x) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public static int getDimensionLength(byte x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public static int getDimensionLength(long x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public static int getDimensionLength(short x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public static int getDimensionLength(double x)  throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public static int getDimensionLength(char x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public static int getDimensionLength(float x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }
	// }}}                                                                                          
	
	// {{{ getDimensions
	/** 
	 * Returns the dimensions of an array
	 *
	 * @param o an array
	 * @throws NotAnArrayException if this is not an array
	 * @return the dimensions of the array or null if the object is null
	 */
	public static int[] getDimensions( Object o) throws NotAnArrayException, NullPointerException {
		if( o == null ) throw new NullPointerException( "array is null" )  ;
		
		Class clazz = o.getClass();
		if( !clazz.isArray() ) throw new NotAnArrayException(clazz) ;
		Object a = o ;
		
		int n = getDimensionLength( o ) ; 
		int[] dims = new int[n] ;
		int i=0;
		int current ; 
		while( clazz.isArray() ){
			current = Array.getLength( a ) ;
			dims[i] = current ;
			i++;
			if( current == 0 ){
				break ; // the while loop 
			} else {
				a = Array.get( a, 0 ) ;
				clazz = clazz.getComponentType() ;
			}
		}
		
		/* in case of premature stop, we fill the rest of the array with 0 */
		// this might not be true: 
		// Object[][] = new Object[0][10] will return c(0,0)
		while( i < dims.length){
			dims[i] = 0 ;
			i++ ;
		}
		return dims ; 
	}
	// thoose below make java < 1.5 happy and me unhappy ;-)
	public static int[] getDimensions(int x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public static int[] getDimensions(boolean x) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public static int[] getDimensions(byte x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public static int[] getDimensions(long x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public static int[] getDimensions(short x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public static int[] getDimensions(double x)  throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public static int[] getDimensions(char x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public static int[] getDimensions(float x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }
	// }}}                                                                                          
	
	// {{{ getTrueLength
	/** 
	 * Returns the true length of an array (the product of its dimensions)
	 *
	 * @param o an array
	 * @throws NotAnArrayException if this is not an array
	 * @return the number of objects in the array (the product of its dimensions).
	 */
	public static int getTrueLength( Object o) throws NotAnArrayException, NullPointerException {
		if( o == null ) throw new NullPointerException( "array is null" ) ;
		
		Class clazz = o.getClass();
		if( !clazz.isArray() ) throw new NotAnArrayException(clazz) ;
		Object a = o ;
		
		int len = 1 ;
		int i = 0; 
		while( clazz.isArray() ){
			len = len * Array.getLength( a ) ;
			if( len == 0 ) return 0 ; /* no need to go further */
			i++;
			a = Array.get( a, 0 ) ;
			clazz = clazz.getComponentType() ;
		}
		return len ; 
	}
	// thoose below make java < 1.5 happy and me unhappy ;-)
	public static int getTrueLength(int x)     throws NotAnArrayException { throw new NotAnArrayException("primitive type : int     ") ; }
	public static int getTrueLength(boolean x) throws NotAnArrayException { throw new NotAnArrayException("primitive type : boolean ") ; }
	public static int getTrueLength(byte x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : byte    ") ; }
	public static int getTrueLength(long x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : long    ") ; }
	public static int getTrueLength(short x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : short   ") ; }
	public static int getTrueLength(double x)  throws NotAnArrayException { throw new NotAnArrayException("primitive type : double  ") ; }
	public static int getTrueLength(char x)    throws NotAnArrayException { throw new NotAnArrayException("primitive type : char    ") ; }
	public static int getTrueLength(float x)   throws NotAnArrayException { throw new NotAnArrayException("primitive type : float   ") ; }
	// }}}                                                                                          
	
	// {{{ isArray
	/**
	 * Indicates if a java object is an array
	 * 
	 * @param o object
	 * @return true if the object is an array
	 * @deprecated use RJavaArrayTools#isArray
	 */
	public static boolean isArray(Object o){
		if( o == null) return false ; 
		return o.getClass().isArray() ; 
	}
	// thoose below make java < 1.5 happy and me unhappy ;-)
	public static boolean isArray(int x){ return false ; }
	public static boolean isArray(boolean x){ return false ; }
	public static boolean isArray(byte x){ return false ; }
	public static boolean isArray(long x){ return false ; }
	public static boolean isArray(short x){ return false ; }
	public static boolean isArray(double x){ return false ; }
	public static boolean isArray(char x){ return false ; }
	public static boolean isArray(float x){ return false ; }
	// }}}
	
	// {{{ ArrayDimensionMismatchException
	public static class ArrayDimensionMismatchException extends Exception {
		public ArrayDimensionMismatchException( int index_dim, int actual_dim ){
			super( "dimension of indexer (" + index_dim + ") too large for array (depth ="+ actual_dim+ ")") ;
		}
	}
	// }}}
	
	// {{{ get
	/**
	 * Gets a single object from a multi dimensional array
	 *
	 * @param array java array
	 * @param position
	 */
	public static Object get( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.get( getArray( array, position ), position[ position.length -1] ); 
	}
	
	public static int getInt( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getInt( getArray( array, position ), position[ position.length -1] ); 
	}
	public static boolean getBoolean( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getBoolean( getArray( array, position ), position[ position.length -1] ); 
	}
	public static byte getByte( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getByte( getArray( array, position ), position[ position.length -1] ); 
	}
	public static long getLong( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getLong( getArray( array, position ), position[ position.length -1] ); 
	}
	public static short getShort( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getShort( getArray( array, position ), position[ position.length -1] ); 
	}
	public static double getDouble( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getDouble( getArray( array, position ), position[ position.length -1] ); 
	}
	public static char getChar( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getChar( getArray( array, position ), position[ position.length -1] ); 
	}
	public static float getFloat( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return Array.getFloat( getArray( array, position ), position[ position.length -1] ); 
	}

	
	public static Object get( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return get( array, new int[]{position} ) ;
	}
	public static int getInt( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getInt( array, new int[]{position} ) ; 
	}
	public static boolean getBoolean( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getBoolean( array, new int[]{position} ) ; 
	}
	public static byte getByte( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getByte( array, new int[]{position} ) ; 
	}
	public static long getLong( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getLong( array, new int[]{position} ) ; 
	}
	public static short getShort( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getShort( array, new int[]{position} ) ; 
	}
	public static double getDouble( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getDouble( array, new int[]{position} ) ; 
	}
	public static char getChar( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getChar( array, new int[]{position} ) ;
	}
	public static float getFloat( Object array, int position ) throws NotAnArrayException, ArrayDimensionMismatchException {
		return getFloat( array, new int[]{position} ) ; 
	}
	
	private static void checkDimensions(Object array, int[] position) throws NotAnArrayException, ArrayDimensionMismatchException {
		int poslength = position.length ;
		int actuallength = getDimensionLength(array); 
		if( poslength > actuallength ){
			throw new ArrayDimensionMismatchException( poslength, actuallength ) ; 
		}
	}
	
	// }}}
	
	// {{{ set
	/**
	 * Replaces a single value of the array 
	 *
	 * @param array array 
	 * @param position index
	 * @param value the new value
	 * 
	 * @throws NotAnArrayException if array is not an array
	 * @throws ArrayDimensionMismatchException if the length of position is too big
	 */
	public static void set( Object array, int[] position, Object value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.set( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	
	/* primitive versions */
	public static void set( Object array, int[] position, int value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setInt( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, boolean value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setBoolean( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, byte value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setByte( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, long value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setLong( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, short value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setShort( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, double value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setDouble( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, char value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setChar( getArray( array, position ), position[ position.length - 1], value ) ;
	}
	public static void set( Object array, int[] position, float value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		Array.setFloat( getArray( array, position ), position[ position.length - 1], value ) ;
	}

	
	public static void set( Object array, int position, Object value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value ); 
	}
	public static void set( Object array, int position, int value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, boolean value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, byte value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, long value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, short value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, double value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, char value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}
	public static void set( Object array, int position, float value ) throws NotAnArrayException, ArrayDimensionMismatchException{
		set( array, new int[]{ position }, value );
	}


	
	private static Object getArray( Object array, int[] position ) throws NotAnArrayException, ArrayDimensionMismatchException{
		checkDimensions( array, position ) ;
		int poslength = position.length ;
		
		Object o = array ;
		int i=0 ;
		if( poslength > 1 ){
			while( i< (poslength-1) ){
					o = Array.get( o, position[i] ) ;
					i++ ;
			}
		}
		return o ;
	}
	
	// TODO: also have primitive types in value
	// }}}
	

	// {{{ unique
	// TODO: cannot use LinkedHashSet because it first was introduced in 1.4 
	//       and code in this area needs to work on 1.2 jvm
	public static Object[] unique( Object[] array ){
		int n = array.length ;
		boolean[] unique = new boolean[ array.length ];
		for( int i=0; i<array.length; i++){
			unique[i] = true ; 
		}
		
		Vector res = new Vector();
		boolean added ;
		for( int i=0; i<n; i++){
			if( !unique[i] ) continue ;
			Object current = array[i];
			added = false; 
			
			for( int j=i+1; j<n; j++){
				Object o_j = array[j] ;
				if( unique[j] && current.equals( o_j ) ){
					if( !added ){
						unique[i] = false; 
						res.add( current ); 
						added = true ;
					}
					unique[j] = false;
				}
			}
		}
		// build the array using newInstance so that it has the same
		// component type as the original array and not just Object
		Object[] res_array = (Object[])Array.newInstance( array.getClass().getComponentType(), res.size() ) ;
		res.toArray( res_array ); 
		return res_array ;
	}
	// }}}
	
	// {{{ duplicated
	public static boolean[] duplicated( Object[] array ){
		int n = array.length ;
		boolean[] duplicated = new boolean[ array.length ];
		for( int i=0; i<array.length; i++){
			duplicated[i] = false ; 
		}
		
		for( int i=0; i<n; i++){
			if( duplicated[i] ) continue ;
			Object current = array[i];
			
			for( int j=i+1; j<n; j++){
				Object o_j = array[j] ;
				if( !duplicated[j] && current.equals( o_j ) ){
					duplicated[j] = true;
				}
			}
		}
		
		return duplicated ;
	}	
	// }}}
	
	// {{{ anyDuplicated
	public static int anyDuplicated( Object[] array ){
		int n = array.length ;
		
		for( int i=0; i<n; i++){
			Object current = array[i];
			
			for( int j=i+1; j<n; j++){
				Object o_j = array[j] ;
				if( current.equals( o_j ) ){
					return j ;
				}
			}
		}
		
		return -1 ;
	}	
	// }}}
	
	// {{{ sort
	/**
	 * Returns a copy of the array where elements are sorted
	 *
	 * @param array array of Objects.  
	 * @param decreasing if true the sort is in decreasing order
	 * 
	 * @throws NotComparableException if the component type of the array does not
	 * implement the Comparable interface
	 */
	public static Object[] sort( Object[] array, boolean decreasing ) throws NotComparableException {
		Class ct = array.getClass().getComponentType() ;
		if( Comparable.class.isAssignableFrom( ct ) ){
			throw new NotComparableException( ct ) ; 
		}
		int n = array.length ;
		Object[] res = copy( array ) ; 
		Arrays.sort( res ) ;
		
		if( !decreasing ){
			return res ;
		} else{
			Object current ;
			int top = (res.length) / 2 ; 
			for( int i=0; i<top ; i++ ){
				current = res[i] ;
				res[ i ] = res[ n-i-1 ] ;
				res[ n-i-1 ] = current ; 
			}
		}
		return res ;
	}
	// }}}
	
	// {{{ rev
	/**
	 * Returns a copy of the input array with elements in
	 * reverse order
	 * 
	 * @param original input array
	 */
	public static Object[] rev( Object[] original ){
		int n = original.length ;
		Object[] copy = (Object[])Array.newInstance( original.getClass().getComponentType() , n ); 
		for( int i=0; i<n ; i++ ){
			copy[n-i-1] = original[i] ;
		}
		return copy ;
	}    
	// }}}
	    
	// {{{ copy
	public static Object[] copy( Object[] original ){
		int n = original.length ;
		Object[] copy = (Object[])Array.newInstance( original.getClass().getComponentType() , n ); 
		for( int i=0; i<n ; i++ ){
			copy[i] = original[i] ;
		}
		return copy ;
	}
	// }}}
	
	// {{{ getIterableContent
	public static Object[] getIterableContent( Iterable o){
		Vector v = new Vector(); 
		Iterator iterator = o.iterator(); 
		while( iterator.hasNext() ){
			v.add( iterator.next() ); 
		}
		return v.toArray(); 
	}
	// }}}
	
	// {{{ rep
	/**
	 * Creates a java array by cloning o several times
	 * 
	 * @param o object to clone
	 * @param size number of times to replicate the object
	 */
	public static Object[] rep( Object o, int size ) throws Throwable {
		Object[] res = (Object[])Array.newInstance( o.getClass(), size ) ;
		if( ! ( o instanceof Cloneable )){
			return res ;
		}
		
		Method m = getCloneMethod( o.getClass() ) ;
		boolean access = m.isAccessible() ; 
		m.setAccessible( true ) ;
		try{
			for( int i=0; i<size; i++){
				Object cloned = o.getClass().cast( m.invoke( o, (Object[])null ) );
				res[i] = cloned ;
			}
		} catch( IllegalAccessException e) {
			m.setAccessible( access );
			/* should not happen */
		} catch( InvocationTargetException e){
			m.setAccessible( access );
			throw e.getCause() ; 
		} 
		return res ;
	}
	
	private static Method getCloneMethod(Class cl){
		Method[] methodz ;
		Method m = null ;
		while( cl != null ){
			methodz = cl.getDeclaredMethods( ) ;
			for( int i=0; i<methodz.length; i++){
				m = methodz[i];
				if( "clone".equals( m.getName() ) && m.getParameterTypes().length == 0 ){
					return m ;
				}
			}
			cl = cl.getSuperclass();        
		}
		return null ; /* never happens */
	}
	// }}}
	
	// {{{ cloneObject
	public static Object cloneObject( Object o) throws Throwable {
		Method m = getCloneMethod( o.getClass() ) ;
		boolean access = m.isAccessible() ; 
		m.setAccessible( true ) ;
		
		Object copy = null ; 
		
		try{
				copy = o.getClass().cast( m.invoke( o, (Object[])null ) );
		} catch( IllegalAccessException e) {
			m.setAccessible( access );
			/* should not happen */
		} catch( InvocationTargetException e){
			m.setAccessible( access );
			throw e.getCause() ; 
		}
		return copy ;
	}
	// }}}
	
	/// boxing and unboxing for Double[] and Integer[]
        public static final int NA_INTEGER = -2147483648;
	public static final double NA_REAL = Double.longBitsToDouble(0x7ff00000000007a2L);
        static final long NA_bits = Double.doubleToRawLongBits(Double.longBitsToDouble(0x7ff00000000007a2L));

	public static double[] unboxDoubles(Double[] o) {
		if (o == null) return null;
		int i = 0, n = o.length;
		double d[] = new double[n];
		for (i = 0; i < n; i++) d[i] = (o[i] == null) ? NA_REAL : o[i].doubleValue();
		return d;
	}

	public static int[] unboxIntegers(Integer[] o) {
		if (o == null) return null;
		int i = 0, n = o.length;
		int d[] = new int[n];
		for (i = 0; i < n; i++) d[i] = (o[i] == null) ? NA_INTEGER : o[i].intValue();
		return d;
	}

	public static int[] unboxBooleans(Boolean[] o) {
		if (o == null) return null;
		int i = 0, n = o.length;
		int d[] = new int[n];
		for (i = 0; i < n; i++) d[i] = (o[i] == null) ? NA_INTEGER : (o[i].booleanValue() ? 1 : 0);
		return d;
	}

        public static boolean isNA(double value) {
                /* on OS X i386 the MSB of the fraction is set even though R doesn't set it.
                   Although this is technically a good idea (to make it a QNaN) it's not what R does and thus makes the comparison tricky */
                return (Double.doubleToRawLongBits(value) & 0xfff7ffffffffffffL) == (NA_bits & 0xfff7ffffffffffffL);
        }

	public static Double[] boxDoubles(double[] d) {
		if (d == null) return null;
		int i = 0, n = d.length;
		Double o[] = new Double[i];
		for (i = 0; i < n; i++) if (!isNA(d[i])) o[i] = new Double(d[i]);
		return o;
	}

	public static Integer[] boxIntegers(int[] d) {
		if (d == null) return null;
		int i = 0, n = d.length;
		Integer o[] = new Integer[i];
		for (i = 0; i < n; i++) if (d[i] != NA_INTEGER) o[i] = new Integer(d[i]);
		return o;
	}

	public static Boolean[] boxBooleans(int[] d) {
		if (d == null) return null;
		int i = 0, n = d.length;
		Boolean o[] = new Boolean[i];
		for (i = 0; i < n; i++) if (d[i] != NA_INTEGER) o[i] = new Boolean((d[i] == 0) ? false : true);
		return o;
	}
}
