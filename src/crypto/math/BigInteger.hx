package crypto.math;
import haxe.crypto.BaseCode;
//import haxe.BaseCode;
//import haxe.Int64;
import crypto.math.Int64;
import haxe.io.Bytes;
//import haxe.Stack;
import crypto.Hex;

/**
 * ...
 * @author test
 */

 typedef Stack = Array<String>;
 typedef Byte = Int;
 typedef StringBuffer = StringBuf;

class BigInteger 
{
	
	static inline function mul32(a, b) {
		// Have to do some bit-magic to make JavaScript NOT destroy the 32 bit signed integers:
		var a1 = a * (b & 0xFFFF) | 0;
		var b1 = a * ((b >>> 16) << 16) | 0;
		return a1 + b1 | 0;
	}
	
	public static var Character_MAX_RADIX = 36;
	public static var Character_MIN_RADIX = 2;
	
	//static var LongMIN_VALUE = Int64.ofInt(-9223372036854775808); // (-2)**63   // TODO : FIX  // signed:  0x80000000 00000000
	public static var LongMIN_VALUE = Int64.make(0x80000000, 0x00000000);
	public static var LongMAX_VALUE = Int64.make(0x7FFFFFFF, 0xFFFFFFFF);
	
	public static var IntegerMIN_VALUE:Int = -2147483648;
	public static var IntegerMAX_VALUE:Int = 2147483647; // Java: Integer.MAX_VALUE
	
	static function Arrays_clone(a:Array<Int>) {
		var ret = new Array<Int>();
		for (elem in a.iterator()) {
			ret.push(elem);
		}
		return ret;
	}
	

	
	static function i64not(v:Int64) {
		return Int64.make(~Int64.getHigh(v), ~Int64.getLow(v));
	}
	
	static var rchars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	static function charsForRadix(rdx:Int) {
		return rchars.substr(0, rdx);
	}
	
	//static 
	// TODO : implement:
	static function digit(char:String, radix:Int) : Int {
		//////trace(radix);
		if (radix == 10) {
			//////trace("DIGIT=" + Std.parseInt(char));
			return Std.parseInt(char);
		}
		if (radix == 16) {
			//var b = Hex.decode("0" + char);
			//trace("b.length=" + Std.string(b.length));
			var r = Hex.decode("0" + char).get(0);
			//trace("DIGIThex=" + Std.string(r));
			return r;
		}
		var bc = new BaseCode(Bytes.ofString(charsForRadix(radix)));
		var b = bc.decodeBytes(Bytes.ofString(char));
		if (b.length > 1) {
			throw "value too large";
		}
		
		trace("DIGIT=" + Std.string(b.get(0)) + " ("+char+")" );
		return b.get(0);
		//return 0;
	}	
	
	static function Long_toString(n:Int64, rdx:Int) {
		if (rdx == 10) {
			return Std.string(n);
		}
		var hi = Int64.getHigh(n);
		var lo = Int64.getLow(n);
		// TODO: FIX !
		return Integer_toString(hi, rdx) + Integer_toString(lo, rdx);
	}
	static function invPow2(n:Int) : Int {
		if (n == 32) {
			return 5;
		} else if (n == 16) {
			return 4;
		} else if (n == 8) {
			return 3;
		} else if (n == 4) {
			return 2;
		} else if (n == 2) {
			return 1;
		}
		return -1;
	}
	static function Integer_toString(n:Int, rdx:Int, ?digits : Int) {
		#if flash9
			var n : UInt = n;
			var s : String = untyped n.toString(rdx);
			s = s.toUpperCase();
		#else
			var s = "";
			var hexChars = charsForRadix(rdx); // "0123456789ABCDEF";
			do {
				s = hexChars.charAt(n&(/*15*/(rdx-1))) + s;
				n >>>= invPow2(rdx); // 4; // TODO: Is this right for non-hex ?
			} while( n > 0 );
		#end
		if( digits != null )
			while( s.length < digits )
				s = "0"+s;
		return s;
	}	
	
	//////////////////////////

    // The first few odd primes
    /*
            3   5   7   11  13  17  19  23  29
        31  37  41  43  47  53  59  61  67  71
        73  79  83  89  97  101 103 107 109 113
        127 131 137 139 149 151 157 163 167 173
        179 181 191 193 197 199 211 223 227 229
        233 239 241 251 257 263 269 271 277 281
        283 293 307 311 313 317 331 337 347 349
        353 359 367 373 379 383 389 397 401 409
        419 421 431 433 439 443 449 457 461 463
        467 479 487 491 499 503 509 521 523 541
        547 557 563 569 571 577 587 593 599 601
        607 613 617 619 631 641 643 647 653 659
        661 673 677 683 691 701 709 719 727 733
        739 743 751 757 761 769 773 787 797 809
        811 821 823 827 829 839 853 857 859 863
        877 881 883 887 907 911 919 929 937 941
        947 953 967 971 977 983 991 997 1009
        1013 1019 1021 1031 1033 1039 1049 1051
        1061 1063 1069 1087 1091 1093 1097 1103
        1109 1117 1123 1129 1151 1153 1163 1171
        1181 1187 1193 1201 1213 1217 1223 1229
        1231 1237 1249 1259 1277 1279 1283 1289
    */

    // Each list has a product < 2^31
    private static var primeLists:Array<Array<Int>> = 
    [
        [ 3, 5, 7, 11, 13, 17, 19, 23 ],
        [ 29, 31, 37, 41, 43 ],
        [ 47, 53, 59, 61, 67 ],
        [ 71, 73, 79, 83 ],
        [ 89, 97, 101, 103 ],

        [ 107, 109, 113, 127 ],
        [ 131, 137, 139, 149 ],
        [ 151, 157, 163, 167 ],
        [ 173, 179, 181, 191 ],
        [ 193, 197, 199, 211 ],

        [ 223, 227, 229 ],
        [ 233, 239, 241 ],
        [ 251, 257, 263 ],
        [ 269, 271, 277 ],
        [ 281, 283, 293 ],

        [ 307, 311, 313 ],
        [ 317, 331, 337 ],
        [ 347, 349, 353 ],
        [ 359, 367, 373 ],
        [ 379, 383, 389 ],

        [ 397, 401, 409 ],
        [ 419, 421, 431 ],
        [ 433, 439, 443 ],
        [ 449, 457, 461 ],
        [ 463, 467, 479 ],

        [ 487, 491, 499 ],
        [ 503, 509, 521 ],
        [ 523, 541, 547 ],
        [ 557, 563, 569 ],
        [ 571, 577, 587 ],

        [ 593, 599, 601 ],
        [ 607, 613, 617 ],
        [ 619, 631, 641 ],
        [ 643, 647, 653 ],
        [ 659, 661, 673 ],

        [ 677, 683, 691 ],
        [ 701, 709, 719 ],
        [ 727, 733, 739 ],
        [ 743, 751, 757 ],
        [ 761, 769, 773 ],

        [ 787, 797, 809 ],
        [ 811, 821, 823 ],
        [ 827, 829, 839 ],
        [ 853, 857, 859 ],
        [ 863, 877, 881 ],

        [ 883, 887, 907 ],
        [ 911, 919, 929 ],
        [ 937, 941, 947 ],
        [ 953, 967, 971 ],
        [ 977, 983, 991 ],

        [ 997, 1009, 1013 ],
        [ 1019, 1021, 1031 ],
        [ 1033, 1039, 1049 ],
        [ 1051, 1061, 1063 ],
        [ 1069, 1087, 1091 ],

        [ 1093, 1097, 1103 ],
        [ 1109, 1117, 1123 ],
        [ 1129, 1151, 1153 ],
        [ 1163, 1171, 1181 ],
        [ 1187, 1193, 1201 ],

        [ 1213, 1217, 1223 ],
        [ 1229, 1231, 1237 ],
        [ 1249, 1259, 1277 ],
        [ 1279, 1283, 1289 ]
    ];

    private static  var primeProducts:Array<Int>;

    /*private*/public static var IMASK:Int64 = Int64.make(0,0xffffffff); // L;

    //private static  var ZERO_MAGNITUDE:Array<Int> = []; // intArray(0];
	private static function ZERO_MAGNITUDE() {
		return [];
	}

    private static var SMALL_CONSTANTS : Array<BigInteger> = 
		[null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null];
	//new BigInteger[17];
    public static  var ZERO:BigInteger;
    public static  var ONE:BigInteger;
    public static  var TWO:BigInteger;
    public static  var THREE:BigInteger;
    public static  var TEN:BigInteger;

    private static var bitCounts : Array<Int> = //final static byte[] bitCounts =
    [
        0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
        1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
        1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
        1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
        2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
        3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
        3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
        4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
    ];

    private static var bitLengths:Array<Int> = // final static byte[] bitLengths =
    [
        0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
    ];

    /*
     * These are the threshold bit-lengths (of an exponent) where we increase the window size.
     * These were calculated according to the expected savings in multiplications.
     * Some squares will also be saved on average, but we offset these against the extra storage costs.
     */
    private static var EXP_WINDOW_THRESHOLDS:Array<Int>= [ 7, 25, 81, 241, 673, 1793, 4609, IntegerMAX_VALUE ];

	private static var inited = false;
	private static function initIfNotInited() {
		if (!inited) {
			initSTATIC();
			inited = true;
		}
	}
	
    public static function initSTATIC()
    {
        /*
         *  Avoid using large windows in VMs with little memory.
         *  Window size limited to 2 below 256kB, then increased by one for every doubling,
         *  i.e. at 512kB, 1MB, 2MB, etc...
         */
 /*        var totalMemory:Int64= Runtime.getRuntime().totalMemory();
        if (totalMemory <= Integer.MAX_VALUE)
        {
             var mem:Int= (int)totalMemory;
             var maxExpThreshold:Int= 1 + bitLen(mem >> 18);
            if (maxExpThreshold < EXP_WINDOW_THRESHOLDS.length)
            {
                EXP_WINDOW_THRESHOLDS[maxExpThreshold] = Integer.MAX_VALUE;
            }
        }*/

        ZERO = BigInteger.fromSignumMag(0, ZERO_MAGNITUDE());
		//trace("ZERO:" + Std.string(ZERO));
        ZERO.nBits = 0; ZERO.nBitLength = 0;

        SMALL_CONSTANTS[0] = ZERO;
         var numBits:Int= 0;
        //for ( var i:Int= 1; i < SMALL_CONSTANTS.length; ++i)
		for (i in 1...SMALL_CONSTANTS.length)
        {
            SMALL_CONSTANTS[i] = createValueOf(Int64.ofInt(i));

            // Check for a power of two
            if ((i & -i) == i)
            {
                SMALL_CONSTANTS[i].nBits = 1;
                ++numBits;
            }

            SMALL_CONSTANTS[i].nBitLength = numBits;
        }

        ONE = SMALL_CONSTANTS[1];
        TWO = SMALL_CONSTANTS[2];
        THREE = SMALL_CONSTANTS[3];
        TEN = SMALL_CONSTANTS[10];

        primeProducts = intArray(primeLists.length);

        //for ( var i:Int= 0; i < primeLists.length; ++i)
		for (i in 0...primeLists.length)
        {
             var primeList:Array<Int>= primeLists[i];
             var product:Int= 1;
            //for ( var j:Int= 0; j < primeList.length; ++j)
			for (j in 0...primeList.length)
            {
                product = mul32(product, primeList[j]) ;
            }
            primeProducts[i] = product;
        }
    }
    
    /*private*/public  var sign:Int; // -1 means -ve; +1 means +ve; 0 means 0;
    /*private*/public  var magnitude:Array<Int>; // array of ints with [0] being the most significant
    private  var nBits:Int= -1; // cache bitCount() value
    private  var nBitLength:Int= -1; // cache bitLength() value
    private  var mQuote:Int= 0; // -m^(-1) mod b, b = 2^32 (see Montgomery mult.), 0 when uninitialised

    /*private BigInteger()
    {
    }*/
	//private static var inited = false;
	public function new() {
		/*if (!inited) {
			initSTATIC();
			inited = true;
		}*/
	}

	/// HAXE-helper:
	static function intArray(len:Int, ?fillnum : Int) : Array<Int> {
		if (fillnum == null) {
			fillnum = 0;
		}
		var b = new Array<Int>();
		for (i in 0...len) {
			b[i] = fillnum;
		}
		return b;
	}
	
	// TODO: Figure out something more optimal:
	static function arraycopy(src:Array<Int>, srcpos:Int, dst:Array<Int>, dstpos:Int, len:Int) {
		for (i in 0...len) {
			dst[i + dstpos] = src[i + srcpos];
		}
	}
	
	public static function fromSignumMag(signum:Int , mag:Array<Int>) : BigInteger {
		var b = new BigInteger();
		b.init_signum_mag(signum, mag);
		return b;
	}
    public function init_signum_mag/*BigInteger*/(signum:Int , mag:Array<Int>) : Void
    {
        if (mag.length > 0)
        {
            sign = signum;

             var i:Int= 0;
            while (i < mag.length && mag[i] == 0)
            {
                i++;
            }
            if (i == 0)
            {
                magnitude = mag;
            }
            else
            {
                // strip leading 0 bytes
                 var newMag:Array<Int> = intArray(mag.length - i); // intArray(mag.length - i];
                arraycopy(mag, i, newMag, 0, newMag.length);
                magnitude = newMag;
                if (newMag.length == 0)
                    sign = 0;
            }
        }
        else
        {
            magnitude = mag;
            sign = 0;
        }
    }

	public static function fromString(sval:String) : BigInteger {
		initIfNotInited();
		var b = new BigInteger();
		b.init_sval(sval);
		return b;
	}
    public function init_sval/*BigInteger*/(sval: String) : Void ////throws NumberFormatException
    {
        //this(sval, 10);
		init_sval_rdx(sval, 10);
    }

