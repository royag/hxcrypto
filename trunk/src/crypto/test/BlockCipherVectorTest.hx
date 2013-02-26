package crypto.test;

import crypto.BlockCipher;
import crypto.CipherParameters;
import crypto.Hex;
import crypto.BufferedBlockCipher;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */

class BlockCipherVectorTest extends SimpleTest
{

	var id:Int;
    var         engine:BlockCipher;
    var    param:CipherParameters;
    var             input:Bytes;
    var              output:Bytes;

    public function new(
                         id:Int,
                 engine:BlockCipher,
            param:CipherParameters,
                      input:String,
                      output:String)
    {
        this.id = id;
        this.engine = engine;
        this.param = param;
        this.input = Hex.decode(input);
        this.output = Hex.decode(output);
    }


    public override function getName()
    {
        return engine.getAlgorithmName() + " Vector Test " + id;
    }

    public override function performTest()
    {
		
        var cipher = new BufferedBlockCipher(engine);

        cipher.init(true, param);

		var out = Bytes.alloc(input.length);

        var len1 = cipher.processBytes(input, 0, input.length, out, 0);

        cipher.doFinal(out, len1);

        if (!areEqual(out, output))
        {
            fail("failed - " + "expected " + new String(Hex.encode(output)) + " got " + new String(Hex.encode(out)));
        }

        cipher.init(false, param);

        var len2 = cipher.processBytes(output, 0, output.length, out, 0);

        cipher.doFinal(out, len2);

        if (!areEqual(input, out))
        {
            fail("failed reversal got " + new String(Hex.encode(out)));
        }
    }	
	
}