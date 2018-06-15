// :tabSize=2:indentSize=2:noTabs=false:folding=explicit:collapseFolds=1:

/**
 * Utility class that makes example rectangular java arrays of 2 and 3 dimensions
 * for all primitive types, String and Point (as an example of array of non primitive object)
 */
public class RectangularArrayExamples {

	// {{{ Example 2d rect arrays 
	public static int[][] getIntDoubleRectangularArrayExample(){
		int[][] x = new int[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = k ;
			}
		}
		return x; 
	}
	
	public static boolean[][] getBooleanDoubleRectangularArrayExample(){
		boolean[][] x = new boolean[5][2]; 
		boolean current = false;  
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, current = !current){
				x[i][j] = current ;
			}
		}
		return x ;
	}
	
	public static byte[][] getByteDoubleRectangularArrayExample(){
		byte[][] x = new byte[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = (byte)k ;
			}
		}
		return x; 
	}
	
	public static long[][] getLongDoubleRectangularArrayExample(){
		long[][] x = new long[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = (long)k ;
			}
		}
		return x; 
	}
	
	public static short[][] getShortDoubleRectangularArrayExample(){
		short[][] x = new short[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = (short)k ;
			}
		}
		return x; 
	}
	
	public static double[][] getDoubleDoubleRectangularArrayExample(){
		double[][] x = new double[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = k + 0.0 ;
			}
		}
		return x; 
	}
	
	public static char[][] getCharDoubleRectangularArrayExample(){
		char[][] x = new char[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = (char)k ;
			}
		}
		return x; 
	}
	
	public static float[][] getFloatDoubleRectangularArrayExample(){
		float[][] x = new float[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = k + 0.0f ;
			}
		}
		return x; 
	}
	
	public static String[][] getStringDoubleRectangularArrayExample(){
		String[][] x = new String[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = "" + k ;
			}
		}
		return x; 
	}
	
	public static DummyPoint[][] getDummyPointDoubleRectangularArrayExample(){
		DummyPoint[][] x = new DummyPoint[5][2]; 
		int k= 0; 
		for( int j=0; j<2; j++){
			for( int i=0; i<5; i++, k++){
				x[i][j] = new DummyPoint(k,k) ;
			}
		}
		return x; 
	}
	// }}}
	
	// {{{ Example 3d rect arrays 
	public static int[][][] getIntTripleRectangularArrayExample(){
		int[][][] x = new int[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = current ;
				}
			}
		}
		return x; 
	}
	
	public static boolean[][][] getBooleanTripleRectangularArrayExample(){
		boolean[][][] x = new boolean[5][3][2]; 
		boolean current = false ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current= !current){
					x[i][j][k] = current ;
				}
			}
		}
		return x; 
	}
	
	public static byte[][][] getByteTripleRectangularArrayExample(){
		byte[][][] x = new byte[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = (byte)current ;
				}
			}
		}
		return x; 
	}
	
	public static long[][][] getLongTripleRectangularArrayExample(){
		long[][][] x = new long[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = (long)current ;
				}
			}
		}
		return x; 
	}
	
	public static short[][][] getShortTripleRectangularArrayExample(){
		short[][][] x = new short[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = (short)current ;
				}
			}
		}
		return x; 
	}
	
	public static double[][][] getDoubleTripleRectangularArrayExample(){
		double[][][] x = new double[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = 0.0 + current ;
				}
			}
		}
		return x; 
	}
	
	public static char[][][] getCharTripleRectangularArrayExample(){
		char[][][] x = new char[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = (char)current ;
				}
			}
		}
		return x; 
	}
	
	public static float[][][] getFloatTripleRectangularArrayExample(){
		float[][][] x = new float[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = 0.0f + current ;
				}
			}
		}
		return x; 
	}
	
	public static String[][][] getStringTripleRectangularArrayExample(){
		String[][][] x = new String[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = ""+current ;
				}
			}
		}
		return x; 
	}
	
	public static DummyPoint[][][] getDummyPointTripleRectangularArrayExample(){
		DummyPoint[][][] x = new DummyPoint[5][3][2]; 
		int current = 0 ;
		for( int k=0; k<2; k++){
			for( int j=0; j<3; j++){
				for( int i=0; i<5; i++, current++){
					x[i][j][k] = new DummyPoint( current, current ) ;
				}
			}
		}
		return x; 
	}
	
	// }}}
	
}