	public static function fromStringRadix(sval:String, rdx:Int) : BigInteger {
		initIfNotInited();
		var b = new BigInteger();
		//trace("rdx=" + Std.string(rdx));
		b.init_sval_rdx(sval, rdx);
		return b;
	}	
    public function init_sval_rdx/*BigInteger*/(sval:String, rdx:Int) : Void ////throws NumberFormatException
    {
		//trace(sval);
		//var traceIt = (sval == "11");
		//trace(rdx);
        if (sval.length == 0)
        {
            throw "Zero length BigInteger"; //            throw new NumberFormatException("Zero length BigInteger");
        }

        if (rdx < Character_MIN_RADIX || rdx > Character_MAX_RADIX)
        {
            throw "Radix out of range"; //            throw new NumberFormatException("Radix out of range");
        }

         var index:Int= 0;
        sign = 1;

        if (sval.charAt(0) == '-')
        {
            if (sval.length == 1)
            {
                throw "Zero length BigInteger"; //                throw new NumberFormatException("Zero length BigInteger");
            }

            sign = -1;
            index = 1;
        }

        // strip leading zeros from the string value
        while (index < sval.length && digit(sval.charAt(index), rdx) == 0)
        {
            index++;
        }

        if (index >= sval.length)
        {
			trace("zeroValue:" + sval);
            // zero value - we're done
            sign = 0;
            magnitude = intArray(0); // intArray(0];
            return;
        }

        //////
        // could we work out the max number of ints required to store
        // sval.length digits in the given base, then allocate that
        // storage in one hit?, then generate the magnitude in one hit too?
        //////

		//trace(ZERO);
         var b:BigInteger= ZERO;
         var r:BigInteger = valueOfInt(rdx);
		 //////trace("r:BigInteger=" + Std.string(r));
		 ////trace("sval.length: " + Std.string(sval.length));
		 var i = 0;
        while (index < sval.length)
        {
			//trace("b.magnitude=" + Std.string(b.magnitude));
			//trace("r.magnitude=" + Std.string(r.magnitude));
			//////trace("index=" + Std.string(b));
			i++;
			//if (i > 5) throw "UGH";
            // (optimise this by taking chunks of digits instead?)
			//b = b.multiply(r);
			////trace("b.magnitude_after_mul=" + Std.string(b.magnitude));
			
			//var dig = digit(sval.charAt(index), rdx);
			//if (traceIt) trace("digit: " + Std.string(dig) + " from " + sval.charAt(index));
			//trace("valueOf: " + Std.string(valueOfInt(dig).magnitude));
			
			//b = b.add(valueOfInt(digit(sval.charAt(index), rdx)));
			//trace("b.magnitude_after_add=" + Std.string(b.magnitude));
			
            b = b.multiply(r).add(valueOfInt(digit(sval.charAt(index), rdx)));
			
			/*if (traceIt) {
				trace(r.magnitude);
				trace(b.magnitude);
			}*/
			
            index++;
        }
		//if (traceIt) throw "DONEER";

        magnitude = b.magnitude;
		//trace("rdx=" + Std.string(rdx));
		//trace("magnitude=" + Std.string(magnitude));
		
		//trace("NEW BIGINT = " + Std.string(magnitude));
        return;
    }
	
	

	public static function fromBytes(bval:Bytes) : BigInteger {
		var b = new BigInteger();
		b.init_bval(bval);
		return b;
	}
	
	/*
	/// JAVA VERSION
    public function init_bval(bval:Bytes) : Void // BigInteger(byte[] bval) //throws NumberFormatException
    {
        if (bval.length == 0)
        {
            throw "Zero length BigInteger"; //            throw new NumberFormatException("Zero length BigInteger");
        }

        sign = 1;
        if (bval.get(0) < 0)
        {
            sign = -1;
        }
        magnitude = makeMagnitude(bval, sign);
        if (magnitude.length == 0) {
            sign = 0;
        }
    }*/

	/// C# VERSION
    public function init_bval(bval:Bytes) : Void // BigInteger(byte[] bval) //throws NumberFormatException
    {
        if (bval.length == 0)
        {
            throw "Zero length BigInteger"; //            throw new NumberFormatException("Zero length BigInteger");
        }

        sign = 1;
        if (bval.get(0) >= 0x80) //< 0)
        {
			/*trace("IS NEGATIVE");
		// FIXME:
			var iBval:Int;
			sign = -1;
			// strip leading sign bytes
			//for (iBval = 0; iBval < bval.ength && (bval.get(iBval) == 0xFF); iBval++) ;
			iBval = 0;
			while (iBval < bval.length && (bval.get(iBval) == 0xFF)) {
				trace("IS SO");
				iBval++;
			}
			trace("iBval=" + Std.string(iBval));
			magnitude = intArray(Math.floor((bval.length - iBval) / 2) + 1);
			// copy bytes to magnitude
			// invert bytes then add one to find magnitude of value*/
this.sign = -1;

var length = bval.length;
var offset = 0;
				var end = offset + length;

				var iBval = offset;
				// strip leading sign bytes
				while (iBval < end && (bval.get(iBval) == 0xFF)) { //-1) {
					iBval++;
				}
				/*for (iBval = offset; iBval < end && ((sbyte)bytes[iBval] == -1); iBval++)
				{
				}*/

				if (iBval >= end)
				{
					this.magnitude = ONE.magnitude;
				}
				else
				{
					var numBytes = end - iBval;
					var inverse = Bytes.alloc(numBytes);

					var index = 0;
					while (index < numBytes)
					{
						//inverse[index++] = (byte)~bytes[iBval++];
						inverse.set(index++,~bval.get(iBval++));
					}

					//Debug.Assert(iBval == end);

					while (inverse.get(--index) == 0xFF) //byte.MaxValue)
					{
						//inverse[index] = byte.MinValue;
						inverse.set(index, 0);
					}

					//inverse[index]++;
					inverse.set(index, inverse.get(index) + 1);

					this.magnitude = makeMagnitudeBytes(inverse); // , 0, inverse.Length);
				}			
		}
		else
		{
			// strip leading zero bytes and return magnitude bytes
			magnitude = makeMagnitudeBytes(bval);
			sign = magnitude.length > 0 ? 1 : 0;
		}
		//trace("init_bval/magnitude:" + Std.string(magnitude));
    }
	private function makeMagnitudeBytes(bval:Bytes) : Array<Int>
        {
            var i:Int;
            var mag:Array<Int>;
            var firstSignificant:Int;

            // strip leading zeros
			
            //for (firstSignificant = 0; firstSignificant < bval.Length
            //        && bval[firstSignificant] == 0; firstSignificant++) ;
			firstSignificant = 0;
			while (firstSignificant < bval.length && bval.get(firstSignificant) == 0) {
				firstSignificant++;
			}

            if (firstSignificant >= bval.length)
            {
                return [];// new int[0];
            }

            var nInts:Int = Math.floor((bval.length - firstSignificant + 3) / 4);
            var bCount:Int = (bval.length - firstSignificant) % 4;
            if (bCount == 0)
                bCount = 4;

            mag = intArray(nInts);
            var v:Int = 0;
            var magnitudeIndex:Int = 0;
            //for (i = firstSignificant; i < bval.Length; i++)
			for (i in firstSignificant...bval.length)
            {
                v <<= 8;
                v |= bval.get(i) & 0xff;
                bCount--;
                if (bCount <= 0)
                {
                    mag[magnitudeIndex] = v;
                    magnitudeIndex++;
                    bCount = 4;
                    v = 0;
                }
            }

            if (magnitudeIndex < mag.length)
            {
                mag[magnitudeIndex] = v;
            }

            return mag;
        }	
	

		public static function fromSignBytes(sign:Int, mag:Bytes) {
			var b = new BigInteger();
			b.init_fromSignBytes(sign, mag);
			return b;
		}
		
		private function init_fromSignBytes(sign:Int, mag:Bytes) {
			if (sign < -1 || sign > 1)
			{
				throw /*new NumberFormatException(*/"Invalid sign value"; // );
			}

			var ret = new BigInteger();
			
			if (sign == 0)
			{
				this.sign = 0;
				this.magnitude = []; // new int[0];
				return;
			}

			// copy bytes
			this.magnitude = makeMagnitude(mag, 1);
			this.sign = sign;			
		}
		
    /**
     * If sign >= 0, packs bytes into an array of ints, most significant first
     * If sign <  0, packs 2's complement of bytes into 
     * an array of ints, most significant first,
     * adding an extra most significant byte in case bval = {0x80, 0x00, ..., 0x00}
     *
     * @param bval
     * @param sign
     * @return
     */
	 private  function makeMagnitude(bval:Bytes, sign:Int):Array<Int>
    {
        if (sign >= 0) {
             var i:Int;
             var mag:Array<Int>;
             var firstSignificant:Int;

            // strip leading zeros
			firstSignificant = 0;
			while (firstSignificant < bval.length
                    && bval.get(firstSignificant) == 0) {
						firstSignificant++;
					}
            /*for (firstSignificant = 0; firstSignificant < bval.length
                    && bval.get(firstSignificant] == 0; firstSignificant++);*/
			

            if (firstSignificant >= bval.length)
            {
                return intArray(0); // intArray(0];
            }

             var nInts:Int= Math.floor((bval.length - firstSignificant + 3) / 4);
             var bCount:Int= (bval.length - firstSignificant) % 4;            
            if (bCount == 0)
                bCount = 4;
            // n = k * (n / k) + n % k
            // bval.length - firstSignificant + 3 = 4 * nInts + bCount - 1
            // bval.length - firstSignificant + 4 - bCount = 4 * nInts

            mag = intArray(nInts); // intArray(nInts];
             var v:Int= 0;
             var magnitudeIndex:Int= 0;
            //for (i = firstSignificant; i < bval.length; i++)
			for (i in firstSignificant...bval.length)
            {
                // bval.length + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
                // 1 <= bCount <= 4
                v <<= 8;
                v |= bval.get(i) & 0xff;
                bCount--;
                if (bCount <= 0)
                {
                    mag[magnitudeIndex] = v;
                    magnitudeIndex++;
                    bCount = 4;
                    v = 0;
                }
            }
            // 4 - bCount + 4 * magnitudeIndex = 4 * nInts
            // bCount = 4 * (1 + magnitudeIndex - nInts)
            // 1 <= bCount <= 4
            // So bCount = 4 and magnitudeIndex = nInts = mag.length

//            if (magnitudeIndex < mag.length)
//            {
//                mag[magnitudeIndex] = v;
//            }
            return mag;
        }
        else {
             var i:Int;
             var mag:Array<Int>;
             var firstSignificant:Int;
            

            // strip leading -1's
			firstSignificant = 0;
			while (firstSignificant < bval.length - 1 && bval.get(firstSignificant) == 0xff) {
				firstSignificant++;
			}
            /*for (firstSignificant = 0; firstSignificant < bval.length - 1
                    && bval.get(firstSignificant] == 0xff; firstSignificant++);*/

             var nBytes:Int= bval.length;
             var leadingByte:Bool= false;

            // check for -2^(n-1)
            if (bval.get(firstSignificant) == 0x80) {
                //for (i = firstSignificant + 1; i < bval.length; i++) {
				var j = firstSignificant;
				for (i in firstSignificant + 1...bval.length) {
					j = i;
                    if (bval.get(i) != 0) {
                        break;
                    }
                }
                if (j == bval.length) {
                    nBytes++;
                    leadingByte = true;
                }
            }

             var nInts:Int= Math.floor((nBytes - firstSignificant + 3) / 4);
             var bCount:Int= (nBytes - firstSignificant) % 4;
            if (bCount == 0)
                bCount = 4;

            // n = k * (n / k) + n % k
            // nBytes - firstSignificant + 3 = 4 * nInts + bCount - 1
            // nBytes - firstSignificant + 4 - bCount = 4 * nInts
            // 1 <= bCount <= 4

            mag = intArray(nInts); // intArray(nInts];
             var v:Int= 0;
             var magnitudeIndex:Int= 0;
            // nBytes + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
            // 1 <= bCount <= 4
            if (leadingByte) {
                // bval.length + 1 + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
                bCount--;
                // bval.length + 1 + 4 - (bCount + 1) - i + 4 * magnitudeIndex = 4 * nInts
                // bval.length + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
                if (bCount <= 0)
                {
                    magnitudeIndex++;
                    bCount = 4;
                }
                // bval.length + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
                // 1 <= bCount <= 4
            }
            //for (i = firstSignificant; i < bval.length; i++)
			for (i in firstSignificant...bval.length)
            {
                // bval.length + 4 - bCount - i + 4 * magnitudeIndex = 4 * nInts
                // 1 <= bCount <= 4
                v <<= 8;
                v |= ~bval.get(i) & 0xff;
                bCount--;
                if (bCount <= 0)
                {
                    mag[magnitudeIndex] = v;
                    magnitudeIndex++;
                    bCount = 4;
                    v = 0;
                }
            }
            // 4 - bCount + 4 * magnitudeIndex = 4 * nInts
            // 1 <= bCount <= 4
            // bCount = 4 * (1 + magnitudeIndex - nInts)
            // 1 <= bCount <= 4
            // So bCount = 4 and magnitudeIndex = nInts = mag.length

//            if (magnitudeIndex < mag.length)
//            {
//                mag[magnitudeIndex] = v;
//            }
            mag = inc(mag);

            // TODO Fix above so that this is not necessary?
            if (mag[0] == 0)
            {
                 var tmp:Array<Int>= intArray(mag.length - 1);
                arraycopy(mag, 1, tmp, 0, tmp.length);
                mag = tmp;
            }

            return mag;
        }
    }
    
    

	public static function fromSignMag(sign:Int, mag:Bytes) : BigInteger {
		var  b = new BigInteger();
		b.init_sign_mag(sign, mag);
		return b;
	}
    public function init_sign_mag/*BigInteger*/(sign:Int, mag:Bytes) ////throws NumberFormatException
    {
        if (sign < -1 || sign > 1)
        {
            throw "Invalid sign value"; //            throw new NumberFormatException("Invalid sign value");
        }

        if (sign == 0)
        {
            this.sign = 0;
            this.magnitude = intArray(0); // intArray(0];
            return;
        }

        // copy bytes
        this.magnitude = makeMagnitude(mag, 1);
        this.sign = sign;
    }

	public static function fromNumbitsRandom(numBits:Int, rnd:Random) : BigInteger {
		var  b = new BigInteger();
		b.init_numBits_rnd(numBits, rnd);
		/*if (numBits >= 33) {
			trace(b.magnitude);
		}*/
		return b;
	}	
    public function init_numBits_rnd/*BigInteger*/(numBits:Int, rnd:Random) ////throws IllegalArgumentException
    {
        if (numBits < 0)
        {
            throw "numBits must be non-negative"; //            throw new IllegalArgumentException("numBits must be non-negative");
        }

        this.nBits = -1;
        this.nBitLength = -1;

        if (numBits == 0)
        {
//          this.sign = 0;
            this.magnitude = ZERO_MAGNITUDE();
            return;
        }

         var nBytes:Int= Math.floor((numBits + 7) / 8);

        //byte[] b = new byte[nBytes];
		var b:Bytes = Bytes.alloc(nBytes);
        nextRndBytes(rnd, b);

        // strip off any excess bits in the MSB
         var xBits:Int= mul32(BITS_PER_BYTE , nBytes) - numBits;
        b.get(0) &= /*(byte)*/(255 >>> xBits);

        this.magnitude = makeMagnitude(b, 1);
        this.sign = this.magnitude.length < 1 ? 0 : 1;
    }

    private static var BITS_PER_BYTE:Int= 8;
    private static var BYTES_PER_INT:Int= 4;

    /**
     * strictly speaking this is a little dodgey from a compliance
     * point of view as it forces people to be using SecureRandom as
     * well, that being said - this implementation is for a crypto
     * library and you do have the source!
     */
    private function nextRndBytes(rnd:Random, bytes:Bytes) : Void
    {
         var numRequested:Int= bytes.length;
        var numGot:Int = 0, 
        r = 0;

		// TODO: 
        /*if (rnd instanceof java.security.SecureRandom)
        {
            ((java.security.SecureRandom)rnd).nextBytes(bytes);
        }
        else
        {*/
            while(true) //for (; ; )
            {
                //for ( var i:Int= 0; i < BYTES_PER_INT; i++)
				for (i in 0...BYTES_PER_INT)
                {
                    if (numGot == numRequested)
                    {
                        return;
                    }

                    r = (i == 0 ? rnd.nextInt() : r >> BITS_PER_BYTE);
                    //bytes[numGot++] = r;// (byte) r;
					bytes.set(numGot++, r);
                }
            }
        /*}*/
    }

