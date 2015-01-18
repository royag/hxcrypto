package crypto.engines;

import crypto.AsymmetricBlockCipher;
import crypto.CipherParameters;
import crypto.params.RSAKeyParameters;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */
class RSAEngine implements AsymmetricBlockCipher
{
    /*private*/ public var core:RSACoreEngine;

	public function new() : Void {
		
	}
	
    /**
     * initialise the RSA engine.
     *
     * @param forEncryption true if we are encrypting, false otherwise.
     * @param param the necessary RSA key parameters.
     */
    public function init(
                     forEncryption:Bool,
        param:CipherParameters    ) : Void
    {
        if (core == null)
        {
            core = new RSACoreEngine();
        }

		var rsaParam:RSAKeyParameters = cast(param, RSAKeyParameters);
        core.init(forEncryption, rsaParam);
    }

    /**
     * Return the maximum size for an input block to this engine.
     * For RSA this is always one byte less than the key size on
     * encryption, and the same length as the key size on decryption.
     *
     * @return maximum size for an input block.
     */
    public function getInputBlockSize()
    {
        return core.getInputBlockSize();
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
        return core.getOutputBlockSize();
    }

    /**
     * Process a single block using the basic RSA algorithm.
     *
     * @param in the input array.
     * @param inOff the offset into the input buffer where the data starts.
     * @param inLen the length of the data to be processed.
     * @return the result of the RSA process.
     * @exception DataLengthException the input block is too large.
     */
    public function processBlock(
        inBytes:Bytes,
             inOff:Int,
             inLen:Int) : Bytes
    {
        if (core == null)
        {
            throw /*new IllegalStateException(*/"RSA engine not initialised"; // );
        }

        return core.convertOutput(core.processBlock(core.convertInput(inBytes, inOff, inLen)));
    }
	
}