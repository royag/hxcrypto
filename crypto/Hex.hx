package crypto;
import haxe.crypto.BaseCode;
//import haxe.BaseCode;
//import haxe.BaseCode;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */

class Hex 
{
	public static inline var HEX_BASE = "0123456789ABCDEF";
	
	public static function decode(s:String) : Bytes {
		s = s.toUpperCase();
		var bc = new BaseCode(Bytes.ofString(HEX_BASE));
		//s.
		/*var b = Bytes.alloc(s.length);
		for (i in 0...s.length) {
			b.set(i, s.charCodeAt(i));
		}
		var res = bc.decodeBytes(b); // ytes.ofString(s));
		*/
		var res = bc.decodeBytes(Bytes.ofString(s));
		if (res == null) {
			trace("BaseCode.decode returned null");
		}
		return res;
	}
	public static function encode(b:Bytes) : String {
		var bc = new BaseCode(Bytes.ofString(HEX_BASE));
		return bc.encodeBytes(b).toString();
		//return BaseCode.encode(b.toString(), HEX_BASE);
	}	
}