	public static function fromLengthCertaintyRandom(bitLength:Int, certainty:Int, rnd:Random) : BigInteger {
		var b = new BigInteger();
		b.init_length_certainty_rnd(bitLength, certainty, rnd);
		return b;
	}
    public function init_length_certainty_rnd/*BigInteger*/(bitLength:Int, certainty:Int, rnd:Random) ////throws ArithmeticException
    {
        if (bitLength < 2)
        {
            throw "bitLength < 2"; //            throw new ArithmeticException("bitLength < 2");
        }

        this.sign = 1;
        this.nBitLength = bitLength;

        if (bitLength == 2)
        {
            this.magnitude = rnd.nextInt() < 0
                ?   TWO.magnitude
                :   THREE.magnitude;
            return;
        }

         var nBytes:Int= Math.floor((bitLength + 7) / BITS_PER_BYTE);
         var xBits:Int= mul32(BITS_PER_BYTE , nBytes) - bitLength;
        //var mask:Byte = (255 >>> xBits); // TODO : NB : Byte vs Int overflow ?
        var mask:Byte = (255 >>> xBits) << 56 >>> 56; // TODO : NB : Byte vs Int overflow ?

        var b : Bytes = Bytes.alloc(nBytes); // byte[] b = new byte[nBytes];

        //for (;;)
		while (true)
        {
            nextRndBytes(rnd, b);

            // strip off any excess bits in the MSB
            b.get(0) &= mask;

            // ensure the leading bit is 1 (to meet the strength requirement)
            b.get(0) |= /*(byte)*/(1 << (7 - xBits));

            // ensure the trailing bit is 1 (i.e. must be odd)
            b.get(nBytes - 1) |= /*/*(byte)*/1;

            this.magnitude = makeMagnitude(b, 1);
            this.nBits = -1;
            this.mQuote = 0;

            if (certainty < 1)
                break;

            if (this.isProbablePrime(certainty))
                break;

            if (bitLength > 32)
            {
                //for ( var rep:Int= 0; rep < 10000; ++rep)
				// TODO : is this right ?   "++rep"
				for (rep in 0...10000)
                {
                     var n:Int= 33 + (rnd.nextInt() >>> 1) % (bitLength - 2);
                    this.magnitude[this.magnitude.length - (n >>> 5)] ^= (1 << (n & 31));
                    this.magnitude[this.magnitude.length - 1] ^= (rnd.nextInt() << 1);
                    this.mQuote = 0;

                    if (this.isProbablePrime(certainty))
                        return;
                }
            }
        }
    }

    public  function abs():BigInteger
    {
        return (sign >= 0) ? this : this.negate();
    }

    /**
     * return a = a + b - b preserved.
     */
    private  function addArr(a:Array<Int>, b:Array<Int>):Array<Int>
    {
         var tI:Int= a.length - 1;
         var vI:Int= b.length - 1;
         var m:Int64= Int64.ofInt(0);

        while (vI >= 0)
        {
            m = Int64.add(m, Int64.add((Int64.and((Int64.ofInt(a[tI])), IMASK)), (Int64.and((Int64.ofInt(b[vI--])), IMASK))));    
            a[tI--] = Int64.toInt(m);
            m = Int64.ushr(m, 32);    
        }

        while (tI >= 0 && (!Int64.isZero(m))) //m != 0)
        {
            m = Int64.add(m, (Int64.and((Int64.ofInt(a[tI])), IMASK)));    
            a[tI--] = Int64.toInt(m);
            m = Int64.ushr(m, 32);    
        }

        return a;
    }

    /**
     * return a = a + 1.
     */
    private  function inc(a:Array<Int>):Array<Int>
    {
         var tI:Int= a.length - 1;
         var m:Int64= Int64.ofInt(0);

        m = Int64.add(Int64.and((Int64.ofInt(a[tI])), IMASK), Int64.ofInt(1)); // L;
        a[tI--] = Int64.toInt(m);
        m = Int64.ushr(m, 32);    

        while (tI >= 0 && (!Int64.isZero(m))) //m != 0)
        {
            m = Int64.add(m, (Int64.and((Int64.ofInt(a[tI])), IMASK)));    
            a[tI--] = Int64.toInt(m);
            m = Int64.ushr(m, 32);    
        }

        return a;
    }

    public  function add(val:BigInteger):BigInteger //ArithmeticException
    {
        if (val.sign == 0 || val.magnitude.length == 0)
            return this;
        if (this.sign == 0 || this.magnitude.length == 0)
            return val;

        if (val.sign < 0)
        {
			//trace("val=" + Std.string(val.sign));
			//trace("valNeg=" + Std.string(val.negate().sign));
			
            if (this.sign > 0)
                return this.subtract(val.negate());
        }
        else
        {
            if (this.sign < 0)
                return val.subtract(this.negate());
        }

        return addToMagnitude(val.magnitude);
    }

    private function addToMagnitude(
        magToAdd:Array<Int>) : BigInteger
    {
        var big:Array<Int>;
		var small:Array<Int>;
		
		//var traceit = false;
		/*if (magToAdd[0] == -1120314150) {
			traceit = true;
		}
		
		if (traceit) trace("magToAdd=" + magToAdd);
		*/
        if (this.magnitude.length < magToAdd.length)
        {
            big = magToAdd;
            small = this.magnitude;
        }
        else
        {
            big = this.magnitude;
            small = magToAdd;
        }

        // Conservatively avoid over-allocation when no overflow possible
         var limit:Int = IntegerMAX_VALUE | 0;
		 //if (traceit) trace("limit:" + limit);
        if (big.length == small.length)
            limit = limit - small[0] | 0;
			
        //if (traceit) trace("big[0] = " + big[0]);
			
        //if (traceit) trace("(big[0] ^ (1 << 31))  =   " + (big[0] ^ (1 << 31)));

         var possibleOverflow:Bool = (big[0] ^ (1 << 31)) >= limit;
		 //if (traceit) trace("limit:" + limit);
		 //trace("possibleOverflow = " + possibleOverflow);
		//if (traceit) throw "PAUSE";

         var extra:Int= possibleOverflow ? 1 : 0;

         var bigCopy:Array<Int>= intArray(big.length + extra);
        arraycopy(big, 0, bigCopy, extra, big.length);

        bigCopy = addArr(bigCopy, small);

		return BigInteger.fromSignumMag(this.sign, bigCopy);
    }

    public function and(
        value:BigInteger) : BigInteger
    {
        if (this.sign == 0 || value.sign == 0)
        {
            return ZERO;
        }

        var aMag:Array<Int> = this.sign > 0
            ? this.magnitude
            : add(ONE).magnitude;

        var bMag:Array<Int> = value.sign > 0
            ? value.magnitude
            : value.add(ONE).magnitude;

         var resultNeg:Bool= sign < 0 && value.sign < 0;
         var resultLength:Int= Math.floor(Math.max(aMag.length, bMag.length));
         var resultMag:Array<Int> = intArray(resultLength); // intArray(resultLength];

         var aStart:Int= resultMag.length - aMag.length;
         var bStart:Int= resultMag.length - bMag.length;

        //for ( var i:Int= 0; i < resultMag.length; ++i)
		for (i in 0...resultMag.length)
        {
             var aWord:Int= i >= aStart ? aMag[i - aStart] : 0;
             var bWord:Int= i >= bStart ? bMag[i - bStart] : 0;

            if (this.sign < 0)
            {
                aWord = ~aWord;
            }

            if (value.sign < 0)
            {
                bWord = ~bWord;
            }

            resultMag[i] = aWord & bWord;

            if (resultNeg)
            {
                resultMag[i] = ~resultMag[i];
            }
        }

         var result:BigInteger= BigInteger.fromSignumMag(1, resultMag);

        // TODO Optimise this case
        if (resultNeg)
        {
            result = result.not();
        }

        return result;
    }

    public function andNot(
        value:BigInteger) : BigInteger
    {
        return and(value.not());
    }

    public  function bitCount():Int
    {
        if (nBits == -1)
        {
            if (sign < 0)
            {
                // TODO Optimise this case
                nBits = not().bitCount();
            }
            else
            {
                 var sum:Int= 0;
                //for ( var i:Int= 0; i < magnitude.length; i++)
				for (i in 0...magnitude.length)
                {
                    sum += bitCounts[magnitude[i] & 0xff];
                    sum += bitCounts[(magnitude[i] >> 8) & 0xff];
                    sum += bitCounts[(magnitude[i] >> 16) & 0xff];
                    sum += bitCounts[(magnitude[i] >> 24) & 0xff];
                }
                nBits = sum;
            }
        }

        return nBits;
    }

    private static  function calcBitLength(sign:Int, indx:Int, mag:Array<Int>):Int
    {
        if (mag.length == 0)
        {
            return 0;
        }

        while (indx != mag.length && mag[indx] == 0)
        {
            indx++;
        }

        if (indx == mag.length)
        {
            return 0;
        }

        // bit length for everything after the first int
         var bitLength:Int= mul32(32 , ((mag.length - indx) - 1));

        // and determine bitlength of first int
        bitLength += bitLen(mag[indx]);

        if (sign < 0)
        {
            // Check if magnitude is a power of two
            var pow2:Bool = ((bitCounts[mag[indx] & 0xff])
                    + (bitCounts[(mag[indx] >> 8) & 0xff])
                    + (bitCounts[(mag[indx] >> 16) & 0xff])
                    + (bitCounts[(mag[indx] >> 24) & 0xff])) == 1;

            //for ( var i:Int= indx + 1; i < mag.length && pow2; i++)
			var i = indx + 1;
			while (i < mag.length && pow2)
            {
                pow2 = (mag[i] == 0);
				i++;
            }

            bitLength -= (pow2 ? 1 : 0);
        }

		/*if (bitLength <= 33) {
			trace("calcBitLen=" + Std.string(bitLength));
		}*/
        return bitLength;
    }

    public  function bitLength():Int
    {
		//////trace("SIGN:" + Std.string(sign));
		//////trace("magnitude:" + Std.string(magnitude));
        if (nBitLength == -1)
        {
            if (sign == 0)
            {
                nBitLength = 0;
            }
            else
            {
                nBitLength = calcBitLength(sign, 0, magnitude);
            }
        }

        return nBitLength;
		//return calcBitLength(sign, 0, magnitude);
    }

    //
    // bitLen(value) is the number of bits in value.
    //
    private static  function bitLen(w:Int):Int
    {
         var t:Int= w >>> 24;
        if (t != 0)
        {
            return 24 + bitLengths[t];
        }
        t = w >>> 16;
        if (t != 0)
        {
            return 16 + bitLengths[t];
        }
        t = w >>> 8;
        if (t != 0)
        {
            return 8 + bitLengths[t];
        }
        return bitLengths[w];
    }

    private  function quickPow2Check():Bool
    {
        return sign > 0 && nBits == 1;
    }

	// TODO ?
    /*public  function compareTo(Object o):Int
    {
        return compareTo((BigInteger)o);
    }*/

    /**
     * unsigned comparison on two arrays - note the arrays may
     * start with leading zeros.
     */
    private static  function compareToArr(xIndx:Int, x:Array<Int>, yIndx:Int, y:Array<Int>):Int
    {
        while (xIndx != x.length && x[xIndx] == 0)
        {
            xIndx++;
        }

        while (yIndx != y.length && y[yIndx] == 0)
        {
            yIndx++;
        }

        return compareNoLeadingZeroes(xIndx, x, yIndx, y);
    }

    private static  function compareNoLeadingZeroes(xIndx:Int, x:Array<Int>, yIndx:Int, y:Array<Int>):Int
    {
         var diff:Int= (x.length - y.length) - (xIndx - yIndx);

        if (diff != 0)
        {
            return diff < 0 ? -1 : 1;
        }

        // lengths of magnitudes the same, test the magnitude values

        while (xIndx < x.length)
        {
             var v1:Int= x[xIndx++];
             var v2:Int= y[yIndx++];

            if (v1 != v2)
            {
                return (v1 ^ IntegerMIN_VALUE) < (v2 ^ IntegerMIN_VALUE) ? -1 : 1;
            }
        }

        return 0;
    }

    public  function compareTo(val:BigInteger):Int
    {
        if (sign < val.sign)
            return -1;
        if (sign > val.sign)
            return 1;
        if (sign == 0)
            return 0;

        return sign * compareToArr(0, magnitude, 0, val.magnitude);
    }

    /**
     * return z = x / y - done in place (z value preserved, x contains the
     * remainder)
     */
    private  function divideArr(x:Array<Int>, y:Array<Int>):Array<Int>
    {
         var xyCmp:Int= compareToArr(0, x, 0, y);
         var count:Array<Int>;

        if (xyCmp > 0)
        {
             var c:Array<Int>;

             var shift:Int= calcBitLength(1, 0, x) - calcBitLength(1, 0, y);

            if (shift > 1)
            {
                c = shiftLeftArr(y, shift - 1);
				//throw Std.string(c.length);
                count = shiftLeftArr(ONE.magnitude, shift - 1);
                if (shift % 32 == 0)
                {
                    // Special case where the shift is the size of an int.
                    var countSpecial = intArray(Math.floor(shift / 32) + 1);
                    arraycopy(count, 0, countSpecial, 1, countSpecial.length - 1);
                    countSpecial[0] = 0;
                    count = countSpecial;
                }
            }
            else
            {
                c = intArray(x.length);
                count = intArray(1); // intArray(1];

                arraycopy(y, 0, c, c.length - y.length, y.length);
                count[0] = 1;
            }

             var iCount:Array<Int>= intArray(count.length);

            subtractArr(0, x, 0, c);
            arraycopy(count, 0, iCount, 0, count.length);

             var xStart:Int= 0;
             var cStart:Int= 0;
             var iCountStart:Int= 0;

            //for (; ; )
			while (true)
            {
                 var cmp:Int= compareToArr(xStart, x, cStart, c);

                while (cmp >= 0)
                {
                    subtractArr(xStart, x, cStart, c);
                    addArr(count, iCount);
                    cmp = compareToArr(xStart, x, cStart, c);
                }

                xyCmp = compareToArr(xStart, x, 0, y);

                if (xyCmp > 0)
                {
                    if (x[xStart] == 0)
                    {
                        xStart++;
                    }

                    shift = calcBitLength(1, cStart, c) - calcBitLength(1, xStart, x);

                    if (shift == 0)
                    {
                        shiftRightOneInPlace(cStart, c);
                        shiftRightOneInPlace(iCountStart, iCount);
                    }
                    else
                    {
                        shiftRightInPlace(cStart, c, shift);
                        shiftRightInPlace(iCountStart, iCount, shift);
                    }

                    if (c[cStart] == 0)
                    {
                        cStart++;
                    }

                    if (iCount[iCountStart] == 0)
                    {
                        iCountStart++;
                    }
                }
                else if (xyCmp == 0)
                {
                    addArr(count, ONE.magnitude);
                    //for ( var i:Int= xStart; i != x.length; i++)
					for (i in xStart...x.length)
                    {
                        x[i] = 0;
                    }
                    break;
                }
                else
                {
                    break;
                }
            }
        }
        else if (xyCmp == 0)
        {
            //count = intArray(1); // intArray(1];
			count = intArray(1); // intArray(1];
            count[0] = 1;
			for (i in 0...x.length) {
				x[i] = 0;
			}
            //Arrays.fill(x, 0);
        }
        else
        {
            count = intArray(1); // intArray(1];
            count[0] = 0;
        }

        return count;
    }

