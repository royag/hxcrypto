package crypto.digests;

import crypto.math.Int64;
import crypto.Util;
import crypto.util.Pack;
import haxe.io.Bytes;

class SHA256Digest extends GeneralDigestImpl implements IGeneralDigest
{

    private static inline var    DIGEST_LENGTH = 32;

    private var     H1:Int;
	private var     H2:Int;
	private var     H3:Int;
	private var     H4:Int;
	private var     H5:Int;
	private var     H6:Int;
	private var     H7:Int;
	private var     H8:Int;

    private var   X:Array<Int>; // = Util.intArray(64);// new int[64];
    private var     xOff:Int;

    /**
     * Standard constructor
     */
    public function new()
    {
		super();
		X = Util.intArray(64);
        reset();
		//trace("after init: H1=" + Std.string(H1));
    }

    /**
     * Copy constructor.  This will copy the state of the provided
     * message digest.
     */
    public function initAsCopySHA256(t:SHA256Digest)
    {
        super.initAsCopyGeneral(t);

        H1 = t.H1;
        H2 = t.H2;
        H3 = t.H3;
        H4 = t.H4;
        H5 = t.H5;
        H6 = t.H6;
        H7 = t.H7;
        H8 = t.H8;

        Util.arraycopyInt(t.X, 0, X, 0, t.X.length);
        xOff = t.xOff;
		return this;
    }	

    public function getAlgorithmName():String
    {
        return "SHA-256";
    }

    public function getDigestSize():Int
    {
        return DIGEST_LENGTH;
    }

    public function processWord(
        inBytes:Bytes,
        inOff:Int):Void
    {
        // Note: Inlined for performance
//        X[xOff] = Pack.bigEndianToInt(inBytes, inOff);
        var n:Int = inBytes.get(  inOff) << 24;
        n |= (inBytes.get(++inOff) & 0xff) << 16;
        n |= (inBytes.get(++inOff) & 0xff) << 8;
        n |= (inBytes.get(++inOff) & 0xff);
        X[xOff] = n;

        if (++xOff == 16)
        {
            processBlock();
        }        
    }	

    public function processLength(
        bitLength:Int64):Void
    {
        if (xOff > 14)
        {
            processBlock();
        }

        X[14] = Int64.toInt(Int64.ushr(bitLength,32));
        X[15] = Int64.toInt(Int64.and(bitLength , Int64.make(0,0xffffffff)));
    }	

    public function doFinal(
        out:Bytes,
        outOff:Int):Int
    {
        finish();

        Pack.intToBigEndian(H1, out, outOff);
        Pack.intToBigEndian(H2, out, outOff + 4);
        Pack.intToBigEndian(H3, out, outOff + 8);
        Pack.intToBigEndian(H4, out, outOff + 12);
        Pack.intToBigEndian(H5, out, outOff + 16);
		Pack.intToBigEndian(H6, out, outOff + 20); // additional to SHA1
		Pack.intToBigEndian(H7, out, outOff + 24); // additional to SHA1
		Pack.intToBigEndian(H8, out, outOff + 28); // additional to SHA1

        reset();

        return DIGEST_LENGTH;
    }	
	
	private function traceArr(b:Bytes) {
		var s = "";
		for (i in 0...b.length) {
			s += Std.string(b.get(i)) + ",";
		}
		trace("byte[" + s + "]");
	}	

    /**
     * reset the chaining variables
     */
    public override function reset():Void
    {
        super.reset();

        /* SHA-256 initial hash value
         * The first 32 bits of the fractional parts of the square roots
         * of the first eight prime numbers
         */

        H1 = 0x6a09e667;
        H2 = 0xbb67ae85;
        H3 = 0x3c6ef372;
        H4 = 0xa54ff53a;
        H5 = 0x510e527f;
        H6 = 0x9b05688c;
        H7 = 0x1f83d9ab;
        H8 = 0x5be0cd19;

        xOff = 0;
		for (i in 0...X.length)
        {
            X[i] = 0;
        }
    }	
	
	
	
	
	
	

