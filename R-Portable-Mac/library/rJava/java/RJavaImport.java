
import java.util.regex.Pattern ;
import java.util.regex.Matcher ;

import java.util.Vector; 
import java.util.HashMap;
import java.util.Map;
import java.util.Collection;
import java.util.Set ;
import java.util.Iterator ;

import java.io.Serializable; 

/**
 * Utilities to manage java packages and how they are "imported" to R
 * databases. This is the back door of the <code>javaImport</code>
 * system in the R side
 *
 * @author Romain Francois &lt;francoisromain@free.fr&gt;
 */
public class RJavaImport implements Serializable {

	/**
	 * Debug flag. Prints some messages if it is set to TRUE
	 */
	public static boolean DEBUG = false ; 
	
	/** 
	 * list of imported packages
	 */
	/* TODO: vector is not good enough, we need to control the order
	         in which the packages appear */
	private Vector/*<String>*/ importedPackages ;
	
	/**
	 * maps a simple name to a fully qualified name
	 */
	/* String -> java.lang.String */
  /* should we cache the Class instead ? */
	private Map/*<String,String>*/ cache ;
	
	/**
	 * associated class loader
	 */
	public ClassLoader loader ;
	
	/**
	 * Constructor. Initializes the imported package vector and the cache
	 */ 
	public RJavaImport( ClassLoader loader ){
	    this.loader = loader ;
		importedPackages = new Vector/*<String>*/(); 
		cache = new HashMap/*<String,String>*/() ;
	}
	
	/**
	 * Look for the class in the set of packages
	 *
	 * @param clazz the simple class name
	 * 
	 * @return an instance of Class representing the actual class
	 */
	public Class lookup( String clazz){
		Class res = lookup_(clazz) ;
		if( DEBUG ) System.out.println( "  [J] lookup( '" + clazz + "' ) = " + (res == null ? " " : ("'" + res.getName() + "'" ) ) ) ;
		return res ;
	}

	private Class lookup_( String clazz ){
		Class res = null ;
		
		if( cache.containsKey( clazz ) ){
			try{
				String fullname = (String)cache.get( clazz ) ;
				Class cl = Class.forName( fullname ) ; 
				return cl ;
			} catch( Exception e ){
				/* does not happen */
			}
		}
		
		/* first try to see if the class does not exist verbatim */
		try{
			res = Class.forName( clazz ) ;
		} catch( Exception e){}
		if( res != null ) {
			cache.put( clazz, clazz ) ;
			return res;
		}
		
		int npacks = importedPackages.size() ;
		if( DEBUG ) System.out.println( "    [J] " + npacks + " packages" ) ;
		if( npacks > 0 ){
			for( int i=0; i<npacks; i++){
				try{
				    String p = (String)importedPackages.get(i); 
				    String candidate = p + "." + clazz ;
				    if( DEBUG ) System.out.println( "    [J] trying class : " + candidate ) ;
					res = Class.forName( candidate ) ;
				} catch( Exception e){
				    if( DEBUG ) System.out.println( "   [JE] " + e.getMessage() );
				}
				if( res != null ){
					cache.put( clazz, res.getName() ) ;
					return res ; 
				}
			}
		}
		return null ;
	}
	
	/**
	 * @return true if the class is known
	 */
	public boolean exists( String clazz){
		boolean res = exists_(clazz) ;
		if( DEBUG ) System.out.println( "  [J] exists( '" + clazz + "' ) = " + res ) ;
		return res ;
	}

	public boolean exists_( String clazz ){
		if( cache.containsKey( clazz ) ) return true ;
		
		return ( lookup_( clazz ) != null );
	}
	
	/**
	 * Adds a package to the list of "imported" packages
	 *
	 * @param packageName package path name
	 */
  public void importPackage( String packageName ){
  	importedPackages.add( packageName ) ; 
  }
	
  /**
   * Adds a set of packages
   *
   * @param packages package path names
   */
  public void importPackage( String[] packages ){
  	for( int i=0; i<packages.length; i++){
  		importPackage( packages[i] ) ;
  	}
  }
  
  /**
   * @return the simple names of the classes currently known
   * by this importer
   */
  public String[] getKnownClasses(){
  	Set/*<String>*/ set = cache.keySet() ; 
  	int size = set.size() ;
  	String[] res = new String[size];
  	set.toArray( res );
  	if( DEBUG ) System.out.println( "  [J] getKnownClasses().length = "  + res.length ) ;
  	return res ;
  }
  
  public static Class lookup( String clazz , Set importers ){
  	Class res  ;
  	Iterator iterator = importers.iterator() ;
  	while( iterator.hasNext()){
  		RJavaImport importer = (RJavaImport)iterator.next() ;
  		res = importer.lookup( clazz ) ;
  		if( res != null ) return res ;
  	}
  	return null ;
  }
  
}

