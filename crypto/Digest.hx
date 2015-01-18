package crypto;
import haxe.io.Bytes;

//typedef Byte = Int;

/**
 * interface that a message digest conforms to.
 */
interface Digest 
{

	/**
     * return the algorithm name
     *
     * @return the algorithm name
     */
    public function getAlgorithmName():String;

    /**
     * return the size, in bytes, of the digest produced by this message digest.
     *
     * @return the size, in bytes, of the digest produced by this message digest.
     */
    public function getDigestSize() : Int;

    /**
     * update the message digest with a single byte.
     *
     * @param in the input byte to be entered.
     */
    public function updateOne(inByte:Int) :Void;

    /**
     * update the message digest with a block of bytes.
     *
     * @param in the byte array containing the data.
     * @param inOff the offset into the byte array where the data starts.
     * @param len the length of the data.
     */
    public function update(inBytes:Bytes, inOff:Int, len:Int) : Void;

    /**
     * close the digest, producing the final digest value. The doFinal
     * call leaves the digest reset.
     *
     * @param out the array the digest is to be copied into.
     * @param outOff the offset into the out array the digest is to start at.
     */
    public function doFinal(out:Bytes, outOff:Int):Int;

    /**
     * reset the digest back to it's initial state.
     */
    public function reset() :Void;
	
}