    public  function divide(val:BigInteger):BigInteger ////throws:BigInteger ArithmeticException
    {
        if (val.sign == 0)
        {
            throw "Divide by zero"; //            throw new ArithmeticException("Divide by zero");
        }

        if (sign == 0)
        {
            return BigInteger.ZERO;
        }

        if (val.compareTo(BigInteger.ONE) == 0)
        {
            return this;
        }

         var mag:Array<Int>= intArray(this.magnitude.length);
        arraycopy(this.magnitude, 0, mag, 0, mag.length);

        return BigInteger.fromSignumMag(this.sign * val.sign, divideArr(mag, val.magnitude));
    }
	

	/// HAXE-helper:
	static function bigIntArray(len:Int) : Array<BigInteger> {
		var b = new Array<BigInteger>();
		for (i in 0...len) {
			//b[i] = null;
			b.push(null);
		}
		return b;
	}

    public function divideAndRemainder(val:BigInteger) : Array<BigInteger> ////throws ArithmeticException
    {
        if (val.sign == 0)
        {
            throw "Divide by zero"; //            throw new ArithmeticException("Divide by zero");
        }

        var biggies:Array<BigInteger> = bigIntArray(2); // new BigInteger[2];

        if (sign == 0)
        {
            biggies[0] = biggies[1] = BigInteger.ZERO;

            return biggies;
        }

        if (val.compareTo(BigInteger.ONE) == 0)
        {
            biggies[0] = this;
            biggies[1] = BigInteger.ZERO;

            return biggies;
        }

         var remainder:Array<Int>= intArray(this.magnitude.length);
        arraycopy(this.magnitude, 0, remainder, 0, remainder.length);

         var quotient:Array<Int>= divideArr(remainder, val.magnitude);

        biggies[0] = BigInteger.fromSignumMag(this.sign * val.sign, quotient);
        biggies[1] = BigInteger.fromSignumMag(this.sign, remainder);

        return biggies;
    }

	// TODO:
    public  function equals(val:BigInteger):Bool
    {
        if (val == this)
            return true;

        /*if (!(val instanceof BigInteger))
            return false;
         var biggie:BigInteger= (BigInteger)val;
		*/
        return sign == val.sign && isEqualMagnitude(val);
    }
	

    private  function isEqualMagnitude(x:BigInteger):Bool
    {
        if (magnitude.length != x.magnitude.length)
        {
            return false;
        }
        //for ( var i:Int= 0; i < magnitude.length; i++)
		for (i in 0...magnitude.length)
        {
            if (magnitude[i] != x.magnitude[i])
            {
                return false;
            }
        }
        return true;
    }

    public  function gcd(val:BigInteger):BigInteger
    {
        if (val.sign == 0)
            return this.abs();
        else if (sign == 0)
            return val.abs();

         var r:BigInteger;
         var u:BigInteger= this;
         var v:BigInteger= val;

        while (v.sign != 0)
        {
            r = u.mod(v);
            u = v;
            v = r;
        }

        return u;
    }

    public  function hashCode():Int
    {
         var hc:Int= magnitude.length;

        if (magnitude.length > 0)
        {
            hc ^= magnitude[0];

            if (magnitude.length > 1)
            {
                hc ^= magnitude[magnitude.length - 1];
            }
        }

        return sign < 0 ? ~hc : hc;
    }

    public function intValue():Int
    {
        if (sign == 0)
        {
            return 0;
        }

         var n:Int= magnitude.length;

         var val:Int= magnitude[n - 1];

        return sign < 0 ? -val : val;
    }

    public function byteValue() : Byte
    {
        return intValue();
    }

    /**
     * return whether or not a BigInteger is probably prime with a
     * probability of 1 - (1/2)**certainty.
     * <p>
     * From Knuth Vol 2, pg 395.
     */
    public  function isProbablePrime(certainty:Int):Bool
    {
        if (certainty <= 0)
            return true;

        if (sign == 0)
            return false;

         var n:BigInteger= this.abs();

        if (!n.testBit(0))
            return n.equals(TWO);

        if (n.equals(ONE))
            return false;

        // Try to reduce the penalty for really small numbers
         var numLists:Int= Math.floor(Math.min(n.bitLength() - 1, primeLists.length));

        //for ( var i:Int= 0; i < numLists; ++i)
		for (i in 0...numLists)
        {
             var test:Int= n.remainderInt(primeProducts[i]);

             var primeList:Array<Int>= primeLists[i];
            //for ( var j:Int= 0; j < primeList.length; ++j)
			for (j in 0...primeList.length)
            {
                 var prime:Int= primeList[j];
                 var qRem:Int= test % prime;
                if (qRem == 0)
                {
                    // We may find small numbers in the list
                    return n.bitLength() < 16 && n.intValue() == prime;
                }
            }
        }

        //
        // let n = 1 + 2^kq
        //
         var s:Int= n.getLowestSetBitMaskFirst(-1 << 1);
         var r:BigInteger= n.shiftRight(s);

        var random:Random = new Random();

        // NOTE: Avoid conversion to/from Montgomery form and check for R/-R as result instead

         var montRadix:BigInteger= ONE.shiftLeft(32 * n.magnitude.length).remainder(n);
         var minusMontRadix:BigInteger= n.subtract(montRadix);

        do
        {
             var a:BigInteger;

            do
            {
                a = BigInteger.fromNumbitsRandom(n.bitLength(), random);
            }
            while (a.sign == 0 || a.compareTo(n) >= 0
                || a.isEqualMagnitude(montRadix) || a.isEqualMagnitude(minusMontRadix));

             var y:BigInteger= modPowMonty(a, r, n, false);

            if (!y.equals(montRadix))
            {
                 var j:Int= 0;
                while (!y.equals(minusMontRadix))
                {
                    if (++j == s)
                    {
                        return false;
                    }

                    y = modPowMonty(y, TWO, n, false);

                    if (y.equals(montRadix))
                    {
                        return false;
                    }
                }
            }

            certainty -= 2; // composites pass for only 1/4 possible 'a'
        }
        while (certainty > 0);

        return true;
    }

    public function longValue():Int64
    {
        if (sign == 0)
        {
            return Int64.ofInt(0);
        }

         var n:Int= magnitude.length;

         var val:Int64 = Int64.and(Int64.ofInt(magnitude[n - 1]), IMASK);    // NB
		 
		 //////trace("IMASK=" + Std.string(IMASK));
		 //////trace("VAL=" + Std.string(val));
		 
        if (n > 1)
        {
			//////trace("magnitude[n - 2] = " + Std.string(magnitude[n - 2]));
			//////trace("magnitude[n - 2] & IMASK = " + Std.string(Int64.and(Int64.ofInt(magnitude[n - 2]), IMASK)));
			//////trace("(magnitude[n - 2] & IMASK) << 32 = " + Std.string(Int64.shl(Int64.and(Int64.ofInt(magnitude[n - 2]), IMASK),32)));
            val = Int64.or(val, Int64.shl((Int64.and(Int64.ofInt(magnitude[n - 2]), IMASK)) , 32));    // NB
			//////trace("val=" + Std.string(val));
        }

        return sign < 0 ? Int64.neg(val) : val;
    }

    public  function max(val:BigInteger):BigInteger
    {
        return (compareTo(val) > 0) ? this : val;
    }

    public  function min(val:BigInteger):BigInteger
    {
        return (compareTo(val) < 0) ? this : val;
    }

    public  function mod(m:BigInteger):BigInteger //ArithmeticException
    {
        if (m.sign <= 0)
        {
            throw "BigInteger: modulus is not positive"; //            throw new ArithmeticException("BigInteger: modulus is not positive");
        }

         var biggie:BigInteger= this.remainder(m);

        var res = (biggie.sign >= 0 ? biggie : biggie.add(m));
		//trace("mod-in:");
		//trace(m.magnitude);
		//trace("mod-biggie:");
		//trace(biggie.magnitude);
		//trace("mod-out:");
		//trace(res.magnitude);
		return res;
    }

    public  function modInverse(m:BigInteger):BigInteger //ArithmeticException
    {
        if (m.sign < 1)
        {
            throw "Modulus must be positive"; //            throw new ArithmeticException("Modulus must be positive");
        }

        if (m.quickPow2Check())
        {
			//trace("modInversePow2");
            return modInversePow2(m);
        }

         var d:BigInteger = this.remainder(m);
		 //trace("remainder:");
		 //trace(d.magnitude);
         var x:BigInteger= new BigInteger();
         var gcd:BigInteger = BigInteger.extEuclid(d, m, x, null);
        //trace("x(out):");
        //trace(x.magnitude);
        //trace("gcd:");
        //trace(gcd.magnitude);
		 

        if (!gcd.equals(BigInteger.ONE))
        {
            throw "Numbers not relatively prime."; //            throw new ArithmeticException("Numbers not relatively prime.");
        }

        if (x.compareTo(BigInteger.ZERO) < 0)
        {
			//trace("modInverse: negative.. doing add");
            x = x.add(m);
            //trace("after add:");
            //trace(x.magnitude);
			
        }

        return x;
    }

    private  function modInversePow2(m:BigInteger):BigInteger
    {
//        assert m.signum() > 0;
//        assert m.bitCount() == 1;

        if (!testBit(0))
        {
            throw "Numbers not relatively prime."; //            throw new ArithmeticException("Numbers not relatively prime.");
        }

         var pow:Int = m.bitLength() - 1;
		 
		 //trace("pow=" + Std.string(pow));

        if (pow <= 64)
        {
             var inv:Int64= modInverse64(longValue());
		 //trace("longValue()=" + Std.string(longValue()));
		 //trace("inv=" + Std.string(inv));
            if (pow < 64)
            {
				inv = Int64.and(inv, Int64.sub(m.longValue() , Int64.ofInt(1)));    
            }
            return BigInteger.valueOf(inv);
        }

         var d:BigInteger= this.remainder(m);
         var x:BigInteger= d;
         var bitsCorrect:Int= 3;

        while (bitsCorrect < pow)
        {
             var t:BigInteger= x.multiply(d).remainder(m);
            x = x.multiply(TWO.subtract(t)).remainder(m);
            bitsCorrect <<= 1;
        }

        if (x.sign < 0)
        {
            x = x.add(m);
        }

        return x;
    }

    private static  function modInverse32(d:Int):Int
    {
        // Newton-Raphson division (roughly)
         var x:Int = d;        // d.x == 1 mod 2**3
		 //trace(x);
        x = mul32(x, 2 - mul32(d , x));   // d.x == 1 mod 2**6
		 //trace(x);
        x = mul32(x, 2 - mul32(d , x));   // d.x == 1 mod 2**12
		 //trace(x);
        x = mul32(x, 2 - mul32(d , x));   // d.x == 1 mod 2**24
		 //trace(x);
        x = mul32(x, 2 - mul32(d , x));   // d.x == 1 mod 2**48
		 //trace(x);
//        assert d * x == 1;
        return  x;
    }

    private static  function modInverse64(d:Int64):Int64
    {
        // Newton-Raphson division (roughly)
         var x:Int64 = d;       // d.x == 1 mod 2**3
		 
        x = Int64.mul(x,Int64.sub( Int64.ofInt(2), Int64.mul(d, x)));   // d.x == 1 mod 2**6    
        x = Int64.mul(x,Int64.sub( Int64.ofInt(2), Int64.mul(d, x)));   // d.x == 1 mod 2**12    
        x = Int64.mul(x,Int64.sub( Int64.ofInt(2), Int64.mul(d, x)));   // d.x == 1 mod 2**24    
        x = Int64.mul(x,Int64.sub( Int64.ofInt(2), Int64.mul(d, x)));   // d.x == 1 mod 2**48    
        x = Int64.mul(x,Int64.sub( Int64.ofInt(2), Int64.mul(d, x)));   // d.x == 1 mod 2**96    
//        assert d * x == 1L;
        return  x;
    }

    /**
     * Calculate the numbers u1, u2, and u3 such that:
     *
     * u1 * a + u2 * b = u3
     *
     * where u3 is the greatest common divider of a and b.
     * a and b using the extended Euclid algorithm (refer p. 323
     * of The Art of Computer Programming vol 2, 2nd ed).
     * This also seems to have the side effect of calculating
     * some form of multiplicative inverse.
     *
     * @param a    First number to calculate gcd for
     * @param b    Second number to calculate gcd for
     * @param u1Out      the return object for the u1 value
     * @param u2Out      the return object for the u2 value
     * @return     The greatest common divisor of a and b
     */
    private static function extEuclid(a:BigInteger, b:BigInteger, u1Out:BigInteger ,
            u2Out:BigInteger ) : BigInteger
    {
		//trace("extEuclid");
		
         var u1:BigInteger= BigInteger.ONE;
         var u3:BigInteger= a;
         var v1:BigInteger= BigInteger.ZERO;
         var v3:BigInteger= b;

		// var traceit = false;
		 
        while (v3.sign > 0)
        {
            var q:Array<BigInteger> = u3.divideAndRemainder(v3);
			
            //trace("q[0] and q[1]");
            //trace(q[0].magnitude);
            //trace(q[1].magnitude);
			

			/*if (traceit) {
				trace(u1.magnitude);
                                trace("subtract");
				trace(v1.multiply(q[0]).magnitude);
				traceit = false;
				trace("subtracted to:");
				trace(u1.subtract(v1.multiply(q[0])).magnitude);

			}*/
			
             var tn:BigInteger = u1.subtract(v1.multiply(q[0]));
			 //trace(tn.magnitude);
			 /*if (tn.magnitude[0] == 1587326573) {
				 traceit = true;
			 }*/
            u1 = v1;
            v1 = tn;

            u3 = v3;
            v3 = q[1];
        }

        if (u1Out != null)
        {
			//trace("u1Out != null");
            u1Out.sign = u1.sign;
            u1Out.magnitude = u1.magnitude;
        }

        if (u2Out != null)
        {
			trace("u2Out != null");
             var res:BigInteger= u3.subtract(u1.multiply(a)).divide(b);
            u2Out.sign = res.sign;
            u2Out.magnitude = res.magnitude;
        }

        return u3;
    }

    /**
     * zero out the array x
     */
    private static function zero(x:Array<Int>) : Void
    {
        //for ( var i:Int= 0; i != x.length; i++)
		for (i in 0...x.length)
        {
            x[i] = 0;
        }
    }

    public  function modPow(e:BigInteger, m:BigInteger):BigInteger
    {
        if (m.sign < 1)
        {
            throw "Modulus must be positive"; //            throw new ArithmeticException("Modulus must be positive");
        }

        if (m.equals(ONE))
        {
            return ZERO;
        }

        if (e.sign == 0)
        {
            return ONE;
        }

        if (sign == 0)
        {
            return ZERO;
        }

         var negExp:Bool= e.sign < 0;
        if (negExp)
        {
            e = e.negate();
        }

         var result:BigInteger = this.mod(m);
        //trace("this.mod(m)");
        //trace(result.magnitude);
		 
        if (!e.equals(ONE))
        {
            if ((m.magnitude[m.magnitude.length - 1] & 1) == 0)
            {
                result = modPowBarrett(result, e, m);
            }
            else
            {
                result = modPowMonty(result, e, m, true);
                //trace("modPowMonty(result, e, m, true)");
                //trace(result.magnitude);
				
            }
        }

        if (negExp)
        {
            result = result.modInverse(m);
        }

        return result;
    }

