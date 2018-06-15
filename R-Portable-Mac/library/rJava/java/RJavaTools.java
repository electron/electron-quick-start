// RJavaTools.java: rJava - low level R to java interface
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

import java.lang.reflect.Method ;
import java.lang.reflect.Field ;
import java.lang.reflect.Constructor ;
import java.lang.reflect.InvocationTargetException ;
import java.lang.reflect.Modifier ;
import java.lang.reflect.Member ;

import java.util.Vector ;


/** 
 * Tools used internally by rJava.
 * 
 * The method lookup code is heavily based on ReflectionTools 
 * by Romain Francois &lt;francoisromain@free.fr&gt; licensed under GPL v2 or higher.
 */
public class RJavaTools {
	
	/**
	 * Returns an inner class of the class with the given simple name
	 * 
	 * @param cl class
	 * @param name simple name of the inner class
	 * @param staticRequired boolean, if <code>true</code> the inner class is required to be static
	 */
	public static Class getClass(Class cl, String name, boolean staticRequired){
		Class[] clazzes = cl.getClasses(); 
		for( int i=0; i<clazzes.length; i++){
			if( getSimpleName( clazzes[i].getName() ).equals( name ) && ( !staticRequired || isStatic(clazzes[i]) ) ){
				return clazzes[i] ;
			}
		}
		return null; 
	}
	
	
	/**
	 * Returns the static inner classes of the class
	 * 
	 * @param cl class
	 * @return an array of classes or null if cl does not have static inner classes
	 */
	public static Class[] getStaticClasses(Class cl){
		 Class[] clazzes = cl.getClasses(); 
		 if( clazzes == null ) return null; 
		 
		 Vector vec = new Vector() ;
		 int n = clazzes.length; 
		 for( int i=0; i<n; i++){
			Class clazz = clazzes[i] ;
			if( isStatic( clazz ) ){
				vec.add( clazz ) ; 
			}
		}
		if( vec.size() == 0 ){
			return null ;
		}
		Class[] out = new Class[ vec.size() ] ;
		vec.toArray( out ) ; 
		return out ; 
	}
	
	/**
	 * Indicates if a class is static
	 * 
	 * @param clazz class
	 * @return true if the class is static
	 */
	public static boolean isStatic( Class clazz ){
		return (clazz.getModifiers() & Modifier.STATIC) != 0  ;
	}
	
	/**
	 * Returns the static fields of the class
	 *
	 * @param cl class 
	 * @return an array of static fields
	 */
	public static Field[] getStaticFields( Class cl ){
		Field[] members = cl.getFields() ;
		if( members.length == 0 ){
			return null;  
		}
		Vector vec = new Vector() ;
		int n = members.length ; 
		for( int i=0; i<n; i++){
			Field memb = members[i] ;
			if( isStatic( memb ) ){
				vec.add( memb ) ; 
			}
		}
		if( vec.size() == 0 ){
			return null ;
		}
		Field[] out = new Field[ vec.size() ] ;
		vec.toArray( out ) ; 
		return out ; 
	}
	
	/**
	 * Returns the static methods of the class
	 *
	 * @param cl class 
	 * @return an array of static fields
	 */
	public static Method[] getStaticMethods( Class cl ){
		Method[] members = cl.getMethods() ;
		Vector vec = new Vector() ;
		if( members.length == 0 ){
			return null;  
		}
		int n = members.length ; 
		for( int i=0; i<n; i++){
			Method memb = members[i] ;
			if( isStatic( memb ) ){
				vec.add( memb ) ; 
			}
		}
		if( vec.size() == 0 ){
			return null ;
		}
		Method[] out = new Method[ vec.size() ] ;
		vec.toArray( out ) ; 
		return out ; 
	}
	
	
	/**
	 * Returns the names of the fields of a given class
	 *
	 * @param cl class 
	 * @param staticRequired if true only static fields are returned
	 * @return the public (and maybe only static) names of the fields. 
	 */
	public static String[] getFieldNames( Class cl, boolean staticRequired ){
		return getMemberNames( cl.getFields(), staticRequired ) ; 
	}
	
	/**
	 * Returns the completion names of the methods of a given class. 
	 * See the getMethodCompletionName method below
	 *
	 * @param cl class 
	 * @param staticRequired if true only static methods are returned
	 * @return the public (and maybe only static) names of the methods. 
	 */
	public static String[] getMethodNames( Class cl, boolean staticRequired ){
		return getMemberNames( cl.getMethods(), staticRequired ) ;
	}
	