    public function processBlock():Void
    {
        //
        // expand 16 word block into 64 word blocks.
        //
        //for (int t = 16; t <= 63; t++)
		for (t in 16...64)
        {
            X[t] = Theta1(X[t - 2]) + X[t - 7] + Theta0(X[t - 15]) + X[t - 16];
        }

        //
        // set up working variables.
        //
        var     a = H1;
        var     b = H2;
        var     c = H3;
        var     d = H4;
        var     e = H5;
        var     f = H6;
        var     g = H7;
        var     h = H8;

        var t = 0;     
        //for(int i = 0; i < 8; i ++)
		for (i in 0...8)
        {
            // t = 8 * i
            h += Sum1(e) + Ch(e, f, g) + K[t] + X[t] | 0;
            d += h | 0;
            h += Sum0(a) + Maj(a, b, c) | 0;
            ++t;

            // t = 8 * i + 1
            g += Sum1(d) + Ch(d, e, f) + K[t] + X[t] | 0;
            c += g | 0;
            g += Sum0(h) + Maj(h, a, b) | 0;
            ++t;

            // t = 8 * i + 2
            f += Sum1(c) + Ch(c, d, e) + K[t] + X[t] | 0;
            b += f | 0;
            f += Sum0(g) + Maj(g, h, a) | 0;
            ++t;

            // t = 8 * i + 3
            e += Sum1(b) + Ch(b, c, d) + K[t] + X[t] | 0;
            a += e | 0;
            e += Sum0(f) + Maj(f, g, h) | 0;
            ++t;

            // t = 8 * i + 4
            d += Sum1(a) + Ch(a, b, c) + K[t] + X[t] | 0;
            h += d | 0;
            d += Sum0(e) + Maj(e, f, g) | 0;
            ++t;

            // t = 8 * i + 5
            c += Sum1(h) + Ch(h, a, b) + K[t] + X[t] | 0;
            g += c | 0;
            c += Sum0(d) + Maj(d, e, f) | 0;
            ++t;

            // t = 8 * i + 6
            b += Sum1(g) + Ch(g, h, a) + K[t] + X[t] | 0;
            f += b | 0;
            b += Sum0(c) + Maj(c, d, e) | 0;
            ++t;

            // t = 8 * i + 7
			/*if (i == 7) { 
				trace(a);  trace(e); 
				trace("EXP=" + (Sum1(f) + Ch(f, g, h) + K[t] + X[t] ));
				trace("K=" + K[t]);
				trace("X=" + X[t]);
				trace(X);
			}*/
            a += Sum1(f) + Ch(f, g, h) + K[t] + X[t] | 0;
			//if (i == 7) { trace(a);  trace(e); }
            e += a | 0;
            a += Sum0(b) + Maj(b, c, d) | 0;
            ++t;

			//trace("i=" + i + " -- a="+a); 
			
		}
		//throw "pause1";

        H1 += a | 0;
		//trace(H1);
		//trace(a);
		//throw "pause";
        H2 += b | 0;
        H3 += c | 0;
        H4 += d | 0;
        H5 += e | 0;
        H6 += f | 0;
        H7 += g | 0;
        H8 += h | 0;

        //
        // reset the offset and clean out the word buffer.
        //
        xOff = 0;
        //for (int i = 0; i < 16; i++)
		for (i in 0...16)
        {
            X[i] = 0;
        }
    }

    /* SHA-256 functions */
    private function Ch(
            x:Int,
            y:Int,
            z:Int)
    {
        return (x & y) ^ ((~x) & z);
    }

    private function Maj(
            x:Int,
            y:Int,
            z:Int)
    {
        return (x & y) ^ (x & z) ^ (y & z);
    }

    private function Sum0(
            x:Int)
    {
        return ((x >>> 2) | (x << 30)) ^ ((x >>> 13) | (x << 19)) ^ ((x >>> 22) | (x << 10));
    }

    private function Sum1(
            x:Int)
    {
        return ((x >>> 6) | (x << 26)) ^ ((x >>> 11) | (x << 21)) ^ ((x >>> 25) | (x << 7));
    }

    private function Theta0(
            x:Int)
    {
        return ((x >>> 7) | (x << 25)) ^ ((x >>> 18) | (x << 14)) ^ (x >>> 3);
    }

    private function Theta1(
            x:Int)
    {
        return ((x >>> 17) | (x << 15)) ^ ((x >>> 19) | (x << 13)) ^ (x >>> 10);
    }

    /* SHA-256 Constants
     * (represent the first 32 bits of the fractional parts of the
     * cube roots of the first sixty-four prime numbers)
     */
    static var K = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ];

	
}