    private static  function modPowBarrett(b:BigInteger, e:BigInteger, m:BigInteger):BigInteger
    {
        trace("BARRET - e.magnitude:");
        trace(e.magnitude);
        trace("b.magnitude:");
        trace(b.magnitude);
        trace("m.magnitude:");
        trace(m.magnitude);		
		
         var k:Int= m.magnitude.length;
         var mr:BigInteger= ONE.shiftLeft((k + 1) << 5);
         var yu:BigInteger= ONE.shiftLeft(k << 6).divide(m);

        // Sliding window from MSW to LSW
         var extraBits:Int= 0, expLength = e.bitLength();
        while (expLength > EXP_WINDOW_THRESHOLDS[extraBits])
        {
            ++extraBits;
        }

         var numPowers:Int= 1 << extraBits;
        var oddPowers : Array<BigInteger> = bigIntArray(numPowers);
        oddPowers[0] = b;

         var b2:BigInteger= reduceBarrett(b.square(), m, mr, yu);

        //for ( var i:Int= 1; i < numPowers; ++i)
		for (i in 1...numPowers)
        {
            oddPowers[i] = reduceBarrett(oddPowers[i - 1].multiply(b2), m, mr, yu);
        }

         var windowList:Array<Int>= getWindowList(e.magnitude, extraBits);
//      assert windowList.size() > 0;

         var window:Int= windowList[0];
         var mult:Int= window & 0xFF, lastZeroes = window >>> 8;

         var y:BigInteger;
        if (mult == 1)
        {
            y = b2;
            --lastZeroes;
        }
        else
        {
            y = oddPowers[mult >>> 1];
        }

         var windowPos:Int= 1;
        while ((window = windowList[windowPos++]) != -1)
        {
            mult = window & 0xFF;

             var bits:Int= lastZeroes + bitLengths[mult];
            //for ( var j:Int= 0; j < bits; ++j)
			for (j in 0...bits)
            {
                y = reduceBarrett(y.square(), m, mr, yu);
            }

            y = reduceBarrett(y.multiply(oddPowers[mult >>> 1]), m, mr, yu);

            lastZeroes = window >>> 8;
        }

        //for ( var i:Int= 0; i < lastZeroes; ++i)
		for (i in 0...lastZeroes)
        {
            y = reduceBarrett(y.square(), m, mr, yu);
        }

		trace("Barret Result");
		trace(y.magnitude);
		throw "YEA";
        return y;
    }

    private static  function reduceBarrett(x:BigInteger, m:BigInteger, mr:BigInteger, yu:BigInteger):BigInteger
    {
         var xLen:Int= x.bitLength(), mLen = m.bitLength();
        if (xLen < mLen)
        {
            return x;
        }

        if (xLen - mLen > 1)
        {
             var k:Int= m.magnitude.length;

             var q1:BigInteger= x.divideWords(k - 1);
             var q2:BigInteger= q1.multiply(yu); // TODO Only need partial multiplication here
             var q3:BigInteger= q2.divideWords(k + 1);

             var r1:BigInteger= x.remainderWords(k + 1);
             var r2:BigInteger= q3.multiply(m); // TODO Only need partial multiplication here
             var r3:BigInteger= r2.remainderWords(k + 1);

            x = r1.subtract(r3);
            if (x.sign < 0)
            {
                x = x.add(mr);
            }
        }

        while (x.compareTo(m) >= 0)
        {
            x = x.subtract(m);
        }

        return x;
    }

    private static  function modPowMonty(b:BigInteger, e:BigInteger, m:BigInteger, convert:Bool):BigInteger
    {
        /*trace("e.magnitude:");
        trace(e.magnitude);
        trace("b.magnitude:");
        trace(b.magnitude);
        trace("m.magnitude:");
        trace(m.magnitude);*/
		
         var n:Int= m.magnitude.length;
         var powR:Int= 32 * n;
         var smallMontyModulus:Bool= m.bitLength() + 2 <= powR;
         var mDash:Int= m.getMQuote();

		 //trace("mDash: " + Std.int(mDash));
		 
        // tmp = this * R mod m
        if (convert)
        {
            b = b.shiftLeft(powR).remainder(m);
        }

         var yAccum:Array<Int>= intArray(n + 1);

         var zVal:Array<Int>= b.magnitude;
//        assert zVal.length <= n;
        if (zVal.length < n)
        {
             var tmp:Array<Int> = intArray(n); // intArray(n];
            arraycopy(zVal, 0, tmp, n - zVal.length, zVal.length);
            zVal = tmp;  
        }

        // Sliding window from MSW to LSW

         var extraBits:Int= 0;

        // Filter the common case of small RSA exponents with few bits set
        if (e.magnitude.length > 1 || e.bitCount() > 2)
        {
             var expLength:Int= e.bitLength();
            while (expLength > EXP_WINDOW_THRESHOLDS[extraBits])
            {
                ++extraBits;
            }
        }

         var numPowers:Int= 1 << extraBits;
         var oddPowers:Array<Array<Int>> = new Array<Array<Int>>();//intArray(numPowers][];
        oddPowers[0] = zVal;

         var zSquared:Array<Int>= Arrays_clone(zVal);
        squareMonty(yAccum, zSquared, m.magnitude, mDash, smallMontyModulus);

        //for ( var i:Int= 1; i < numPowers; ++i)
		for (i in 1...numPowers)
        {
            oddPowers[i] = Arrays_clone(oddPowers[i - 1]);
            multiplyMonty(yAccum, oddPowers[i], zSquared, m.magnitude, mDash, smallMontyModulus);
        }

         var windowList:Array<Int>= getWindowList(e.magnitude, extraBits);
//        assert windowList.size() > 0;

         var window:Int= windowList[0];
         var mult:Int= window & 0xFF, lastZeroes = window >>> 8;

         var yVal:Array<Int>;
        if (mult == 1)
        {
            yVal = zSquared;
            --lastZeroes;
        }
        else
        {
            yVal = Arrays_clone(oddPowers[mult >>> 1]);
        }

         var windowPos:Int = 1;
		 //trace(windowList);
		 //trace("len:" + Std.string(windowList.length));
		 /*var found = false;
		 for (nn in 0...windowList.length) {
			 if (windowList[nn] == -1) {
				 found = true;
				 trace("-1 at " + Std.string(nn));
			 }
		 }
		 if (!found) throw "NO -1";*/
        while ((window = windowList[windowPos++]) != -1)
        {
            mult = window & 0xFF;
//trace("windowPos=" + Std.string(windowPos));
             var bits:Int= lastZeroes + bitLengths[mult];
            //for ( var j:Int= 0; j < bits; ++j)
			for (j in 0...bits)
            {
                squareMonty(yAccum, yVal, m.magnitude, mDash, smallMontyModulus);
            }

            multiplyMonty(yAccum, yVal, oddPowers[mult >>> 1], m.magnitude, mDash, smallMontyModulus);

            lastZeroes = window >>> 8;
        }

        //for ( var i:Int= 0; i < lastZeroes; ++i)
		for (i in 0...lastZeroes)
        {
            squareMonty(yAccum, yVal, m.magnitude, mDash, smallMontyModulus);
        }

        if (convert)
        {
            // Return y * R^(-1) mod m
            reduceMonty(yVal, m.magnitude, mDash);
        }
        else if (smallMontyModulus && compareToArr(0, yVal, 0, m.magnitude) >= 0)
        {
            subtractArr(0, yVal, 0, m.magnitude);
        }

		//trace("yVal:");
        //trace(yVal);

		
        return BigInteger.fromSignumMag(1, yVal);
    }

    private static  function getWindowList(mag:Array<Int>, extraBits:Int):Array<Int>
    {
         var v:Int= mag[0];
//        assert v != 0;
         var leadingBits:Int= bitLen(v);

         var resultSize:Int= Math.floor((((mag.length - 1) << 5) + leadingBits) / (1 + extraBits)) + 2;
         var result:Array<Int> = intArray(resultSize);
		 //trace(mag);
		 //throw result.length;
         var resultPos:Int= 0;

         var bitPos:Int= 33 - leadingBits;
        v <<= bitPos;

         var mult:Int= 1, multLimit = 1 << extraBits;
         var zeroes:Int= 0;

         var i:Int= 0;
        //for (; ; )
		while(true)
        {
            //for (; bitPos < 32; ++bitPos)
			while (bitPos < 32)
            {
                if (mult < multLimit)
                {
                    mult = (mult << 1) | (v >>> 31);
                }
                else if (v < 0)
                {
                    result[resultPos++] = createWindowEntry(mult, zeroes);
                    mult = 1;
                    zeroes = 0;
                }
                else
                {
                    ++zeroes;
                }

                v <<= 1;
				
				++bitPos; //HAXE
            }

			////trace("HEY");
			
            if (++i == mag.length)
            {
                result[resultPos++] = createWindowEntry(mult, zeroes);
                break;
            }

            v = mag[i];
            bitPos = 0;
        }

        result[resultPos] = -1;
        return result;
    }

    private static  function createWindowEntry(mult:Int, zeroes:Int):Int
    {
        while ((mult & 1) == 0)
        {
            mult >>>= 1;
            ++zeroes;
        }

        return mult | (zeroes << 8);
    }

    /**
     * return w with w = x * x - w is assumed to have enough space.
     */
    private static  function squareArr(w:Array<Int>, x:Array<Int>):Array<Int>
    {
        // Note: this method allows w to be only (2 * x.Length - 1) words if result will fit
//        if (w.length != 2 * x.length)
//        {
//            throw "no I don't think so..."; ////            throw new IllegalArgumentException("no I don't think so...");
//        }

		////trace("squareArr for " + Std.string(x));

         var c:Int64;

         var wBase:Int= w.length - 1;

        //for ( var i:Int= x.length - 1; i != 0; --i)
		var i = x.length - 1;
		while (i != 0)
        {
             var v:Int64= Int64.and(Int64.ofInt(x[i]), IMASK);    

            c = Int64.add(Int64.mul(v, v), (Int64.and(Int64.ofInt(w[wBase]), IMASK)));    
			////trace("C=" + Std.string(c));
            w[wBase] = Int64.toInt(c);
            c = Int64.ushr(c, 32);    

            //for ( var j:Int= i - 1; j >= 0; --j)
			var j = i - 1;
			while (j >= 0)
            {
                 var prod:Int64= Int64.mul(v, (Int64.and(Int64.ofInt(x[j]), IMASK)));    

                c = Int64.add(c, Int64.add((Int64.and(Int64.ofInt(w[--wBase]), IMASK)) , Int64.and((Int64.shl(prod, 1)) , IMASK)));    // c += (w[--wBase] & IMASK) + ((prod << 1) & IMASK);
                w[wBase] = Int64.toInt(c);
                c = Int64.add((Int64.ushr(c, 32)) , (Int64.ushr(prod, 31)));    
				--j; // HAXE
            }

            c = Int64.add(c, Int64.and(Int64.ofInt(w[--wBase]), IMASK));    
            w[wBase] = Int64.toInt(c);

            if (--wBase >= 0)
            {
                w[wBase] = Int64.toInt(Int64.shr(c, 32));    
            }
            wBase += i;
			--i; //HAXE
        }

        c = Int64.and(Int64.ofInt(x[0]), IMASK);    

        c = Int64.add(Int64.mul(c, c), (Int64.and(Int64.ofInt(w[wBase]), IMASK)));    
        w[wBase] = Int64.toInt(c);

        if (--wBase >= 0)
        {
            //w[wBase] += Int64.toInt(Int64.shr(c, 32)); // Int64.add(Int64.ofInt(w[wBase]), Int64.toInt(Int64.shr(c, 32)));    
			w[wBase] = w[wBase] + Int64.toInt(Int64.shr(c, 32));// | 0; // Int64.add(Int64.ofInt(w[wBase]), Int64.toInt(Int64.shr(c, 32)));    
        }

		//trace("squareArr result = " + Std.string(w));
		
        return w;
    }

	public static var mycnt = 0;

    /**
     * return x with x = y * z - x is assumed to have enough space.
     */
    private static  function multiplyArr(x:Array<Int>, y:Array<Int>, z:Array<Int>):Array<Int>
    {
		////trace("multiplyArr: OUT:" + Std.string(x));
		
         var i:Int= z.length;

        if (i < 1)
        {
            return x;
        }

         var xBase:Int= x.length - y.length;

        //for (;;)
		while (true)
        {
			//var s = "inMUL:";
			
             var a:Int64= Int64.and(Int64.ofInt(z[--i]), IMASK);    
             var val:Int64= Int64.ofInt(0);

            //for ( var j:Int= y.length - 1; j >= 0; j--)
			var j = y.length - 1;
			
			while (j >= 0)
            {
		////trace("multiplyArr: OUT:" + Std.string(x));
				var trackit = (mycnt == 1000 && j == 9 || Int64.toStr(val) == "550312129");
				////trace("J = " + Std.string(j));
				
				//val += a * (y[j] & IMASK) + (x[xBase + j] & IMASK);
				// NB:NB: In AUTOFIX, add and mull were switched to yield the wrong result:: !!!!
				//if (mycnt == 1001) {
				//	throw "PAUSE";
				//	//trace("val before add: " + Std.string(val));
				//}				
				
				//var and1 = Int64.and(Int64.ofInt(y[j]), IMASK);
				//var m1 = Int64.mul(a , and1);
				//var and2 = Int64.and(Int64.ofInt(x[xBase + j]), IMASK);
				
			
				
                //val = Int64.add(val, Int64.add(m1, and1));    
				
				var _a1 = Int64.and(Int64.ofInt(y[j]), IMASK);
				var _m = Int64.mul(a , _a1);
				var _a2 = Int64.and(Int64.ofInt(x[xBase + j]), IMASK);
				var v1 = Int64.add(_m, (_a2));
				if (trackit) {
					//trace("a: " + Std.string(a));
					//trace("a.hi: " + Std.string(Int64.getHigh(a)));
					//trace("a.lo: " + Std.string(Int64.getLow(a)));
					//trace("Int64.ofInt(y[j]): " + Std.string(Int64.ofInt(y[j])));
					//trace("_a1: " + Std.string(_a1));
					//trace("_a1.hi: " + Std.string(Int64.getHigh(_a1)));
					//trace("_a1.lo: " + Std.string(Int64.getLow(_a1)));
					//trace("_m (a * _a1): " + Std.string(_m));
					//trace("_a2: " + Std.string(_a2));
					//trace("v1: " + Std.string(v1));
					//trace("x[xBase + j]: " + Std.string(x[xBase + j]));
					//trace("Int64.ofInt(x[xBase + j]): " + Std.string(Int64.ofInt(x[xBase + j])));
				}		
				
				if (trackit) {
					//trace("beforeadd:");
					//trace(Std.string(mycnt) + ":" + Std.string(val));
					//trace(Std.string(mycnt) + ":" + Std.string(Int64.toInt(val)));
				}
				val = Int64.add(val, v1);
				   


                //////trace("xBase + j"+ Std.string(xBase + j));

				/*if (trackit) {
					//trace(j);
					//trace(Std.string(mycnt) + ":" + Std.string(val));
					//trace(Std.string(mycnt) + ":" + Std.string(Int64.toInt(val)));
					throw "PAUS";
				}*/
				
                x[xBase + j] = Int64.toInt(val);

                //val >>>= 32;
				if (trackit) {
					//trace("val before ushr: " + Std.string(val));
				}				
				
				val = Int64.ushr(val, 32);
				
								if (trackit) {
					//trace("val after before ushr: " + Std.string(val));
				}	
				
				//s+= Std.string(val) + ",";
				
				if (mycnt >= 1000) {
					//trace("VAL=" + Std.string(val));
				}
				
				j--; //HAXE
            }
			mycnt += 1;
			////trace(Std.string(mycnt) + ":" + s);
			
            if (mycnt == 119) {
                ////trace("119 - x is: " + Std.string(x));
            }			
			
			//if (mycnt >= 120) throw "UGH";
			//throw "UGH";
            --xBase;

			if (Int64.toInt(val) > 0) {
				//trace(Std.string(mycnt) + ":" + Std.string(Int64.toInt(val)));
			}
			
            if (i < 1)
            {
                if (xBase >= 0)
                {
                    x[xBase] = Int64.toInt(val);
					//trace(Std.string(mycnt) + "-:" + Std.string(Int64.toInt(val)));
                }
                break;
            }

            x[xBase] = Int64.toInt(val);
			//trace(Std.string(mycnt) + "--:" + Std.string(Int64.toInt(val)));

            if (mycnt == 117) {
                ////trace("117");
				////trace(x);
            }			
			
		}

        return x;
    }

