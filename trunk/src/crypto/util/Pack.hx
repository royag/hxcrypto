package crypto.util;

import crypto.math.Int64;
import haxe.io.Bytes;

class Pack 
{
	public static function bigEndianToInt(bs:Bytes, off:Int):Int
    {
        var n:Int = bs.get(  off) << 24;
        n |= (bs.get(++off) & 0xff) << 16;
        n |= (bs.get(++off) & 0xff) << 8;
        n |= (bs.get(++off) & 0xff);
        return n;
    }

    public static function bigEndianToIntArray(bs:Bytes, off:Int, ns:Array<Int>):Void
    {
        //for (int i = 0; i < ns.length; ++i)
		for (i in 0...ns.length)
        {
            ns[i] = bigEndianToInt(bs, off);
            off += 4;
        }
    }

    public static function intToBigEndian(n:Int, bs:Bytes,  off:Int):Void
    {
        bs.set(  off,n >>> 24);
        bs.set(++off,n >>> 16);
        bs.set(++off,n >>>  8);
        bs.set(++off,n       );
    }

    public static function intArrayToBigEndian(ns:Array<Int>, bs:Bytes,  off:Int):Void
    {
        //for (int i = 0; i < ns.length; ++i)
		for (i in 0...ns.length)
        {
            intToBigEndian(ns[i], bs, off);
            off += 4;
        }
    }

    public static function bigEndianToLong(bs:Bytes,  off:Int):Int64
    {
        var hi:Int = bigEndianToInt(bs, off);
        var lo:Int = bigEndianToInt(bs, off + 4);
        //return ((long)(hi & 0xffffffffL) << 32) | (long)(lo & 0xffffffffL);
		var n1 = Int64.shl(Int64.and(Int64.ofInt(hi), Int64.make(0, 0xffffffff)), 32);
		var n2 = Int64.and(Int64.ofInt(lo), Int64.make(0, 0xffffffff));
		return Int64.or(n1,n2);
    }

    public static function longToBigEndian(n:Int64, bs:Bytes, off:Int):Void
    {
        //intToBigEndian((int)(n >>> 32), bs, off);
        intToBigEndian(Int64.toInt(Int64.ushr(n,32)), bs, off);
        //intToBigEndian((int)(n & 0xffffffffL), bs, off + 4);
		intToBigEndian(Int64.toInt(Int64.and(n,Int64.make(0, 0xffffffff))), bs, off + 4);
    }

    public static function littleEndianToInt(bs:Bytes, off:Int):Int
    {
        var n:Int = bs.get(  off) & 0xff;
        n |= (bs.get(++off) & 0xff) << 8;
        n |= (bs.get(++off) & 0xff) << 16;
        n |= bs.get(++off) << 24;
        return n;
    }

    public static function littleEndianToIntArray(bs:Bytes,  off:Int, ns:Array<Int>):Void
	{
		//for (int i = 0; i < ns.length; ++i)
		for (i in 0...ns.length)
		{
			ns[i] = littleEndianToInt(bs, off);
			off += 4;
		}
	}

    public static function intToLittleEndian(n:Int, bs:Bytes,  off:Int):Void
    {
        bs.set(  off,(n       ));
        bs.set(++off,(n >>>  8));
        bs.set(++off,(n >>> 16));
        bs.set(++off,(n >>> 24));
    }

	public static function intArrayToLittleEndian(ns:Array<Int>, bs:Bytes ,  off:Int):Void
	{
		//for (int i = 0; i < ns.length; ++i)
		for (i in 0...ns.length)
		{
			intToLittleEndian(ns[i], bs, off);
			off += 4;
		}
	}

    public static function littleEndianToLong(bs:Bytes ,  off:Int):Int64
    {
        var lo:Int = littleEndianToInt(bs, off);
        var hi:Int = littleEndianToInt(bs, off + 4);
        //return ((long)(hi & 0xffffffffL) << 32) | (long)(lo & 0xffffffffL);
        //return ((long)(hi & 0xffffffffL) << 32) | (long)(lo & 0xffffffffL);
		var n1 = Int64.shl(Int64.and(Int64.ofInt(hi), Int64.make(0, 0xffffffff)), 32);
		var n2 = Int64.and(Int64.ofInt(lo), Int64.make(0, 0xffffffff));
		return Int64.or(n1,n2);
	}

    public static function longToLittleEndian(n:Int64, bs:Bytes ,  off:Int):Void
    {
        //intToLittleEndian((int)(n & 0xffffffffL), bs, off);
		intToLittleEndian(Int64.toInt(Int64.and(n , Int64.make(0, 0xffffffff))), bs, off);
        //intToLittleEndian((int)(n >>> 32), bs, off + 4);
		intToLittleEndian(Int64.toInt(Int64.ushr(n,32)), bs, off + 4);
    }
	
}