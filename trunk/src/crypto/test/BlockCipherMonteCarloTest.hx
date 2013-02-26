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

class BlockCipherMonteCarloTest extends SimpleTest
{

	
	var id:Int;
    var                 iterations:Int;
    var         engine:BlockCipher;
    var    param:CipherParameters;
    var             input:Bytes;
    var              output:Bytes;

    public function new(
                         id:Int,
                         iterations:Int,
                 engine:BlockCipher,
            param:CipherParameters,
                      input:String,
                      output:String)
    {
        this.id = id;
        this.iterations = iterations;
        this.engine = engine;
        this.param = param;
        this.input = Hex.decode(input);
        this.output = Hex.decode(output);
    }

    public override function getName()
    {
        return engine.getAlgorithmName() + " Monte Carlo Test " + id;
    }

    public override function performTest() : Void
    {
        var cipher = new BufferedBlockCipher(engine);

        cipher.init(true, param);

        var out = Bytes.alloc(input.length); // new byte[input.length];

		out.blit(0, input, 0, output.length);
		var cnt = 0;
		
        for (i in 0...iterations) 
        {
            var len1 = cipher.processBytes(out, 0, out.length, out, 0);

            cipher.doFinal(out, len1);
			cnt ++;
        }

        if (!areEqual(out, output))
        {
            fail("failed - " + "expected " + Hex.encode(output) + " got " + Hex.encode(out) + " on iteration " + Std.string(cnt));
        }

        cipher.init(false, param);

        for (i in 0...iterations) 
        {
            var len1 = cipher.processBytes(out, 0, out.length, out, 0);

            cipher.doFinal(out, len1);
        }

        if (!areEqual(input, out))
        {
            fail("failed reversal");
        }
    }	
	
}