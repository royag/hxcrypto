package crypto;

/**
 * ...
 * @author test
 */

class Array2<T> 
{

	var pitch:Int;
	public var arr:Array<Array<T>>;
	//public var ar1:Array<T>;
	
	public function new(pitch:Int) 
	{
		this.pitch = pitch;
		arr = new Array<Array<T>>();
		for (i in 0...pitch) {
			arr[i] = new Array<T>();
		}
		//ar1 = new Array<T>();
	}
	
	public function set(y:Int, x:Int, val:T) {
		//ar1[y * pitch + x] = val;
		arr[y][x] = val;
	}
	
     public function get(y: Int, x: Int) : T
     {
          //return ar1[y * pitch + x];
		  return arr[y][x];
     }
	
}