    /**
     * Calculate mQuote = -m^(-1) mod b with b = 2^32 (32 = word size)
     */
    private  function getMQuote():Int
    {
        if (mQuote != 0)
        {
            return mQuote; // already calculated
        }

//        assert this.sign > 0;

         var d:Int= -magnitude[magnitude.length - 1];

//        assert (d & 1) != 0;

		mQuote = modInverse32(d);
		//trace("modInverse32(" + Std.string(d) + ")=" + Std.string(mQuote));
		return mQuote;

        //return mQuote = modInverse32(d);
    }

    private static function reduceMonty(x:Array<Int>, m:Array<Int>, mDash:Int) : Void // mDash = -m^(-1) mod b
    {
        // NOTE: Not a general purpose reduction (which would allow x up to twice the bitlength of m)
//        assert x.length == m.length;

         var n:Int= m.length;

        //for ( var i:Int= n - 1; i >= 0; --i)
		var i = n - 1;
		while (i >= 0)
        {
             var x0:Int= x[n - 1];

             var t:Int64=  Int64.and(Int64.ofInt(mul32(x0 , mDash)) , IMASK);//(x0 * mDash) & IMASK;

             var carry:Int64= Int64.add(Int64.mul(t, (Int64.and(Int64.ofInt(m[n - 1]), IMASK))) , (Int64.and(Int64.ofInt(x0), IMASK)));    
//          assert (int)carry == 0;
            carry = Int64.ushr(carry, 32);    

            //for ( var j:Int= n - 2; j >= 0; --j)
			var j = n - 2;
			while (j >= 0)
            {
                carry = Int64.add(carry, Int64.add(Int64.mul(t, (Int64.and(Int64.ofInt(m[j]), IMASK))) , (Int64.and(Int64.ofInt(x[j]), IMASK))));    
                x[j + 1] = Int64.toInt(carry);
                carry = Int64.ushr(carry, 32);    
				
				--j; // HAXE
            }

            x[0] = Int64.toInt(carry);
//            assert carry >>> 32 == 0;
			--i; // HAXE
        }

        if (compareToArr(0, x, 0, m) >= 0)
        {
            subtractArr(0, x, 0, m);
        }
    }
	
	// HAXE HELPER
	static inline function i64(i : Int) {
		return Int64.make(0, i);
	}

    /**
     * Montgomery multiplication: a = x * y * R^(-1) mod m
     * <br>
     * Based algorithm 14.36 of Handbook of Applied Cryptography.
     * <br>
     * <li> m, x, y should have length n </li>
     * <li> a should have length (n + 1) </li>
     * <li> b = 2^32, R = b^n </li>
     * <br>
     * The result is put in x
     * <br>
     * NOTE: the indices of x, y, m, a different in HAC and in Java
     */
    private static function multiplyMonty(a:Array<Int>, x:Array<Int>, y:Array<Int>, m:Array<Int>, mDash:Int, smallMontyModulus:Bool) : Void
        // mDash = -m^(-1) mod b
    {
         var n:Int= m.length;
         var y_0:Int64= Int64.and(Int64.ofInt(y[n - 1]), IMASK);    

        // 1. a = 0 (Notation: a = (a_{n} a_{n-1} ... a_{0})_{b} )
        //for ( var i:Int= 0; i <= n; i++)
		for (i in 0...n+1)
        {
            a[i] = 0;
        }

        // 2. for i from 0 to (n - 1) do the following:
        //for ( var i:Int= n; i > 0; i--)
		var i = n;
		//	trace("I starts at: " + Std.string(i));
		while (i > 0)
        {
             var a0:Int64= Int64.and(Int64.ofInt(a[n]), IMASK);    
             var x_i:Int64= Int64.and(Int64.ofInt(x[i - 1]), IMASK);    

             var prod1:Int64= Int64.mul(x_i, y_0);    
             var carry:Int64= Int64.add((Int64.and(prod1, IMASK)), a0);    

            // 2.1 u = ((a[0] + (x[i] * y[0]) * mDash) mod b
             var u:Int64= Int64.and(Int64.ofInt(mul32(Int64.toInt(carry) , mDash)),IMASK);        // Int64.toInt(carry);

            // 2.2 a = (a + x_i * y + u * m) / b
             var prod2:Int64= Int64.mul(u, Int64.and(Int64.ofInt(m[n - 1]), IMASK));
            carry = Int64.add(carry, Int64.and(prod2, IMASK));
//            assert (int)carry == 0;
            carry = Int64.add((Int64.ushr(carry, 32)) ,
				Int64.add((Int64.ushr(prod1, 32)), (Int64.ushr(prod2, 32))));    

            //for ( var j:Int= n - 2; j >= 0; j--)
			var j = n - 2;
			while (j >= 0) // TODO : Look into this eternal loop
            {
                prod1 = Int64.mul(x_i, (Int64.and(Int64.ofInt(y[j]), IMASK)));    
                prod2 = Int64.mul(u, (Int64.and(Int64.ofInt(m[j]), IMASK)));    

                carry = Int64.add(carry, Int64.add((Int64.and(prod1, IMASK)) , Int64.add((Int64.and(prod2, IMASK)), (Int64.and(Int64.ofInt(a[j + 1]), IMASK)))));    
                a[j + 2] = Int64.toInt(carry);
                carry = Int64.add((Int64.ushr(carry, 32)) ,
						Int64.add((Int64.ushr(prod1, 32)), (Int64.ushr(prod2, 32))));    
				
				j--; // HAXE
            }

            carry = Int64.add(carry, (Int64.and(Int64.ofInt(a[0]), IMASK)));    
            a[1] = Int64.toInt(carry);
            a[0] = Int64.toInt(Int64.ushr(carry,32));
			
			i--; // HAXE
        }

        // 3. if x >= m the x = x - m
        if (!smallMontyModulus && compareToArr(0, a, 0, m) >= 0)
        {
            subtractArr(0, a, 0, m);
        }

        // put the result in x
        arraycopy(a, 1, x, 0, n);
    }

    private static function squareMonty(a:Array<Int>, x:Array<Int>, m:Array<Int>, mDash:Int, smallMontyModulus:Bool) : Void // mDash = -m^(-1) mod b
    {
         var n:Int= m.length;

         var x0:Int64= Int64.and(Int64.ofInt(x[n - 1]), IMASK);    

        {
             var carry:Int64= Int64.mul(x0, x0);    
             var u:Int64= Int64.and(Int64.ofInt(mul32(Int64.toInt(carry) , mDash)) , IMASK);

            var prod1:Int64 = Int64.mul(u, (Int64.and(Int64.ofInt(m[n - 1]), IMASK)));    
			var prod2 = prod1;
            carry = Int64.add(carry, (Int64.and(prod2, IMASK)));    
//            assert (int)carry == 0;
            carry = Int64.add((Int64.ushr(carry, 32)), (Int64.ushr(prod2, 32)));    
//            assert carry <= (IMASK << 1);

            //for ( var j:Int= n - 2; j >= 0; --j)
			var j = n - 2;
			while (j >= 0)
            {
                prod1 = Int64.mul(x0, (Int64.and(Int64.ofInt(x[j]), IMASK)));    
                prod2 = Int64.mul(u, (Int64.and(Int64.ofInt(m[j]), IMASK)));    

                carry = Int64.add(carry, Int64.add((Int64.and((Int64.shl(prod1, 1)), IMASK)) , (Int64.and(prod2, IMASK))));    
                a[j + 2] = Int64.toInt(carry);
                carry = Int64.add((Int64.ushr(carry, 32)) , Int64.add((Int64.ushr(prod1, 31)), (Int64.ushr(prod2, 32))));    
				
				--j; // HAXE
            }

            a[1] = Int64.toInt(carry);
            a[0] = Int64.toInt(Int64.ushr(carry, 32));    
        }

        //for ( var i:Int= n - 2; i >= 0; --i)
		var i = n - 2;
		while (i >= 0)
        {
             var a0:Int= a[n];
             var u:Int64= Int64.and(Int64.ofInt(mul32(a0 , mDash)) , IMASK);

             var carry:Int64= Int64.add(Int64.mul(u, (Int64.and(Int64.ofInt(m[n - 1]), IMASK))) , (Int64.and(Int64.ofInt(a0), IMASK)));    
//            assert (int)carry == 0;
            carry = Int64.ushr(carry, 32);    

            //for ( var j:Int= n - 2; j > i; --j)
			var j = n - 2;
			while (j > i)
            {
                carry = Int64.add(carry, Int64.add(Int64.mul(u, (Int64.and(Int64.ofInt(m[j]), IMASK))) , (Int64.and(Int64.ofInt(a[j + 1]), IMASK))));    
                a[j + 2] = Int64.toInt(carry);
                carry = Int64.ushr(carry, 32);    
				
				--j; // HAXE
            }

             var xi:Int64= Int64.and(Int64.ofInt(x[i]), IMASK);    

			 // TODO : hmmm???
            {
                 var prod1:Int64= Int64.mul(xi, xi);    
                 var prod2:Int64= Int64.mul(u, (Int64.and(Int64.ofInt(m[i]), IMASK)));    

                carry = Int64.add(carry, Int64.add((Int64.and(prod1, IMASK)) , Int64.add((Int64.and(prod2, IMASK)), (Int64.and(Int64.ofInt(a[i + 1]), IMASK)))));    
                a[i + 2] = Int64.toInt(carry);
                carry = Int64.add((Int64.ushr(carry, 32)) , Int64.add((Int64.ushr(prod1, 32)), (Int64.ushr(prod2, 32))));    
            }

            //for ( var j:Int= i - 1; j >= 0; --j)
			j = i - 1;
			//			trace("J starts at: " + Std.string(j));

			while (j >= 0)
            {
                 var prod1:Int64= Int64.mul(xi, (Int64.and(Int64.ofInt(x[j]), IMASK)));    
                 var prod2:Int64= Int64.mul(u, (Int64.and(Int64.ofInt(m[j]), IMASK)));    

                carry = Int64.add(carry, Int64.add((Int64.and((Int64.shl(prod1, 1)), IMASK)) , Int64.add((Int64.and(prod2, IMASK)), (Int64.and(Int64.ofInt(a[j + 1]), IMASK)))));    
                a[j + 2] = Int64.toInt(carry);
                carry = Int64.add((Int64.ushr(carry, 32)) , Int64.add((Int64.ushr(prod1, 31)), (Int64.ushr(prod2, 32))));    
				
				--j; //HAXE
            }

            carry = Int64.add(carry, (Int64.and(Int64.ofInt(a[0]), IMASK)));    
            a[1] = Int64.toInt(carry);
            a[0] = Int64.toInt(Int64.ushr(carry, 32));    
			
			--i; // HAXE
        }

        if (!smallMontyModulus && compareToArr(0, a, 0, m) >= 0)
        {
            subtractArr(0, a, 0, m);
        }

        arraycopy(a, 1, x, 0, n);
    }

    public  function multiply(val:BigInteger):BigInteger
    {
		//////trace("mag:" + Std.string(magnitude));
		////trace("MULTIPLY with val.mag:" + Std.string(val.magnitude));		
		
        if (val == this) {
			//trace("val is THIS");
            return square();
		}

        if ((sign & val.sign) == 0) {
			//trace("ZERO");
            return ZERO;
		}

        if (val.quickPow2Check()) // val is power of two
        {
			//trace("VAL is power of 2");
             var result:BigInteger= this.shiftLeft(val.abs().bitLength() - 1);
            return val.sign > 0 ? result : result.negate();
        }

        if (this.quickPow2Check()) // this is power of two
        {
			//trace("this is power of 2");
             var result:BigInteger= val.shiftLeft(this.abs().bitLength() - 1);
            return this.sign > 0 ? result : result.negate();
        }

		////trace("mag:" + Std.string(magnitude));
		////trace("val.mag:" + Std.string(val.magnitude));
		
         var resLength:Int = magnitude.length + val.magnitude.length;
		 //////trace("resLength="+ Std.string(resLength));
         var res:Array<Int>= intArray(resLength);

        multiplyArr(res, this.magnitude, val.magnitude);

         var resSign:Int= sign ^ val.sign ^ 1;
        return BigInteger.fromSignumMag(resSign, res);
    }

    public  function square():BigInteger
    {
        if (sign == 0)
        {
			//trace("square-return ZERO");
            return ZERO;
        }
        if (this.quickPow2Check())
        {
            return shiftLeft(abs().bitLength() - 1);
        }
         var resLength:Int= magnitude.length << 1;
        if ((magnitude[0] >>> 16) == 0)
        {
            --resLength;
        }
         var res:Array<Int>= intArray(resLength);
        squareArr(res, magnitude);
        return BigInteger.fromSignumMag(1, res);
    }

    public  function negate():BigInteger
    {
        if (sign == 0)
        {
            return this;
        }

		return BigInteger.fromSignumMag(-sign, magnitude);
        //return new BigInteger(-sign, magnitude);
    }

    public  function not():BigInteger
    {
        return add(ONE).negate();
    }

