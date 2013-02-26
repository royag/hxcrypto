package crypto.math;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */

class Random 
{

	public static var IntegerMIN_VALUE:Int = -2147483648;
	public static var IntegerMAX_VALUE:Int = 2147483647; 	
	
	public function new() 
	{
		
	}
	
	public function nextBytes(b:Bytes) {
		for (i in 0...b.length) {
			b.set(i, nextUpTo(255));
		}
	}
	
	private function nextUpTo(max:Int) {
		var r:Float = Math.random();
		var s:Float = Math.random();
		var i = max * r;
		return Math.floor(i);
	}
	
	public function nextInt() : Int {
		var r:Float = Math.random();
		var s:Float = Math.random();
		var i = IntegerMAX_VALUE * r;
		if (s > 0.5) {
			i = -i;
		}
		return Math.floor(i) +0 | 0;
		
		//trace("NEXTRANDOMINT");
		//return 0;
	}
	
}