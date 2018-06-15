
public class DummyPoint implements Cloneable {
	public int x; 
	public int y ;
	public DummyPoint(){
		this( 0, 0 ) ;
	}
	public DummyPoint( int x, int y){
		this.x = x ;
		this.y = y ;
	}
	public double getX(){
		return (double)x ;
	}
	public void move(int x, int y){
		this.x += x ;
		this.y += y ;
	}
	
}