    public  function pow(exp:Int):BigInteger//throws:BigInteger ArithmeticException
    {
        if (exp <= 0)
        {
            if (exp < 0)
                throw "Negative exponent"; //                throw new ArithmeticException("Negative exponent");

            return ONE;
        }

        if (sign == 0)
        {
            return this;
        }

        if (quickPow2Check())
        {
             var powOf2:Int64= Int64.mul(Int64.ofInt(exp) , Int64.ofInt((bitLength() - 1)));
            if (gt(powOf2 , IntegerMAX_VALUE))
            {
                throw "Result too large"; //                throw new ArithmeticException("Result too large");
            }
            return ONE.shiftLeft(Int64.toInt(powOf2)); 
        }

         var y:BigInteger= BigInteger.ONE, z = this;

        while (exp != 0)
        {
            if ((exp & 0x1) == 1)
            {
                y = y.multiply(z);
            }
            exp >>= 1;
            if (exp != 0)
            {
                z = z.multiply(z);
            }
        }

        return y;
    }

    public static function probablePrime(
        bitLength:Int,
        random:Random) : BigInteger
    {
        return BigInteger.fromLengthCertaintyRandom(bitLength, 100, random);
    }

    private  function remainderInt(m:Int):Int
    {
         var acc:Int64= Int64.ofInt(0);
        //for ( var pos:Int= 0; pos < magnitude.length; ++pos)
		for (pos in 0...magnitude.length)
        {
            acc = Int64.mod(Int64.or(Int64.shl(acc, 32) , Int64.and(Int64.ofInt(magnitude[pos]) , 
			Int64.make(0,0xffffffff))) , Int64.ofInt(m));    
        }

        return Int64.toInt(acc); // Int64.toInt(acc);
    }
    
    /**
     * return x = x % y - done in place (y value preserved)
     */
    public /*private*/ static  function remainderArr(x:Array<Int>, y:Array<Int>):Array<Int>
    {
		//trace("remainderArrIN");
		//trace(x);
         var xStart:Int= 0;
        while (xStart < x.length && x[xStart] == 0)
        {
            ++xStart;
        }

         var yStart:Int= 0;
        while (yStart < y.length && y[yStart] == 0)
        {
            ++yStart;
        }

         var xyCmp:Int= compareNoLeadingZeroes(xStart, x, yStart, y);

        if (xyCmp > 0)
        {
             var yBitLength:Int= calcBitLength(1, yStart, y);
             var xBitLength:Int= calcBitLength(1, xStart, x);
             var shift:Int= xBitLength - yBitLength;

             var c:Array<Int>;
             var cStart:Int= 0;
             var cBitLength:Int= yBitLength;
            if (shift > 0)
            {
                c = shiftLeftArr(y, shift);
                cBitLength += shift;
            }
            else
            {
                 var len:Int= y.length - yStart; 
                c = intArray(len);
                arraycopy(y, yStart, c, 0, len);
            }

            //for (;;)
			while (true)
            {
                if (cBitLength < xBitLength
                    || compareNoLeadingZeroes(xStart, x, cStart, c) >= 0)
                {
                    subtractArr(xStart, x, cStart, c);

                    while (x[xStart] == 0)
                    {
                        if (++xStart == x.length)
                        {
		trace("remainderArrEARLY");
		trace(x);
		trace(y);							
							
                            return x;
                        }
                    }

                    xyCmp = compareNoLeadingZeroes(xStart, x, yStart, y);

                    if (xyCmp <= 0)
                    {
                        break;
                    }

                    //xBitLength = bitLength(xStart, x);
                    xBitLength = 32 * (x.length - xStart - 1) + bitLen(x[xStart]);
                }

                shift = cBitLength - xBitLength;

                if (shift < 2)
                {
                    shiftRightOneInPlace(cStart, c);
                    --cBitLength;
                }
                else
                {
                    shiftRightInPlace(cStart, c, shift);
                    cBitLength -= shift;
                }

//              cStart = c.length - ((cBitLength + 31) / 32);
                while (c[cStart] == 0)
                {
                    ++cStart;
                }
            }
        }

        if (xyCmp == 0)
        {
            //for ( var i:Int= xStart; i < x.length; ++i)
			for (i in xStart...x.length)
            {
                x[i] = 0;
            }
        }

		//trace("remainderArr");
		//trace(x);
		//trace(y);
		
        return x;
    }

    public  function remainder(n:BigInteger):BigInteger//throws:BigInteger ArithmeticException
    {
        if (n.sign == 0)
        {
            throw "BigInteger: Divide by zero"; //            throw new ArithmeticException("BigInteger: Divide by zero");
        }

        if (sign == 0)
        {
            return BigInteger.ZERO;
        }

        // For small values, use fast remainder method
        if (n.magnitude.length == 1)
        {
             var val:Int= n.magnitude[0];

            if (val > 0)
            {
                if (val == 1)
                    return ZERO;

                 var rem:Int= remainderInt(val);

                return rem == 0
                    ?   ZERO
                    :   BigInteger.fromSignumMag(sign, [ rem ]);
            }
        }

        if (compareToArr(0, magnitude, 0, n.magnitude) < 0)
            return this;

         var res:Array<Int>;
        if (n.quickPow2Check())  // n is power of two
        {
            // TODO Move before small values branch above?
            res = lastNBits(n.abs().bitLength() - 1);
        }
        else
        {
            res = intArray(this.magnitude.length);
            arraycopy(this.magnitude, 0, res, 0, res.length);
            res = remainderArr(res, n.magnitude);
        }

        return BigInteger.fromSignumMag(sign, res);
    }

    private function lastNBits(
        n:Int) :Array<Int>
    {
        if (n < 1)
        {
            return ZERO_MAGNITUDE();
        }

         var numWords:Int= Math.floor((n + 31) / 32);
        numWords = Math.floor(Math.min(numWords, this.magnitude.length));
         var result:Array<Int>= intArray(numWords);

        arraycopy(this.magnitude, this.magnitude.length - numWords, result, 0, numWords);

         var excessBits:Int= (numWords << 5) - n;
        if (excessBits > 0)
        {
            result[0] &= (-1 >>> excessBits);
        }

        return result;
    }

    private  function divideWords(w:Int):BigInteger
    {
//        assert w >= 0;
         var n:Int= magnitude.length;
        if (w >= n)
        {
            return ZERO;
        }
         var mag:Array<Int>= intArray(n - w);
        arraycopy(magnitude, 0, mag, 0, n - w);
        return BigInteger.fromSignumMag(sign, mag);
    }

    private  function remainderWords(w:Int):BigInteger
    {
//        assert w >= 0;
         var n:Int= magnitude.length;
        if (w >= n)
        {
            return this;
        }
         var mag:Array<Int>= intArray(w);
        arraycopy(magnitude, n - w, mag, 0, w);
        return BigInteger.fromSignumMag(sign, mag);
    }

    /**
     * do a left shift - this returns a new array.
     */
    private static  function shiftLeftArr(mag:Array<Int>, n:Int):Array<Int>
    {
		////trace(Std.string(mycnt) + ":SHIFTLEFT(" + Std.string(n) + ")" + Std.string(mag));
		
         var nInts:Int= n >>> 5;
         var nBits:Int= n & 0x1f;
         var magLen:Int= mag.length;
        var newMag:Array<Int> = null;

        if (nBits == 0)
        {
            newMag = intArray(magLen + nInts);
            arraycopy(mag, 0, newMag, 0, magLen);
        }
        else
        {
             var i:Int= 0;
             var nBits2:Int= 32 - nBits;
             var highBits:Int= mag[0] >>> nBits2;

            if (highBits != 0)
            {

                newMag = intArray(magLen + nInts + 1);
				if (mycnt == 117) {
					////trace("MAGLEN=" + Std.string(magLen));
					////trace("nInts=" + Std.string(nInts));
					////trace("newMag.length=" + Std.string(newMag.length));
				}				
                newMag[i++] = highBits;
				////trace("newMag.length=" + Std.string(newMag.length));
            }
            else
            {
                newMag = intArray(magLen + nInts);
            }

             var m:Int= mag[0];
            //for ( var j:Int= 0; j < magLen - 1; j++)
			for (j in 0...magLen-1)
            {
                 var next:Int= mag[j + 1];

                newMag[i++] = (m << nBits) | (next >>> nBits2);
                m = next;
            }

            newMag[i] = mag[magLen - 1] << nBits;
        }

		//if (mycnt == 118) {
		//	throw "SHIFTLEFT: " + Std.string( newMag.length);
		//}
		////trace("SHIFTLEFT-RES=" + Std.string(newMag));
		
        return newMag;
    }

    private static  function shiftLeftOneInPlace(x:Array<Int>, carry:Int):Int
    {
//        assert carry == 0 || carry == 1;
         var pos:Int= x.length;
        while (--pos >= 0)
        {
             var val:Int= x[pos];
            x[pos] = (val << 1) | carry;
            carry = val >>> 31;
        }
        return carry;
    }

    public  function shiftLeft(n:Int):BigInteger
    {
        if (sign == 0 || magnitude.length == 0)
        {
            return ZERO;
        }

        if (n == 0)
        {
            return this;
        }

        if (n < 0)
        {
            return shiftRight( -n);
        }

         var result:BigInteger= BigInteger.fromSignumMag(sign, shiftLeftArr(magnitude, n));

        if (this.nBits != -1)
        {
            result.nBits = sign > 0
                ?   this.nBits
                :   this.nBits + n;
        }

        if (this.nBitLength != -1)
        {
            result.nBitLength = this.nBitLength + n;
        }

        return result;
    }

    /**
     * do a right shift - this does it in place.
     */
    private static function shiftRightInPlace(start:Int, mag:Array<Int>, n:Int) : Void
    {
         var nInts:Int= (n >>> 5) + start;
         var nBits:Int= n & 0x1f;
         var magEnd:Int= mag.length - 1;

        if (nInts != start)
        {
             var delta:Int= (nInts - start);

            //for ( var i:Int= magEnd; i >= nInts; i--)
			var i = magEnd;
			while (i >= nInts)
            {
                mag[i] = mag[i - delta];
				i--; // HAXE
            }
            //for ( var i:Int= nInts - 1; i >= start; i--)
			i = nInts -1;
			while (i>= start)
            {
                mag[i] = 0;
				i--; // HAXE
            }
        }

        if (nBits != 0)
        {
             var nBits2:Int= 32 - nBits;
             var m:Int= mag[magEnd];

            //for ( var i:Int= magEnd; i >= nInts + 1; i--)
			var i = magEnd;
			while(i >= nInts+1)
            {
                 var next:Int= mag[i - 1];

                mag[i] = (m >>> nBits) | (next << nBits2);
                m = next;
				
				i--; // HAXE
            }

            mag[nInts] >>>= nBits;
        }
    }

    /**
     * do a right shift by one - this does it in place.
     */
    private static function shiftRightOneInPlace(start:Int,  mag:Array<Int>) : Void
    {
         var magEnd:Int= mag.length - 1;

         var m:Int= mag[magEnd];

        //for ( var i:Int= magEnd; i > start; i--)
		var i = magEnd;
		while (i > start)
        {
             var next:Int= mag[i - 1];

            mag[i] = (m >>> 1) | (next << 31);
            m = next;
			i--;  // HAXE
        }

        mag[start] >>>= 1;
    }

    public  function shiftRight(n:Int):BigInteger
    {
        if (n == 0)
        {
            return this;
        }

        if (n < 0)
        {
            return shiftLeft( -n);
        }

        if (n >= bitLength())
        {
            return (this.sign < 0 ? valueOfInt( -1) : BigInteger.ZERO);
        }

         var res:Array<Int>= intArray(this.magnitude.length);
        arraycopy(this.magnitude, 0, res, 0, res.length);
        shiftRightInPlace(0, res, n);

        return BigInteger.fromSignumMag(this.sign, res);

        // TODO Port C# version's optimisations...
    }

    public  function signum():Int
    {
        return sign;
    }

    /**
     * returns x = x - y - we assume x is >= y
     */
    private static  function subtractArr(xStart:Int, x:Array<Int>, yStart:Int, y:Array<Int>):Array<Int>
    {
         var iT:Int= x.length;
         var iV:Int= y.length;
         var m:Int64;
         var borrow:Int = 0;
		 
//////trace("iTbefore:"+Std.string(iT));
        do
        {
			var _x = Int64.ofInt(x[--iT]);
			var _y = Int64.ofInt(y[--iV]);
			var _1 = Int64.and(_x, IMASK);
			var _2 = Int64.and(_y, IMASK);
			
			////trace(x);
			////trace(y);
			
			////trace(Std.string(_x) + " XandY " + Std.string(_y));
			////trace(Std.string(_1) + " and " + Std.string(_2));
			
			m = Int64.add(Int64.sub(_1, _2), Int64.ofInt(borrow));
			
            //m = Int64.add(Int64.sub((Int64.and(Int64.ofInt(x[--iT]), IMASK)), (Int64.and(Int64.ofInt(y[--iV]), IMASK))) , Int64.ofInt(borrow));  
			mycnt++;
            ////trace(Std.string(mycnt) + ": m=" + Std.string(m) + " borrow=" + Std.string(borrow));
			//if (mycnt >= 119) throw "UGH";
            x[iT] = Int64.toInt(m);

//            borrow = (m < 0) ? -1 : 0;
            borrow = Int64.toInt(Int64.shr(m, 63));    
        }
        while (iV > yStart);

//////trace("iT after :"+Std.string(iT));
        if (borrow != 0)
        {
			var c = 0;
            while (--x[--iT] == -1)
            {
				// TODO
				//////trace(iT);
				//////trace(x);
				//////trace(--x[--iT]);
				//////trace(x);
				//////trace(y);
				//////trace("-------------C=" + Std.string(c));
				c += 1;
				//if (c > 1) throw "TOOMUCH";
            }
        }

        return x;
    }

    public  function subtract(val:BigInteger):BigInteger
    {
        if (val.sign == 0 || val.magnitude.length == 0)
        {
            return this;
        }
        if (sign == 0 || magnitude.length == 0)
        {
            return val.negate();
        }
        if (this.sign != val.sign)
        {
            return this.add(val.negate());
        }

         var compare:Int= compareToArr(0, magnitude, 0, val.magnitude);
        if (compare == 0)
        {
            return ZERO;
        }

        var bigun:BigInteger;
		var littlun:BigInteger;
        if (compare < 0)
        {
            bigun = val;
            littlun = this;
        }
        else
        {
            bigun = this;
            littlun = val;
        }

        var res = intArray(bigun.magnitude.length);

        arraycopy(bigun.magnitude, 0, res, 0, res.length);

		//var b = new BigInteger();
		//b.ini
		return BigInteger.fromSignumMag(this.sign * compare, subtractArr(0, res, 0, littlun.magnitude));
    }