	private static String[] getMemberNames(Member[] members, boolean staticRequired){
		String[] result = null ;
		int nm = members.length ;
		if( nm == 0 ){
			return new String[0] ;
		}
		if( staticRequired ){
			Vector names = new Vector();
			for( int i=0; i<nm; i++ ){
				Member member = members[i] ; 
				if( isStatic( member ) ){
					names.add( getCompletionName(member) ) ; 
				}
			}
			if( names.size() == 0 ){
				return new String[0] ;
			}
			result = new String[ names.size() ] ;
		  names.toArray( result ) ; 
		} else{ 
			/* don't need the vector */
			result = new String[nm] ;
			for( int i=0; i<nm; i++ ){
				result[i] = getCompletionName( members[i] ) ;
			}
		}
		return  result; 
	}
	
	/**
	 * Completion name of a member. 
	 * 
	 * <p>For fields, it just returns the name of the fields
	 *
	 * <p>For methods, this returns the name of the method
	 * plus a suffix that depends on the number of arguments of the method.
	 * 
	 * <p>The string "()" is added 
	 * if the method has no arguments, and the string "(" is added
	 * if the method has one or more arguments.
	 */
	public static String getCompletionName(Member m){
		if( m instanceof Field ) return m.getName();
		if( m instanceof Method ){
			String suffix = ( ((Method)m).getParameterTypes().length == 0 ) ? ")" : "" ;
			return m.getName() + "(" + suffix ;
		}
		return "" ;
	}
	 
	/**
	 * Indicates if a member of a Class (field, method ) is static
	 * 
	 * @param member class member
	 * @return true if the member is static
	 */
	public static boolean isStatic( Member member ){
		return (member.getModifiers() & Modifier.STATIC) != 0  ;
	}
	
	/**
	 * Checks if the class of the object has the given field. The 
	 * getFields method of Class is used so only public fields are 
	 * checked
	 *
	 * @param o object
	 * @param name name of the field
	 *
	 * @return <code>true</code> if the class of <code>o</code> has the field <code>name</code>
	 */
	public static boolean hasField(Object o, String name) {
		return classHasField(o.getClass(), name, false);
	}
	
	/**
	 * Checks if the class of the object has the given inner class. The 
	 * getClasses method of Class is used so only public classes are 
	 * checked
	 *
	 * @param o object
	 * @param name (simple) name of the inner class
	 *
	 * @return <code>true</code> if the class of <code>o</code> has the class <code>name</code>
	 */
	public static boolean hasClass(Object o, String name) {
		return classHasClass(o.getClass(), name, false);
	}
	
	
	/**
	 * Checks if the specified class has the given field. The 
	 * getFields method of Class is used so only public fields are 
	 * checked
	 *
	 * @param cl class object
	 * @param name name of the field
	 * @param staticRequired if <code>true</code> then the field is required to be static
	 *
	 * @return <code>true</code> if the class <code>cl</code> has the field <code>name</code>
	 */
	public static boolean classHasField(Class cl, String name, boolean staticRequired) {
		Field[] fields = cl.getFields();
		for (int i = 0; i < fields.length; i++)
			if(name.equals(fields[i].getName()) && (!staticRequired || ((fields[i].getModifiers() & Modifier.STATIC) != 0)))
				return true; 
		return false;
	}
	
	
	/**
	 * Checks if the specified class has the given method. The 
	 * getMethods method of Class is used so only public methods are 
	 * checked
	 *
	 * @param cl class
	 * @param name name of the method
	 * @param staticRequired if <code>true</code> then the method is required to be static
	 *
	 * @return <code>true</code> if the class <code>cl</code> has the method <code>name</code>
	 */
	public static boolean classHasMethod(Class cl, String name, boolean staticRequired) {
		Method[] methodz = cl.getMethods();
		for (int i = 0; i < methodz.length; i++)
			if (name.equals(methodz[i].getName()) && (!staticRequired || ((methodz[i].getModifiers() & Modifier.STATIC) != 0)))
				return true;
		return false;
	}
	
	/**
	 * Checks if the specified class has the given inner class. The 
	 * getClasses method of Class is used so only public classes are 
	 * checked
	 *
	 * @param cl class
	 * @param name name of the inner class
	 * @param staticRequired if <code>true</code> then the method is required to be static
	 *
	 * @return <code>true</code> if the class <code>cl</code> has the field <code>name</code>
	 */
	public static boolean classHasClass(Class cl, String name, boolean staticRequired) {
		Class[] clazzes = cl.getClasses();
		for (int i = 0; i < clazzes.length; i++)
			if (name.equals( getSimpleName(clazzes[i].getName()) ) && (!staticRequired || isStatic( clazzes[i] ) ) )
				return true;
		return false;
	}
	
