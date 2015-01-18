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
	
	/*public function nextBytes(b:Bytes) {
		trace("nextBytes");
		for (i in 0...b.length) {
			b.set(i, nextUpTo(255));
		}
	}
	
	private function nextUpTo(max:Int) {
		trace("nextUpTo");
		var r:Float = Math.random();
		var s:Float = Math.random();
		var i = max * r;
		return Math.floor(i);
	}*/
	
	
	public function nextInt() : Int {
		#if js
		untyped __js__("if (window.crypto.getRandomValues) { var tmp = new Int32Array(1); window.crypto.getRandomValues(tmp); return tmp[0]; }");
		#end
		//trace("nextInt");
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