	/*// PORTED FROM JAVA
    public function toByteArray() : Bytes
    {
        if (sign == 0)
        {
            //return new byte[1]; 
			var b = Bytes.alloc(1);
			b.set(0, 0); // 1);
			return b;
        }

         var bitLength:Int= bitLength();
        var bytes = Bytes.alloc(Math.floor(bitLength / 8) + 1);

         var magIndex:Int= magnitude.length;
         var bytesIndex:Int= bytes.length;

        if (sign > 0)
        {
            while (magIndex > 1)
            {
                 var mag:Int= magnitude[--magIndex];
                bytes.set(--bytesIndex,  mag);			//(byte)
                bytes.set(--bytesIndex, (mag >>> 8));//(byte)
                bytes.set(--bytesIndex,(mag >>> 16));//(byte)
                bytes.set(--bytesIndex, (mag >>> 24));//(byte)
            }

             var lastMag:Int= magnitude[0];
            while ((lastMag & 0xFFFFFF00) != 0)
            {
                bytes.set(--bytesIndex,  lastMag);  //(byte)
                lastMag >>>= 8;
            }

            bytes.set(--bytesIndex,  lastMag);  //(byte)
        }
        else
        {
             var carry:Bool= true;

            while (magIndex > 1)
            {
                 var mag:Int= ~magnitude[--magIndex];

                if (carry)
                {
                    carry = (++mag == 0);
                }

                bytes.set(--bytesIndex,  mag);// byte
                bytes.set(--bytesIndex,  (mag >>> 8));// byte
                bytes.set(--bytesIndex,  (mag >>> 16));// byte
                bytes.set(--bytesIndex,  (mag >>> 24));// byte
            }

             var lastMag:Int= magnitude[0];

            if (carry)
            {
                // Never wraps because magnitude[0] != 0
                --lastMag;
            }

            while ((lastMag & 0xFFFFFF00) != 0)
            {
                bytes.set(--bytesIndex,   ~lastMag); // byte
                lastMag >>>= 8;
            }

            bytes.set(--bytesIndex,   ~lastMag); // (byte)

            if (bytesIndex > 0)
            {
                bytes.set(--bytesIndex,  0xFF);   // byte
            }
        }

		/////////
		trace("ARRAY:");
		for (i in 0...bytes.length) {
			trace(bytes.get(i));
		}
		/////////
		
        return bytes;
    }*/
	
	//FROM C#
        public function toByteArray() : Bytes
        {
            var bitLength = this.bitLength();
            var bytes = Bytes.alloc(Math.floor(bitLength / 8 + 1));

            var bytesCopied = 4;
            var mag = 0;
            var ofs = magnitude.length - 1;
            var carry = 1;
            var lMag:Int64;
            //for (int i = bytes.Length - 1; i >= 0; i--)
			var i = bytes.length - 1;
			while (i >= 0)
            {
                if (bytesCopied == 4 && ofs >= 0)
                {
                    if (sign < 0)
                    {
                        // we are dealing with a +ve number and we want a -ve one, so
                        // invert the magnitude ints and add 1 (propagating the carry)
                        // to make a 2's complement -ve number
                        lMag = Int64.and(Int64.ofInt(~magnitude[ofs--]) , IMASK);
                        //lMag += carry;
						lMag = Int64.add(lMag, Int64.ofInt(carry));
                        if (Int64.toInt(Int64.and(lMag , i64not(IMASK))) != 0)
                            carry = 1;
                        else
                            carry = 0;
                        mag = Int64.toInt(Int64.and(lMag , IMASK));
                    }
                    else
                    {
                        mag = magnitude[ofs--];
                    }
                    bytesCopied = 1;
                }
                else
                {
                    //mag = (int)((uint)mag >> 8);
					mag = mag >>> 8;
                    bytesCopied++;
                }

                bytes.set(i, mag); // [i] = mag; // (byte) mag;
				
				i--; // HAXE
            }

            return bytes;
        }	
	

    public  function xor(val:BigInteger):BigInteger 
    {
        if (this.sign == 0)
        {
            return val;
        }

        if (val.sign == 0)
        {
            return this;
        }

        var/*int[]*/ aMag = this.sign > 0
            ? this.magnitude
            : this.add(ONE).magnitude;

        var/*int[]*/ bMag = val.sign > 0
            ? val.magnitude
            : val.add(ONE).magnitude;

         var resultNeg:Bool= (sign < 0 && val.sign >= 0) || (sign >= 0 && val.sign < 0);
         var resultLength:Int= Math.floor(Math.max(aMag.length, bMag.length));
         var resultMag:Array<Int>= intArray(resultLength);

         var aStart:Int= resultMag.length - aMag.length;
         var bStart:Int= resultMag.length - bMag.length;

        //for ( var i:Int= 0; i < resultMag.length; ++i)
		for (i in 0...resultMag.length)
        {
             var aWord:Int= i >= aStart ? aMag[i - aStart] : 0;
             var bWord:Int= i >= bStart ? bMag[i - bStart] : 0;

            if (this.sign < 0)
            {
                aWord = ~aWord;
            }

            if (val.sign < 0)
            {
                bWord = ~bWord;
            }

            resultMag[i] = aWord ^ bWord;

            if (resultNeg)
            {
                resultMag[i] = ~resultMag[i];
            }
        }

         var result:BigInteger= BigInteger.fromSignumMag(1, resultMag);

        if (resultNeg)
        {
            result = result.not();
        }

        return result;
    }

    public function or(
        value:BigInteger) :BigInteger
    {
        if (this.sign == 0)
        {
            return value;
        }

        if (value.sign == 0)
        {
            return this;
        }

        var/*int[]*/ aMag = this.sign > 0
                        ? this.magnitude
                        : this.add(ONE).magnitude;

        var/*int[]*/ bMag = value.sign > 0
                        ? value.magnitude
                        : value.add(ONE).magnitude;

         var resultNeg:Bool= sign < 0 || value.sign < 0;
         var resultLength:Int= Math.floor(Math.max(aMag.length, bMag.length));
         var resultMag:Array<Int>= intArray(resultLength);

         var aStart:Int= resultMag.length - aMag.length;
         var bStart:Int= resultMag.length - bMag.length;

        //for ( var i:Int= 0; i < resultMag.length; ++i)
		for (i in 0...resultMag.length)
        {
             var aWord:Int= i >= aStart ? aMag[i - aStart] : 0;
             var bWord:Int= i >= bStart ? bMag[i - bStart] : 0;

            if (this.sign < 0)
            {
                aWord = ~aWord;
            }

            if (value.sign < 0)
            {
                bWord = ~bWord;
            }

            resultMag[i] = aWord | bWord;

            if (resultNeg)
            {
                resultMag[i] = ~resultMag[i];
            }
        }

         var result:BigInteger= BigInteger.fromSignumMag(1, resultMag);

        if (resultNeg)
        {
            result = result.not();
        }

        return result;
    }
    
    public  function setBit(n:Int):BigInteger 
        //throws ArithmeticException 
    {
        if (n < 0)
        {
            throw "Bit address less than zero"; //            throw new ArithmeticException("Bit address less than zero");
        }

        if (testBit(n))
        {
            return this;
        }

        // TODO Handle negative values and zero
        if (sign > 0 && n < (bitLength() - 1))
        {
            return flipExistingBit(n);
        }

        return or(ONE.shiftLeft(n));
    }
    
    public  function clearBit(n:Int):BigInteger 
        //throws ArithmeticException 
    {
        if (n < 0)
        {
            throw "Bit address less than zero"; //            throw new ArithmeticException("Bit address less than zero");
        }

        if (!testBit(n))
        {
            return this;
        }

        // TODO Handle negative values
        if (sign > 0 && n < (bitLength() - 1))
        {
            return flipExistingBit(n);
        }

        return andNot(ONE.shiftLeft(n));
    }

    public  function flipBit(n:Int):BigInteger 
        //throws ArithmeticException 
    {
        if (n < 0)
        {
            throw "Bit address less than zero"; //            throw new ArithmeticException("Bit address less than zero");
        }

        // TODO Handle negative values and zero
        if (sign > 0 && n < (bitLength() - 1))
        {
            return flipExistingBit(n);
        }

        return xor(ONE.shiftLeft(n));
    }

    private  function flipExistingBit(n:Int):BigInteger
    {
         var mag:Array<Int>= intArray(this.magnitude.length);
        arraycopy(this.magnitude, 0, mag, 0, mag.length);
        mag[mag.length - 1 - (n >>> 5)] ^= (1 << (n & 31)); // Flip 0 bit to 1
        //mag[mag.Length - 1 - (n / 32)] |= (1 << (n % 32));
        return BigInteger.fromSignumMag(this.sign, mag);
    }

    public  function toString():String
    {
        return toStringRadix(10);
    }

    public  function toStringRadix(rdx:Int):String
    {
        if (magnitude == null)
        {
            return "null";
        }
        if (sign == 0)
        {
            return "0";
        }
        if (rdx < Character_MIN_RADIX || rdx > Character_MAX_RADIX)
        {
            rdx = 10;
        }

        
        // NOTE: This *should* be unnecessary, since the magnitude *should* never have leading zero digits
         var firstNonZero:Int= 0;
        while (firstNonZero < magnitude.length)
        {
            if (magnitude[firstNonZero] != 0)
            {
                break;
            }
            ++firstNonZero;
        }

        if (firstNonZero == magnitude.length)
        {
            return "0";
        }


        var sb:StringBuffer = new StringBuffer();
        if (sign == -1)
        {
            sb.add('-');
        }

        if (rdx == 2)
        {
            /* var pos:Int= firstNonZero;
            sb.add(Integer.toBinaryString(magnitude[pos]));
            while (++pos < magnitude.length)
            {
                appendZeroExtendedString(sb, Integer.toBinaryString(magnitude[pos]), 32);
            }
            break;*/
			throw "Not yet implemented"; // TODO
        }
        else if (rdx == 4)
        {
             var pos:Int= firstNonZero;
             var mag:Int= magnitude[pos];
            if (mag < 0)
            {
                sb.add(Integer_toString(mag >>> 30, 4));
                mag &= (1 << 30) - 1;
                appendZeroExtendedString(sb, Integer_toString(mag, 4), 15);
            }
            else
            {
                sb.add(Integer_toString(mag, 4));
            }
             var mask:Int= (1 << 16) - 1;
            while (++pos < magnitude.length)
            {
                mag = magnitude[pos];
                appendZeroExtendedString(sb, Integer_toString(mag >>> 16, 4), 8);
                appendZeroExtendedString(sb, Integer_toString(mag & mask, 4), 8);
            }
        }
        else if (rdx == 8)
        {
             var mask:Int64= Int64.sub(Int64.shl(Int64.ofInt(1) , 63) , Int64.ofInt(1));
             var u:BigInteger= this.abs();
             var bits:Int= u.bitLength();
            var S:Stack = new Stack();
            while (bits > 63)
            {
                S.push(Long_toString(Int64.and(u.longValue() , mask),8));
                u = u.shiftRight(63);
                bits -= 63;
            }
            sb.add(Long_toString(u.longValue(), 8));
            while (!(S.length == 0)) //S.empty())
            {
                appendZeroExtendedString(sb, Std.string(S.pop()), 21);
            }
        }
        else if (rdx == 16)
        {
             var pos:Int= firstNonZero;
            sb.add(StringTools.hex(magnitude[pos]));
            while (++pos < magnitude.length)
            {
                appendZeroExtendedString(sb, StringTools.hex(magnitude[pos]), 8);
            }
		}
        else
        {
             var q:BigInteger = this.abs();
			 //////trace("bitlength: " + Std.string(q.bitLength()));
            if (q.bitLength() < 64)
            {
                sb.add(Long_toString(q.longValue(), rdx));
            } else {

				// Based on algorithm 1a from chapter 4.4 in Seminumerical Algorithms (Knuth)

				// Work out the largest power of 'rdx' that is a positive 64-bit integer
				// TODO possibly cache power/exponent against radix?
				 var limit:Int64= Int64.div(LongMAX_VALUE , Int64.ofInt(rdx));
				 var power:Int64= Int64.ofInt(rdx);
				 var exponent:Int= 1;
				while (Int64.compare(power,limit) <= 0) //ltEq(power , limit))
				{
					power = Int64.mul(power, Int64.ofInt(rdx)); 
					++exponent;
				}

				 var bigPower:BigInteger= BigInteger.valueOf(power);

				var S:Stack = new Stack();
				while (q.compareTo(bigPower) >= 0)
				{
					var qr:Array<BigInteger> = q.divideAndRemainder(bigPower);
					S.push(Long_toString(qr[1].longValue(), rdx));
					q = qr[0];
				}

				sb.add(Long_toString(q.longValue(), rdx));
				while (!   (S.length == 0)) //       S.empty())
				{
					appendZeroExtendedString(sb, Std.string(S.pop()), exponent);
				}
			}
        }

        return sb.toString();
    }

    private static function appendZeroExtendedString(sb:StringBuffer, s:String, minLength:Int) :Void
    {
        //for ( var len:Int= s.length(); len < minLength; ++len)
		for (len in s.length...minLength)
        {
            sb.add('0');
        }
        sb.add(s);
    }

	static inline function gtEq(val:Int64, val2:Int) {
		return Int64.compare(val, Int64.ofInt(val2)) >= 0;
	}
	static inline function gt(val:Int64, val2:Int) {
		return Int64.compare(val, Int64.ofInt(val2)) > 0;
	}	
	static inline function lt(val:Int64, val2:Int) {
		return Int64.compare(val, Int64.ofInt(val2)) < 0;
	}
	static inline function ltEq(val:Int64, val2:Int) {
		return Int64.compare(val, Int64.ofInt(val2)) <= 0;
	}	
	
	public static function valueOfInt(val:Int) {
		return valueOf(Int64.ofInt(val));
	}
	
    public static  function valueOf(val:Int64):BigInteger
    {
        if (gtEq(val,0)/*val >= 0*/ && lt(val, SMALL_CONSTANTS.length))
        {
            return SMALL_CONSTANTS[Int64.toInt(val)];
        }

        return createValueOf(val);
    }

    private static  function createValueOf(val:Int64):BigInteger
    {
        if (lt(val,0))
        {
            if (val == LongMIN_VALUE)
            {
                return valueOf(i64not(val)).not();
            }

            return valueOf(Int64.neg(val)).negate();
        }

        // store val into a byte array
        var b = Bytes.alloc(8); // new byte[8];
        //for ( var i:Int= 0; i < 8; i++)
		for (i in 0...8)
        {
            //b.set(7 - i) = /*(byte)*/val;
			b.set(7 - i, Int64.toInt(val));
            //val >>= 8;
			val = Int64.shr(val, 8);
        }

        //return new BigInteger(b);
		var ret = new BigInteger();
		ret.init_bval(b);
		return ret;
    }

    public  function getLowestSetBit():Int
    {
        if (this.sign == 0)
        {
            return -1;
        }

        return getLowestSetBitMaskFirst(-1);
    }

    private  function getLowestSetBitMaskFirst(firstWordMask:Int):Int
    {
         var w:Int= magnitude.length, offset = 0;

         var word:Int= magnitude[--w] & firstWordMask;
//        assert magnitude[0] != 0;

        while (word == 0)
        {
            word = magnitude[--w];
            offset += 32;
        }

        while ((word & 0xFF) == 0)
        {
            word >>>= 8;
            offset += 8;
        }

        while ((word & 1) == 0)
        {
            word >>>= 1;
            ++offset;
        }

        return offset;
    }

    public  function testBit(n:Int):Bool 
        //throws ArithmeticException
    {
        if (n < 0)
        {
            throw "Bit position must not be negative"; //            throw new ArithmeticException("Bit position must not be negative");
        }

        if (sign < 0)
        {
            return !not().testBit(n);
        }

         var wordNum:Int= Math.floor(n / 32);
        if (wordNum >= magnitude.length)
            return false;

         var word:Int= magnitude[magnitude.length - 1 - wordNum];
        return ((word >> (n % 32)) & 1) > 0;
    }

	
}
 // 3 passes
 // 155 fixes
