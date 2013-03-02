package crypto;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */
typedef Byte = Int;
 /**
 * A wrapper class that allows block ciphers to be used to process data in
 * a piecemeal fashion. The BufferedBlockCipher outputs a block only when the
 * buffer is full and more data is being added, or on a doFinal.
 * <p>
 * Note: in the case where the underlying cipher is either a CFB cipher or an
 * OFB one the last block may not be a multiple of the block size.
 */
class BufferedBlockCipher 
{

    var         buf:Bytes;
    var            bufOff:Int;

    var        forEncryption:Bool;
    var    cipher:BlockCipher;

    var        partialBlockOkay:Bool;
    var        pgpCFB:Bool;	
	
	/*public function new() 
	{
		
	}*/
	
/**
     * Create a buffered block cipher without padding.
     *
     * @param cipher the underlying block cipher this buffering object wraps.
     */
    public function new(
        cipher:BlockCipher     )
    {
        this.cipher = cipher;

        buf = Bytes.alloc(cipher.getBlockSize());
        bufOff = 0;

        //
        // check if we can handle partial blocks on doFinal.
        //
        var  name = cipher.getAlgorithmName();
        var     idx = name.indexOf('/') + 1;

        pgpCFB = (idx > 0 && (name.indexOf("PGP") == 0)); // .startsWith("PGP", idx));

        if (pgpCFB)
        {
            partialBlockOkay = true;
        }
        else
        {
            partialBlockOkay = (idx > 0 && 
			(
			(name.indexOf("CFB", idx) == 0) || 
			(name.indexOf("OFB", idx) == 0) || 
			(name.indexOf("OpenPGP", idx) == 0) || 
			(name.indexOf("SIC", idx) == 0) || 
			(name.indexOf("GCTR", idx) == 0)));
        }
    }
	
    /**
     * return the cipher this object wraps.
     *
     * @return the cipher this object wraps.
     */
    public function getUnderlyingCipher()
    {
        return cipher;
    }	
	
 /**
     * initialise the cipher.
     *
     * @param forEncryption if true the cipher is initialised for
     *  encryption, if false for decryption.
     * @param params the key and other data required by the cipher.
     * @exception IllegalArgumentException if the params argument is
     * inappropriate.
     */
    public function init(
                     forEncryption:Bool,
            params:CipherParameters)
        //throws IllegalArgumentException
    {
        this.forEncryption = forEncryption;

        reset();

        cipher.init(forEncryption, params);
    }
	
	
	
	 /**
     * return the blocksize for the underlying cipher.
     *
     * @return the blocksize for the underlying cipher.
     */
    public function getBlockSize()
    {
        return cipher.getBlockSize();
    }
	
/**
     * return the size of the output buffer required for an update 
     * an input of len bytes.
     *
     * @param len the length of the input.
     * @return the space required to accommodate a call to update
     * with len bytes of input.
     */
    public function getUpdateOutputSize(
        len:Int):Int
    {
        var total       = len + bufOff;
        var leftOver:Int;

        if (pgpCFB)
        {
            leftOver    = total % buf.length - (cipher.getBlockSize() + 2);
        }
        else
        {
            leftOver    = total % buf.length;
        }

        return total - leftOver;
    }
	
