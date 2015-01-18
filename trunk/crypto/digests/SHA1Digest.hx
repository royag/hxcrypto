package crypto.digests;

import crypto.math.Int64;
import crypto.Util;
import crypto.util.Pack;
import haxe.io.Bytes;

class SHA1Digest extends GeneralDigestImpl implements IGeneralDigest
{
    private static inline var    DIGEST_LENGTH = 20;

    private var     H1:Int;
	private var     H2:Int;
	private var     H3:Int;
	private var     H4:Int;
	private var     H5:Int;

    private var   X:Array<Int>; // = Util.intArray(80);// new int[80];
    private var     xOff:Int;
	
	public function new() 
	{
		super();
		X = Util.intArray(80);
		reset();
	}
	
	/**
     * Copy constructor.  This will copy the state of the provided
     * message digest.
     */
    public function initAsCopySHA1(t:SHA1Digest)
    {
        super.initAsCopyGeneral(t);

        H1 = t.H1;
        H2 = t.H2;
        H3 = t.H3;
        H4 = t.H4;
        H5 = t.H5;

        Util.arraycopyInt(t.X, 0, X, 0, t.X.length);
        xOff = t.xOff;
		return this;
    }
	public function getAlgorithmName():String
    {
        return "SHA-1";
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

        //X[14] = (int)(bitLength >>> 32);
        X[14] = Int64.toInt(Int64.ushr(bitLength,32));
        //X[15] = (int)(bitLength & 0xffffffff);
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

        reset();

        return DIGEST_LENGTH;
    }

    /**
     * reset the chaining variables
     */
    public override function reset():Void
    {
        super.reset();

        H1 = 0x67452301;
        H2 = 0xefcdab89;
        H3 = 0x98badcfe;
        H4 = 0x10325476;
        H5 = 0xc3d2e1f0;

        xOff = 0;
        //for (int i = 0; i != X.length; i++)
		for (i in 0...X.length)
        {
            X[i] = 0;
        }
    }

    //
    // Additive constants
    //
    private static inline var     Y1:Int = 0x5a827999;
    private static inline var     Y2:Int = 0x6ed9eba1;
    private static inline var     Y3:Int = 0x8f1bbcdc;
    private static inline var     Y4:Int = 0xca62c1d6;
   
    private function f(
            u:Int,
            v:Int,
            w:Int):Int
    {
        return ((u & v) | ((~u) & w));
    }

    private function h(
            u:Int,
            v:Int,
            w:Int):Int
    {
        return (u ^ v ^ w);
    }

    private function g(
            u:Int,
            v:Int,
            w:Int):Int
    {
        return ((u & v) | (u & w) | (v & w));
    }

