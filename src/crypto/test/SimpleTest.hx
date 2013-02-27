package crypto.test;

import haxe.io.Bytes;

/**
 * ...
 * @author test
 */

class SimpleTest 
{

	function areEqual(
         a:Bytes,
         b:Bytes) : Bool
    {
		return (a.compare(b) == 0);
    }
	
	function fail(s:String) {
		trace("FAIL: " + s);
		throw "TEST FAILED:" + s;
	}
	function fail2(s:String, e:Dynamic) {
		s = s + Std.string(e);
		trace("FAIL: " + s);
		throw "TEST FAILED:" + s;
	}
	function fail3(s:String, e:Dynamic, s2) {
		s = s + Std.string(e)+ ","+s2;
		trace("FAIL: " + s);
		throw "TEST FAILED:" + s;
	}
	
	function success() {
		trace("Success!");
	}
	
	public function performTest() {
	}
	
	public function getName() : String {
		return "SimpleTest";
	}
	
}