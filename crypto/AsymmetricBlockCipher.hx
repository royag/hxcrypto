package crypto;
import haxe.io.Bytes;


/**
 * base interface that a public/private key block cipher needs
 * to conform to.
 */
interface AsymmetricBlockCipher
{
    /**
     * initialise the cipher.
     *
     * @param forEncryption if true the cipher is initialised for 
     *  encryption, if false for decryption.
     * @param param the key and other data required by the cipher.
     */
    function init(forEncryption:Bool, param:CipherParameters) : Void;

    /**
     * returns the largest size an input block can be.
     *
     * @return maximum size for an input block.
     */
    function getInputBlockSize():Int;

    /**
     * returns the maximum size of the block produced by this cipher.
     *
     * @return maximum size of the output block produced by the cipher.
     */
    function getOutputBlockSize():Int;

    /**
     * process the block of len bytes stored in in from offset inOff.
     *
     * @param in the input data
     * @param inOff offset into the in array where the data starts
     * @param len the length of the block to be processed.
     * @return the resulting byte array of the encryption/decryption process.
     * @exception InvalidCipherTextException data decrypts improperly.
     * @exception DataLengthException the input data is too large for the cipher.
     */
    function processBlock(inBytes:Bytes, inOff:Int, len:Int) : Bytes;
        //throws InvalidCipherTextException;
}
