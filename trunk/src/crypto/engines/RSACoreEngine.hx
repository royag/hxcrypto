package crypto.engines;

import crypto.CipherParameters;
import haxe.io.Bytes;
//import crypto.DataLengthException;
//import crypto.params.ParametersWithRandom;
import crypto.params.RSAKeyParameters;
import crypto.params.RSAPrivateCrtKeyParameters;

import crypto.math.BigInteger;

/**
 * this does your basic RSA algorithm.
 */
class RSACoreEngine
{
	public function new() 
	{
	}
	
private var key:RSAKeyParameters;
    private var          forEncryption:Bool;

    /**
     * initialise the RSA engine.
     *
     * @param forEncryption true if we are encrypting, false otherwise.
     * @param param the necessary RSA key parameters.
     */
    public function init(
                  forEncryption:Bool,
         param:RSAKeyParameters)
    {
        
		/*if (param instanceof ParametersWithRandom)
        {
            ParametersWithRandom    rParam = (ParametersWithRandom)param;

            key = (RSAKeyParameters)rParam.getParameters();
        }
        else
        {*/
            key = param; // (RSAKeyParameters) param;
        /*}*/

        this.forEncryption = forEncryption;
    }

    /**
     * Return the maximum size for an input block to this engine.
     * For RSA this is always one byte less than the key size on
     * encryption, and the same length as the key size on decryption.
     *
     * @return maximum size for an input block.
     */
    public function getInputBlockSize():Int
    {
		//trace("KEY: " + Std.string(key));
		//trace("key.getModulus(): " + Std.string(key.getModulus()));
        var     bitSize = key.getModulus().bitLength();

        if (forEncryption)
        {
            return Math.floor( (bitSize + 7) / 8) - 1;
        }
        else
        {
            return Math.floor((bitSize + 7) / 8);
        }
    }

    /**
     * Return the maximum size for an output block to this engine.
     * For RSA this is always one byte less than the key size on
     * decryption, and the same length as the key size on encryption.
     *
     * @return maximum size for an output block.
     */
    public function getOutputBlockSize()
    {
        var     bitSize = key.getModulus().bitLength();

        if (forEncryption)
        {
            return Math.floor((bitSize + 7) / 8);
        }
        else
        {
            return Math.floor((bitSize + 7) / 8) - 1;
        }
    }

    public function convertInput(
        inBytes:Bytes,
	inOff:Int,
	inLen:Int) : BigInteger
    {
		//trace("inLen=" + Std.string(inLen));
		//trace("getInputBlockSize() + 1=" + Std.string(getInputBlockSize() + 1));
		
        if (inLen > (getInputBlockSize() + 1))
        {
            throw /*new DataLengthException(*/"input too large for RSA cipher.";
        }
        else if (inLen == (getInputBlockSize() + 1) && !forEncryption)
        {
            throw /*new DataLengthException(*/"input too large for RSA cipher.";
        }

        var  block:Bytes;

        if (inOff != 0 || inLen != inBytes.length)
        {
            block = Bytes.alloc(inLen); // new byte[inLen];

            //System.arraycopy(inBytes, inOff, block, 0, inLen);
			block.blit(0, inBytes, inOff, inLen);
        }
        else
        {
            block = inBytes;
        }

        var res = BigInteger.fromSignMag(1, block);
        if (res.compareTo(key.getModulus()) >= 0)
        {
            throw /*new DataLengthException(*/"input too large for RSA cipher."; // );
        }

        return res;
    }

	static inline function arraycopy(src:Bytes, srcPos:Int, dst:Bytes, dstPos:Int, len:Int) {
		return dst.blit(dstPos, src, srcPos, len);
	}
	
    public function convertOutput(
	result:BigInteger ) : Bytes
    {
        var      output = result.toByteArray();

		/*
		var s = "byte[";
		for (i in 0...output.length) {
			s += Std.string(output.get(i)) + ",";
		}
		trace(s);
		
		trace(result.magnitude);
		*/
		//throw "OK";
		
        if (forEncryption)
        {
            if (output.get(0) == 0 && output.length > getOutputBlockSize())        // have ended up with an extra zero byte, copy down.
            {
                var  tmp = Bytes.alloc(output.length - 1);

                arraycopy(output, 1, tmp, 0, tmp.length);

                return tmp;
            }

            if (output.length < getOutputBlockSize())     // have ended up with less bytes than normal, lengthen
            {
                var tmp = Bytes.alloc(getOutputBlockSize());

                arraycopy(output, 0, tmp, tmp.length - output.length, output.length);

                return tmp;
            }
        }
        else
        {
            if (output.get(0) == 0)        // have ended up with an extra zero byte, copy down.
            {
                var tmp = Bytes.alloc(output.length - 1);

                arraycopy(output, 1, tmp, 0, tmp.length);

                return tmp;
            }
        }

        return output;
    }

    public function processBlock(input: BigInteger):BigInteger
    {
		if (Std.is(key,RSAPrivateCrtKeyParameters))
        //if (key instanceof RSAPrivateCrtKeyParameters)
        {
            //
            // we have the extra factors, use the Chinese Remainder Theorem - the author
            // wishes to express his thanks to Dirk Bonekaemper at rtsffm.com for
            // advice regarding the expression of this.
            //
             var crtKey:RSAPrivateCrtKeyParameters = cast(key, RSAPrivateCrtKeyParameters);

            var p = crtKey.getP();
            var q = crtKey.getQ();
            var dP = crtKey.getDP();
            var dQ = crtKey.getDQ();
            var qInv = crtKey.getQInv();

            var mP, mQ, h, m;

            // mP = ((input mod p) ^ dP)) mod p
            mP = (input.remainder(p)).modPow(dP, p);

            // mQ = ((input mod q) ^ dQ)) mod q
            mQ = (input.remainder(q)).modPow(dQ, q);

            // h = qInv * (mP - mQ) mod p
            h = mP.subtract(mQ);
            h = h.multiply(qInv);
            h = h.mod(p);               // mod (in Java) returns the positive residual

            // m = h * q + mQ
            m = h.multiply(q);
            m = m.add(mQ);

            return m;
        }
        else
        {
			/*trace("input.magnitude)");
			trace(input.magnitude);
			
			trace("key.getExponent().magnitude)");
			trace(key.getExponent().magnitude);
			trace("key.getModulus().magnitude)");
			trace(key.getModulus().magnitude);*/
			//throw "OK";
            return input.modPow(
                        key.getExponent(), key.getModulus());
        }
    }	
	
}