    public function processBlock():Void
    {
        //
        // expand 16 word block into 80 word block.
        //
        //for (int i = 16; i < 80; i++)
		for (i in 16...80)
        {
            var t:Int = X[i - 3] ^ X[i - 8] ^ X[i - 14] ^ X[i - 16];
            X[i] = t << 1 | t >>> 31;
        }

        //
        // set up working variables.
        //
        var     A = H1;
        var     B = H2;
        var     C = H3;
        var     D = H4;
        var     E = H5;

        //
        // round 1
        //
        var idx = 0;
        
        //for (int j = 0; j < 4; j++)
		for (j in 0...4)
        {
            // E = rotateLeft(A, 5) + f(B, C, D) + E + X[idx++] + Y1
            // B = rotateLeft(B, 30)
            E = 0xFFFFFFFF & (E + (A << 5 | A >>> 27) + f(B, C, D) + X[idx++] + Y1);
            B = 0xFFFFFFFF & (B << 30 | B >>> 2);
        
            D = 0xFFFFFFFF & (D + (E << 5 | E >>> 27) + f(A, B, C) + X[idx++] + Y1);
            A = 0xFFFFFFFF & (A << 30 | A >>> 2);
       
            C = 0xFFFFFFFF & (C + (D << 5 | D >>> 27) + f(E, A, B) + X[idx++] + Y1);
            E = 0xFFFFFFFF & (E << 30 | E >>> 2);
       
            B = 0xFFFFFFFF & (B + (C << 5 | C >>> 27) + f(D, E, A) + X[idx++] + Y1);
            D = 0xFFFFFFFF & (D << 30 | D >>> 2);

            A = 0xFFFFFFFF & (A + (B << 5 | B >>> 27) + f(C, D, E) + X[idx++] + Y1);
            C = 0xFFFFFFFF & (C << 30 | C >>> 2);
        }
        
        //
        // round 2
        //
        //for (int j = 0; j < 4; j++)
		for (j in 0...4)
        {
            // E = rotateLeft(A, 5) + h(B, C, D) + E + X[idx++] + Y2
            // B = rotateLeft(B, 30)
            E = 0xFFFFFFFF & (E + (A << 5 | A >>> 27) + h(B, C, D) + X[idx++] + Y2);
            B = 0xFFFFFFFF & (B << 30 | B >>> 2);   
            
            D = 0xFFFFFFFF & (D + (E << 5 | E >>> 27) + h(A, B, C) + X[idx++] + Y2);
            A = 0xFFFFFFFF & (A << 30 | A >>> 2);
            
            C = 0xFFFFFFFF & (C + (D << 5 | D >>> 27) + h(E, A, B) + X[idx++] + Y2);
            E = 0xFFFFFFFF & (E << 30 | E >>> 2);
            
            B = 0xFFFFFFFF & (B + (C << 5 | C >>> 27) + h(D, E, A) + X[idx++] + Y2);
            D = 0xFFFFFFFF & (D << 30 | D >>> 2);

            A = 0xFFFFFFFF & (A + (B << 5 | B >>> 27) + h(C, D, E) + X[idx++] + Y2);
            C = 0xFFFFFFFF & (C << 30 | C >>> 2);
        }
        
        //
        // round 3
        //
        //for (int j = 0; j < 4; j++)
		for (j in 0...4)
        {
            // E = rotateLeft(A, 5) + g(B, C, D) + E + X[idx++] + Y3
            // B = rotateLeft(B, 30)
            E = 0xFFFFFFFF & (E + (A << 5 | A >>> 27) + g(B, C, D) + X[idx++] + Y3);
            B = 0xFFFFFFFF & (B << 30 | B >>> 2);
            
            D = 0xFFFFFFFF & (D + (E << 5 | E >>> 27) + g(A, B, C) + X[idx++] + Y3);
            A = 0xFFFFFFFF & (A << 30 | A >>> 2);
            
            C = 0xFFFFFFFF & (C + (D << 5 | D >>> 27) + g(E, A, B) + X[idx++] + Y3);
            E = 0xFFFFFFFF & (E << 30 | E >>> 2);
            
            B = 0xFFFFFFFF & (B + (C << 5 | C >>> 27) + g(D, E, A) + X[idx++] + Y3);
            D = 0xFFFFFFFF & (D << 30 | D >>> 2);

            A = 0xFFFFFFFF & (A + (B << 5 | B >>> 27) + g(C, D, E) + X[idx++] + Y3);
            C = 0xFFFFFFFF & (C << 30 | C >>> 2);
        }

        //
        // round 4
        //
        //for (int j = 0; j <= 3; j++)
		for (j in 0...4)
        {
            // E = rotateLeft(A, 5) + h(B, C, D) + E + X[idx++] + Y4
            // B = rotateLeft(B, 30)
            E = 0xFFFFFFFF & (E + (A << 5 | A >>> 27) + h(B, C, D) + X[idx++] + Y4);
            B = 0xFFFFFFFF & (B << 30 | B >>> 2);
            
            D = 0xFFFFFFFF & (D + (E << 5 | E >>> 27) + h(A, B, C) + X[idx++] + Y4);
            A = 0xFFFFFFFF & (A << 30 | A >>> 2);
            
            C = 0xFFFFFFFF & (C + (D << 5 | D >>> 27) + h(E, A, B) + X[idx++] + Y4);
            E = 0xFFFFFFFF & (E << 30 | E >>> 2);
            
            B = 0xFFFFFFFF & (B + (C << 5 | C >>> 27) + h(D, E, A) + X[idx++] + Y4);
            D = 0xFFFFFFFF & (D << 30 | D >>> 2);

            A = 0xFFFFFFFF & (A + (B << 5 | B >>> 27) + h(C, D, E) + X[idx++] + Y4);
            C = 0xFFFFFFFF & (C << 30 | C >>> 2);
        }


        H1 += 0xFFFFFFFF & (A);
        H2 += 0xFFFFFFFF & (B);
        H3 += 0xFFFFFFFF & (C);
        H4 += 0xFFFFFFFF & (D);
        H5 += 0xFFFFFFFF & (E);

        //
        // reset start of the buffer.
        //
        xOff = 0;
        //for (int i = 0; i < 16; i++)
		for (i in 0...16)
        {
            X[i] = 0;
        }
    }
	
}