	/**
	 * Checks if the class of the object has the given method. The 
	 * getMethods method of Class is used so only public methods are 
	 * checked
	 *
	 * @param o object
	 * @param name name of the method
	 *
	 * @return <code>true</code> if the class of <code>o</code> has the field <code>name</code>
	 */
	public static boolean hasMethod(Object o, String name) {
		return classHasMethod(o.getClass(), name, false); 
	}
	
	
	
	/**
	 * Object creator. Find the best constructor based on the parameter classes
	 * and invoke newInstance on the resolved constructor
	 */
	public static Object newInstance( Class o_clazz, Object[] args, Class[] clazzes ) throws Throwable {
		
		boolean[] is_null = new boolean[args.length];
		for( int i=0; i<args.length; i++) {
			is_null[i] = ( args[i] == null ) ;
		}
		
		Constructor cons = getConstructor( o_clazz, clazzes, is_null );
		
		/* enforcing accessibility (workaround for bug 128) */
		boolean access = cons.isAccessible(); 
		cons.setAccessible( true ); 
		
		Object o; 
		try{
			o = cons.newInstance( args ) ; 
		} catch( InvocationTargetException e){
			/* the target exception is much more useful than the reflection wrapper */
			throw e.getTargetException() ;
		} finally{
			cons.setAccessible( access ); 
		}
		return o;                                 
	}
	
	static boolean[] arg_is_null(Object[] args){
		if( args == null ) return null ;
		boolean[] is_null = new boolean[args.length];
		for( int i=0; i<args.length; i++) {
			is_null[i] = ( args[i] == null ) ;
		}
		return is_null ;
	}
	
	/**
	 * Invoke a method of a given class
	 * <p>First the appropriate method is resolved by getMethod and
	 * then invokes the method
	 */
	public static Object invokeMethod( Class o_clazz, Object o, String name, Object[] args, Class[] clazzes) throws Throwable {
		
		Method m = getMethod( o_clazz, name, clazzes, arg_is_null(args) );
		
		/* enforcing accessibility (workaround for bug 128) */
		boolean access = m.isAccessible(); 
		m.setAccessible( true ); 
		
		Object out; 
		try{
			out = m.invoke( o, args ) ; 
		} catch( InvocationTargetException e){
			/* the target exception is much more useful than the reflection wrapper */
			throw e.getTargetException() ;
		} finally{
			m.setAccessible( access ); 
		}
		return out ; 
	}
	
	/**
	 * Attempts to find the best-matching constructor of the class
	 * o_clazz with the parameter types arg_clazz
	 * 
	 * @param o_clazz Class to look for a constructor
	 * @param arg_clazz parameter types
	 * @param arg_is_null indicates if each argument is null
	 * 
	 * @return <code>null</code> if no constructor is found, or the constructor
	 *
	 */
	public static Constructor getConstructor( Class o_clazz, Class[] arg_clazz, boolean[] arg_is_null) 
		throws SecurityException, NoSuchMethodException {
		
		if (o_clazz == null)
			return null; 

		Constructor cons = null ;
		
		/* if there is no argument, try to find a direct match */
		if (arg_clazz == null || arg_clazz.length == 0) {
			cons = o_clazz.getConstructor( (Class[] )null );
			return cons ;
		}

		/* try to find an exact match */
		try {
			cons = o_clazz.getConstructor(arg_clazz);
			if (cons != null)
				return cons ;
		} catch (NoSuchMethodException e) {
			/* we catch this one because we want to further search */
		}
		
		/* ok, no exact match was found - we have to walk through all methods */
		cons = null;
		Constructor[] candidates = o_clazz.getConstructors();
		for (int k = 0; k < candidates.length; k++) {
			Constructor c = candidates[k];
			Class[] param_clazz = c.getParameterTypes();
			if (arg_clazz.length != param_clazz.length) // number of parameters must match
				continue;
			int n = arg_clazz.length;
			boolean ok = true; 
			for (int i = 0; i < n; i++) {
				if( arg_is_null[i] ){
					/* then the class must not be a primitive type */
					if( isPrimitive(arg_clazz[i]) ){ 
						ok = false ;
						break ;
					}
				} else{
					if (arg_clazz[i] != null && !param_clazz[i].isAssignableFrom(arg_clazz[i])) {
						ok = false; 
						break;
					}
				}
			}
			// it must be the only match so far or more specific than the current match
			if (ok && (cons == null || isMoreSpecific(c, cons)))
				cons = c; 
		}
		
		if( cons == null ){
			throw new NoSuchMethodException( "No constructor matching the given parameters" ) ;
		}
		
		return cons; 
		
	}
	
	
	static boolean isPrimitive(Class cl){
		return cl.equals(Boolean.TYPE) || cl.equals(Integer.TYPE) || 
						cl.equals(Double.TYPE) || cl.equals(Float.TYPE) || 
						cl.equals(Long.TYPE) || cl.equals(Short.TYPE) ||
						cl.equals(Character.TYPE) ;
	}
	
