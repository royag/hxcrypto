package crypto;
import haxe.io.Bytes;
//import haxe.Int32;

/**
 * ...
 * @author test
 */

 //typedef Byte = Int;
 
interface BlockCipher 
{
	
/**
     * Initialise the cipher.
     *
     * @param forEncryption if true the cipher is initialised for
     *  encryption, if false for decryption.
     * @param params the key and other data required by the cipher.
     * @exception IllegalArgumentException if the params argument is
     * inappropriate.
     */
    function init(forEncryption:Bool, params:CipherParameters) : Void;

    /**
     * Return the name of the algorithm the cipher implements.
     *
     * @return the name of the algorithm the cipher implements.
     */
    function getAlgorithmName() : String;

    /**
     * Return the block size for this cipher (in bytes).
     *
     * @return the block size for this cipher in bytes.
     */
    function getBlockSize() : Int;

    /**
     * Process one block of input from the array in and write it to
     * the out array.
     *
     * @param in the array containing the input data.
     * @param inOff offset into the in array the data starts at.
     * @param out the array the output data will be copied into.
     * @param outOff the offset into the out array the output will start at.
     * @exception DataLengthException if there isn't enough data in in, or
     * space in out.
     * @exception IllegalStateException if the cipher isn't initialised.
     * @return the number of bytes processed and produced.
     */
    function processBlock(inBytes : Bytes, inOff:Int, out:Bytes, outOff:Int) : Int;

    /**
     * Reset the cipher. After resetting the cipher is in the same state
     * as it was after the last init (if there was one).
     */
    function reset() : Void;	
	
}