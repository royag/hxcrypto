package crypto;

import haxe.io.Bytes;

/**
 * ...
 * @author roy
 */

class Util 
{
	public static inline function arraycopy(src:Bytes, srcPos:Int, dst:Bytes, dstPos:Int, len:Int) {
		return dst.blit(dstPos, src, srcPos, len);
	}
	
	public static function arraycopyInt(src:Array<Int>, srcpos:Int, dst:Array<Int>, dstpos:Int, len:Int) {
		for (i in 0...len) {
			dst[i + dstpos] = src[i + srcpos];
		}
	}	
	
	public static function intArray(len:Int, ?fillnum : Int) : Array<Int> {
		if (fillnum == null) {
			fillnum = 0;
		}
		var b = new Array<Int>();
		for (i in 0...len) {
			b[i] = fillnum;
		}
		return b;
	}
	
}