	/**
	 * Attempts to find the best-matching method of the class <code>o_clazz</code> with the method name <code>name</code> and arguments types defined by <code>arg_clazz</code>.
	 * The lookup is performed by finding the most specific methods that matches the supplied arguments (see also {@link #isMoreSpecific}).
	 *
	 * @param o_clazz class in which to look for the method
	 * @param name method name
	 * @param arg_clazz an array of classes defining the types of arguments
	 * @param arg_is_null indicates if each argument is null
	 *
	 * @return <code>null</code> if no matching method could be found or the best matching method.
	 */
	public static Method getMethod(Class o_clazz, String name, Class[] arg_clazz, boolean[] arg_is_null) 
		throws SecurityException, NoSuchMethodException {
		
		if (o_clazz == null)
			return null; 

		/* if there is no argument, try to find a direct match */
		if (arg_clazz == null || arg_clazz.length == 0) {
				return o_clazz.getMethod(name, (Class[])null);
		}

		/* try to find an exact match */
		Method met;
		try {
			met = o_clazz.getMethod(name, arg_clazz);
			if (met != null)
				return met;
		} catch (NoSuchMethodException e) {
			/* we want to search further */
		}
		
		/* ok, no exact match was found - we have to walk through all methods */
		met = null;
		Method[] ml = o_clazz.getMethods();
		for (int k = 0; k < ml.length; k++) {
			Method m = ml[k];
			if (!m.getName().equals(name)) // the name must match
				continue; 
			Class[] param_clazz = m.getParameterTypes();
			if (arg_clazz.length != param_clazz.length) // number of parameters must match
				continue;
			int n = arg_clazz.length;
			boolean ok = true; 
			for (int i = 0; i < n; i++) {
				if( arg_is_null[i] ){
					/* then the class must not be a primitive type */
					if( isPrimitive(arg_clazz[i]) ){ 
						ok = false ;
						break ;
					}
				} else{
					if (arg_clazz[i] != null && !param_clazz[i].isAssignableFrom(arg_clazz[i])) {
						ok = false; 
						break;
					}
				}
			}
			if (ok && (met == null || isMoreSpecific(m, met))) // it must be the only match so far or more specific than the current match
				met = m; 
		}
		
		if( met == null ){
			throw new NoSuchMethodException( "No suitable method for the given parameters" ) ; 
		}
		return met; 
	}

	/** 
	 * Returns <code>true</code> if <code>m1</code> is more specific than <code>m2</code>. 
	 * The measure used is described in the isMoreSpecific( Class[], Class[] ) method
	 *
	 * @param m1 method to compare
	 * @param m2 method to compare 
	 *
	 * @return <code>true</code> if <code>m1</code> is more specific (in arguments) than <code>m2</code>.
	 */
	private static boolean isMoreSpecific(Method m1, Method m2) {
		Class[] m1_param_clazz = m1.getParameterTypes();
		Class[] m2_param_clazz = m2.getParameterTypes();
		return isMoreSpecific( m1_param_clazz, m2_param_clazz ); 
	}
	
	/** 
	 * Returns <code>true</code> if <code>cons1</code> is more specific than <code>cons2</code>. 
	 * The measure used is described in the isMoreSpecific( Class[], Class[] ) method
	 *
	 * @param cons1 constructor to compare
	 * @param cons2 constructor to compare 
	 * 
	 * @return <code>true</code> if <code>cons1</code> is more specific (in arguments) than <code>cons2</code>.
	 */
	private static boolean isMoreSpecific(Constructor cons1, Constructor cons2) {
		Class[] cons1_param_clazz = cons1.getParameterTypes();
		Class[] cons2_param_clazz = cons2.getParameterTypes();
		return isMoreSpecific( cons1_param_clazz, cons2_param_clazz ); 
	}
	 
