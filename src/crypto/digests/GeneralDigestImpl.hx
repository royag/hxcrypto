package crypto.digests;
import crypto.ExtendedDigest;
import crypto.math.Int64;
import crypto.Util;
import haxe.io.Bytes;

/**
 * base implementation of MD4 family style digest as outlined in
 * "Handbook of Applied Cryptography", pages 344 - 347.
 */
class GeneralDigestImpl //implements ExtendedDigest
{

	private static inline var BYTE_LENGTH:Int = 64;
    private var xBuf:Bytes;
    private var xBufOff:Int;

    private var byteCount:Int64;

    /**
     * Standard constructor
     */
    private function new()
    {
		if (!Std.is(this, IGeneralDigest)) {
			throw "must implement IGeneralDigest";
		}
        xBuf = Bytes.alloc(4);// new byte[4];
        xBufOff = 0;
    }

	private function initAsCopyGeneral(t:GeneralDigestImpl) {
        xBuf = Bytes.alloc(t.xBuf.length);
        Util.arraycopy(t.xBuf, 0, xBuf, 0, t.xBuf.length);

        xBufOff = t.xBufOff;
        byteCount = t.byteCount;
    }

    public function updateOne(
        inByte:Int):Void
    {
		xBuf.set(xBufOff++, inByte);

        if (xBufOff == xBuf.length)
        {
            cast(this,IGeneralDigest).processWord(xBuf, 0);
            xBufOff = 0;
        }

		byteCount = Int64.add(byteCount, Int64.ofInt(1));
        //byteCount++;
    }

    public function update(
		inBytes:Bytes,
        inOff:Int,
		len:Int):Void
    {
        //
        // fill the current word
        //
        while ((xBufOff != 0) && (len > 0))
        {
            updateOne(inBytes.get(inOff));

            inOff++;
            len--;
        }

        //
        // process whole words.
        //
        while (len > xBuf.length)
        {
            cast(this,IGeneralDigest).processWord(inBytes, inOff);

            inOff += xBuf.length;
            len -= xBuf.length;
            //byteCount += xBuf.length;
			byteCount = Int64.add(byteCount, Int64.ofInt(xBuf.length));
        }

        //
        // load in the remainder.
        //
        while (len > 0)
        {
            updateOne(inBytes.get(inOff));

            inOff++;
            len--;
        }
    }

    public function finish():Void
    {
		
        var bitLength:Int64 = Int64.shl(byteCount, 3); //(byteCount << 3);

        //
        // add the pad bytes.
        //
        updateOne(/*(byte)*/128);

        while (xBufOff != 0)
        {
            updateOne(/*(byte)*/0);
        }

        cast(this,IGeneralDigest).processLength(bitLength);

        cast(this,IGeneralDigest).processBlock();
    }

    public function reset():Void
    {
        byteCount = Int64.ofInt(0);

        xBufOff = 0;
        //for (int i = 0; i < xBuf.length; i++)
		for (i in 0...xBuf.length)
        {
            xBuf.set(i, 0);
        }
    }

    public function getByteLength():Int
    {
        return BYTE_LENGTH;
    }
    
    /*private function processWord(inBytes:Bytes, inOff:Int):Void {
		throw "abstract";
	}

    private function processLength(bitLength:Int64):Void {
		throw "abstract";
	}

    private function processBlock():Void {
		throw "abstract";
	}*/
	
}