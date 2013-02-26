/*
 * Copyright (C)2005-2012 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
//package haxe;
package crypto.math;

class Int64 {

	static inline function add32(a, b) {
		return a + b | 0;
	}
	
	static inline function mul32(a, b) {
		// Have to do some bit-magic to make JavaScript NOT destroy the 32 bit signed integers:
		var a1 = a * (b & 0xFFFF) | 0;
		var b1 = a * ((b >>> 16) << 16) | 0;
		return add32(a1, b1);
	}
	
	var high : Int;
	var low : Int;

	function new(high, low) {
		this.high = i32(high);
		this.low = i32(low);
	}

	@:extern inline function i32(i) {
		#if (php || js || flash8)
		return i | 0;
		#else
		return i;
		#end
	}

	#if as3 public #end function toString() {
		if ((high|low) == 0 )
			return "0";
		var str = "";
		var neg = false;
		var i = this;
		if( isNeg(i) ) {
			neg = true;
			i = Int64.neg(i);
		}
		var ten = ofInt(10);
		while( !isZero(i) ) {
			var r = divMod(i, ten);
			str = r.modulus.low + str;
			i = r.quotient;
		}
		if( neg ) str = "-" + str;
		return str;
	}

	public static inline function make( high : Int, low : Int ) : Int64 {
		return new Int64(high, low);
	}

	public static inline function ofInt( x : Int ) : Int64 {
		return new Int64(x >> 31,x);
	}

	public static function toInt( x : Int64 ) : Int {
		if( x.high != 0 ) {
			if( x.high < 0 )
				return -toInt(neg(x));
			//throw "Overflow";
			//trace("OVERFLOW!!!!");
			return x.low;
		}
		return x.low;
	}

	public static function getLow( x : Int64 ) : Int {
		return x.low;
	}

	public static function getHigh( x : Int64 ) : Int {
		return x.high;
	}

	public static function add( a : Int64, b : Int64 ) : Int64 {
		var high = add32(a.high , b.high); // | 0;
		var low = add32(a.low , b.low); // | 0;
		if( uicompare(low,a.low) < 0 )
			//high++;
			high = add32(high , 1); // | 0;
		return new Int64(high, low);
	}

	public static function sub( a : Int64, b : Int64 ) : Int64 {
		var high = a.high - b.high | 0;
		var low = a.low - b.low | 0;
		if( uicompare(a.low,b.low) < 0 )
			high = high - 1 | 0;
		return new Int64(high, low);
	}

	public static function mul( a : Int64, b : Int64 ) : Int64 {
		var mask = 0xFFFF;
		//gtgr
		/*var strange = false;
		if (Std.string(a) == "3556362740" && Std.string(b) == "3362113381") {
			trace(" SOMETHING STRANGE (fails on multiply) ");
			strange = true;
		}
		if (Std.string(a) == "597364243" && Std.string(b) == "957955355") {
			trace(" SOMETHING STRANGE 222 fails on += before uicompare");
			strange = true;
		}*/		
		
		var al:Int = a.low & mask;
		var ah:Int = a.low >>> 16;
		var bl:Int = b.low & mask;
		var bh:Int = b.low >>> 16;
		var p00:Int = mul32(al, bl); // al * bl | 0;
		var p10:Int = mul32(ah, bl); //ah * bl | 0;
		var p01:Int = mul32(al, bh); // al * bh | 0;
		var p11:Int = mul32(ah, bh); // ah * bh | 0;
		var low:Int = p00;
		var high:Int = p11 + ((p01 >>> 16) + (p10 >>> 16)) | 0;
		/*if (strange) {
			trace(al);
			trace(ah);
			trace(bl);
			trace(bh);
			trace(p00);
			if (strange) trace(p10);
			trace(p01);
			trace(p11);
			trace(low);
			trace("high: " + Std.string(high));
		}*/
		
		p01 = (p01 << 16); 
		low = low + p01 | 0; 
		/*if (strange) {
			trace(low);
			trace(p01);
		}*/
		if( uicompare(low,p01) < 0 ) high++;
		//	if (strange) trace("uicompare(low,p01) < 0" + Std.string((uicompare(low, p01) < 0)));
		p10 = (p10 << 16);
		low = low + p10 | 0; 
		/*if (strange) {
			trace(low);
			trace(p10);
		}*/
		if( uicompare(low,p10) < 0 ) high = high + 1 | 0;
		//	if (strange) trace("uicompare(low,p10) < 0" + Std.string((uicompare(low, p10) < 0)));
		/*if (strange) {
			trace("a.high: " + Std.string(a.high));
			trace("a.low: " + Std.string(a.low));
		}		
		if (strange) {
			trace("b.high: " + Std.string(b.high));
			trace("b.low: " + Std.string(b.low));
		}		
		if (strange) {
			trace("high before +=: " + Std.string(high));
		}*/		
		high = high + mul32(a.low, b.high) | 0; // (a.low * b.high | 0);
		high = high + mul32(a.high, b.low) | 0; // (a.high * b.low | 0);
		/*if (strange) {
			trace("high: " + Std.string(high));
			trace("low: " + Std.string(low));
		}*/		
		return new Int64(high, low);
	}

	static function divMod( modulus : Int64, divisor : Int64 ) {
		//trace("ugh-divmod");
		var quotient = new Int64(0, 0);
		var mask = new Int64(0, 1);
		divisor = new Int64(divisor.high, divisor.low);
		while( divisor.high >= 0 ) {
			var cmp = ucompare(divisor, modulus);
			divisor.high = (divisor.high << 1) | (divisor.low >>> 31);
			divisor.low <<= 1;
			mask.high = (mask.high << 1) | (mask.low >>> 31);
			mask.low <<= 1;
			if( cmp >= 0 ) break;
		}
		while( (mask.low | mask.high) != 0 ) {
			if( ucompare(modulus, divisor) >= 0 ) {
				quotient.high |= mask.high;
				quotient.low |= mask.low;
				modulus = sub(modulus,divisor);
			}
			mask.low = (mask.low >>> 1) | (mask.high << 31);
			mask.high >>>= 1;

			divisor.low = (divisor.low >>> 1) | (divisor.high << 31);
			divisor.high >>>= 1;
		}
		return { quotient : quotient, modulus : modulus };
	}

	public static inline function div( a : Int64, b : Int64 ) : Int64 {
		var sign = (a.high | b.high) < 0;
		if( a.high < 0 ) a = neg(a);
		if( b.high < 0 ) b = neg(b);
		var q = divMod(a, b).quotient;
		return sign ? neg(q) : q;
	}

	public static inline function mod( a : Int64, b : Int64 ) : Int64 {
		var sign = (a.high | b.high) < 0;
		if( a.high < 0 ) a = neg(a);
		if( b.high < 0 ) b = neg(b);
		var m = divMod(a, b).modulus;
		return sign ? neg(m) : m;
	}

	public static inline function shl( a : Int64, b : Int ) : Int64 {
		return if( b & 63 == 0 ) a else if( b & 63 < 32 ) new Int64( (a.high << b) | (a.low >>> (32-(b&63))), a.low << b ) else new Int64( a.low << (b - 32), 0 );
	}

	public static inline function shr( a : Int64, b : Int ) : Int64 {
		return if( b & 63 == 0 ) a else if( b & 63 < 32 ) new Int64( a.high >> b, (a.low >>> b) | (a.high << (32 - (b&63))) ) else new Int64( a.high >> 31, a.high >> (b - 32) );
	}

	public static inline function ushr( a : Int64, b : Int ) : Int64 {
		return if( b & 63 == 0 ) a else if( b & 63 < 32 ) new Int64( a.high >>> b, (a.low >>> b) | (a.high << (32 - (b&63))) ) else new Int64( 0, a.high >>> b - 32 );
	}

	public static inline function and( a : Int64, b : Int64 ) : Int64 {
		return new Int64( a.high & b.high, a.low & b.low );
	}

	public static inline function or( a : Int64, b : Int64 ) : Int64 {
		return new Int64( a.high | b.high, a.low | b.low );
	}

	public static inline function xor( a : Int64, b : Int64 ) : Int64 {
		return new Int64( a.high ^ b.high, a.low ^ b.low );
	}

	public static inline function neg( a : Int64 ) : Int64 {
		var high = ~a.high;
		var low = -a.low | 0;
		if( low == 0 )
			//high++;
			high = high + 1 | 0;
		return new Int64(high,low);
	}

	public static inline function isNeg( a : Int64 ) : Bool {
		return a.high < 0;
	}

	public static inline function isZero( a : Int64 ) : Bool {
		return (a.high | a.low) == 0;
	}

	static function uicompare( a : Int, b : Int ) {
		return a < 0 ? (b < 0 ? ~b - ~a : 1) : (b < 0 ? -1 : a - b);
	}

	public static inline function compare( a : Int64, b : Int64 ) : Int {
		var v = a.high - b.high | 0;
		return if( v != 0 ) v else uicompare(a.low,b.low);
	}

	/**
		Compare two Int64 in unsigned mode.
	**/
	public static inline function ucompare( a : Int64, b : Int64 ) : Int {
		var v = uicompare(a.high,b.high);
		return if( v != 0 ) v else uicompare(a.low, b.low);
	}

	public static inline function toStr( a : Int64 ) : String {
		return a.toString();
	}

}