	/**
	 * Returns <code>true</code> if <code>c1</code> is more specific than <code>c2</code>. 
	 *
	 * The measure used is the sum of more specific arguments minus the sum of less specific arguments 
	 * which in total must be positive to qualify as more specific. 
	 * (More specific means the argument is a subclass of the other argument). 
	 *
	 * Both set of classes must have signatures fully compatible in the arguments 
	 * (more precisely incompatible arguments are ignored in the comparison).
	 *
	 * @param c1 set of classes to compare
	 * @param c2 set of classes to compare
   */
	private static boolean isMoreSpecific( Class[] c1, Class[] c2){
	 	int n = c1.length ;
		int res = 0; 
		for (int i = 0; i < n; i++)
			if( c1[i] != c2[i]) {
				if( c1[i].isAssignableFrom(c2[i]))
					res--;
				else if( c2[i].isAssignableFrom(c2[i]) )
					res++;
			}
		return res > 0;
	}
	
	/**
	 * Returns the list of classes of the object 
	 *
	 * @param o an Object
	 */
	public static Class[] getClasses(Object o){
		Vector/*<Class<?>>*/ vec = new Vector(); 
		Class cl = o.getClass(); 
		while( cl != null ){
			vec.add( cl ) ; 
			cl = cl.getSuperclass() ;
		}
		Class[] res = new Class[ vec.size() ] ;
		vec.toArray( res) ;
		return res ;
	}
	
	/**
	 * Returns the list of class names of the object 
	 *
	 * @param o an Object
	 */
	public static String[] getClassNames(Object o){
		Vector/*<String>*/ vec = new Vector(); 
		Class cl = o.getClass(); 
		while( cl != null ){
			vec.add( cl.getName() ) ;
			cl = cl.getSuperclass() ;
		}
		String[] res = new String[ vec.size() ] ;
		vec.toArray( res) ;
		return res ;
	}
	
	/**
	 * Returns the list of simple class names of the object
	 *
	 * @param o an Object
	 */
	public static String[] getSimpleClassNames(Object o, boolean addConditionClasses){
		boolean hasException = false ;
		Vector/*<String>*/ vec = new Vector(); 
		Class cl = o.getClass();
		String name ;
		while( cl != null ){
			name = getSimpleName( cl.getName() ) ;
			if( "Exception".equals( name) ){
				hasException = true ;
			}
			vec.add( name ) ;
			cl = cl.getSuperclass() ;
		}
		if( addConditionClasses ){
			if( !hasException ){
				vec.add( "Exception" ) ;
			}
			vec.add( "error" ) ;
			vec.add( "condition" ) ;
		}
		
		String[] res = new String[ vec.size() ] ;
		vec.toArray( res) ;
		return res ;
	}

	/* because Class.getSimpleName is java 5 API */ 
	private static String getSimpleClassName( Object o ){
		return getSimpleName( o.getClass().getName() ) ; 
	}
	
	private static String getSimpleName( String s ){
		int lastsquare = s.lastIndexOf( '[' ) ;
		if( lastsquare >= 0 ){
			if( s.charAt(  s.lastIndexOf( '[' ) + 1 ) == 'L' ){
				s = s.substring( s.lastIndexOf( '[' ) + 2, s.lastIndexOf( ';' ) ) ;
			} else {
				char first = s.charAt( 0 );
				if( first == 'I' ) {
					s = "int" ;
				} else if( first == 'D' ){
					s = "double" ;
				} else if( first == 'Z' ){
					s = "boolean" ;
				} else if( first == 'B' ){
					s = "byte" ;
				} else if( first == 'J' ){
					s = "long" ; 
				} else if( first == 'F' ){
					s = "float" ; 
				} else if( first == 'S' ){
					s = "short" ; 
				} else if( first == 'C' ){
					s = "char" ;
				}
			}
		}
		
		int lastdollar = s.lastIndexOf( '$' ) ;
		if( lastdollar >= 0 ){
			s = s.substring( lastdollar + 1);
		}
		
		int lastdot = s.lastIndexOf( '.' ) ;
		if( lastdot >= 0 ){
			s = s.substring( lastdot + 1);
		}
		
		if( lastsquare >= 0 ){
			StringBuffer buf = new StringBuffer( s );
			int i ;
			for( i=0; i<=lastsquare; i++){
				buf.append( "[]" ); 
			}
			return buf.toString(); 
		} else {
			return s ;
		}
		
	}
	
	/**
	 * @param cl class 
	 * @param field name of the field 
	 * 
	 * @return the class name of the field of the class (or null) 
	 * if the class does not have the given field)
	 */
	public static String getFieldTypeName( Class cl, String field){
		String res = null ; 
		try{
			res = cl.getField( field ).getType().getName() ;
		} catch( NoSuchFieldException e){
			/* just return null */
			res = null ;
		}
		return res ;
	}
		
}