	/**
     * return the size of the output buffer required for an update plus a
     * doFinal with an input of 'length' bytes.
     *
     * @param length the length of the input.
     * @return the space required to accommodate a call to update and doFinal
     * with 'length' bytes of input.
     */
    public function getOutputSize(length:Int) : Int
    {
        // Note: Can assume partialBlockOkay is true for purposes of this calculation
        return length + bufOff;
    }	
	
/**
     * process a single byte, producing an output block if neccessary.
     *
     * @param in the input byte.
     * @param out the space for any output that might be produced.
     * @param outOff the offset from which the output will be copied.
     * @return the number of output bytes copied to out.
     * @exception DataLengthException if there isn't enough space in out.
     * @exception IllegalStateException if the cipher isn't initialised.
     */
    public function processByte(
		inByte:Byte,
		out:Bytes,
		outOff:Int) : Int
        //throws DataLengthException, IllegalStateException
    {
        var         resultLen = 0;

        buf.set(bufOff++,inByte);

        if (bufOff == buf.length)
        {
            resultLen = cipher.processBlock(buf, 0, out, outOff);
            bufOff = 0;
        }

        return resultLen;
    }
	
/**
     * process an array of bytes, producing output if necessary.
     *
     * @param in the input byte array.
     * @param inOff the offset at which the input data starts.
     * @param len the number of bytes to be copied out of the input array.
     * @param out the space for any output that might be produced.
     * @param outOff the offset from which the output will be copied.
     * @return the number of output bytes copied to out.
     * @exception DataLengthException if there isn't enough space in out.
     * @exception IllegalStateException if the cipher isn't initialised.
     */
    public function processBytes(
              inBytes : Bytes,
                 inOff:Int,
                 len:Int,
              out:Bytes,
                 outOff:Int)
        : Int
    {
        if (len < 0)
        {
            throw "Can't have a negative input length!";
        }

        var blockSize   = getBlockSize();
        var length      = getUpdateOutputSize(len);
        
        if (length > 0)
        {
            if ((outOff + length) > out.length)
            {
                throw "output buffer too short";
            }
        }

        var resultLen = 0;
        var gapLen = buf.length - bufOff;

        if (len > gapLen)
        {
			//buf.blit(outOff, inBytes, inOff, gapLen);
			//buf.blit(bufOff, inBytes, inOff, gapLen);
			buf.blit(bufOff, inBytes, inOff, gapLen);
            //System.arraycopy(inBytes, inOff, buf, bufOff, gapLen);

            resultLen += cipher.processBlock(buf, 0, out, outOff);

            bufOff = 0;
            len -= gapLen;
            inOff += gapLen;

            while (len > buf.length)
            {
                resultLen += cipher.processBlock(inBytes, inOff, out, outOff + resultLen);

                len -= blockSize;
                inOff += blockSize;
            }
        }

		buf.blit(bufOff, inBytes, inOff, len);
        //System.arraycopy(inBytes, inOff, buf, bufOff, len);

        bufOff += len;

        if (bufOff == buf.length)
        {
            resultLen += cipher.processBlock(buf, 0, out, outOff + resultLen);
            bufOff = 0;
        }

        return resultLen;
    }
	
	
/**
     * Process the last block in the buffer.
     *
     * @param out the array the block currently being held is copied into.
     * @param outOff the offset at which the copying starts.
     * @return the number of output bytes copied to out.
     * @exception DataLengthException if there is insufficient space in out for
     * the output, or the input is not block size aligned and should be.
     * @exception IllegalStateException if the underlying cipher is not
     * initialised.
     * @exception InvalidCipherTextException if padding is expected and not found.
     * @exception DataLengthException if the input is not block size
     * aligned.
     */
    public function doFinal(
          out:Bytes,
             outOff:Int)
        : Int
    {
		var resultLen = 0;
        try
        {
            

            if (outOff + bufOff > out.length)
            {
                throw "output buffer too short for doFinal()";
            }

            if (bufOff != 0)
            {
                if (!partialBlockOkay)
                {
                    throw "data not block size aligned";
                }

                cipher.processBlock(buf, 0, buf, 0);
                resultLen = bufOff;
                bufOff = 0;
				out.blit(outOff, buf, 0, resultLen);
                //System.arraycopy(buf, 0, out, outOff, resultLen);
            }

        } catch (e:Dynamic) {
			reset();
			throw e;
		}
		reset();
		return resultLen;
        /*finally
        {
            reset();
        }*/
    }	
	
  /**
     * Reset the buffer and cipher. After resetting the object is in the same
     * state as it was after the last init (if there was one).
     */
    public function reset()
    {
        //
        // clean the buffer.
        //
        for (i in 0...buf.length) //int i = 0; i < buf.length; i++)
        {
            buf.set(i,0);
        }

        bufOff = 0;

        //
        // reset the underlying cipher.
        //
        cipher.reset();
    }	
}