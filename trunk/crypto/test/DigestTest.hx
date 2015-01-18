package crypto.test;

import crypto.Digest;
import haxe.io.Bytes;
import crypto.Hex;

class DigestTest extends SimpleTest
{

	private var digest:Digest;
    private var input:Array<String>;
    private var results:Array<String>;
	
	//private var vcount = 0;

    private function new(
         digest:Digest,
        input:Array<String>,
        results:Array<String>)
    {
        this.digest = digest;
        this.input = input;
        this.results = results;
    }
    
    public override function getName():String
    {
        return digest.getAlgorithmName();
    }
    
    public override function performTest():Void
    {
		trace("------"+ getName() + " TEST");
        var resBuf = Bytes.alloc(digest.getDigestSize());
    
        //for (int i = 0; i < input.length - 1; i++)
		//trace(input.length-1);
		for (i in 0...input.length-1)
        {
            var m = toByteArray(input[i]);
            
            vectorTest(digest, i, resBuf, m, Hex.decode(results[i]));
        }
        
        var lastV = toByteArray(input[input.length - 1]);
        var lastDigest:Bytes = Hex.decode(results[input.length - 1]);
        
        vectorTest(digest, input.length - 1, resBuf, lastV, Hex.decode(results[input.length - 1]));
        
        //
        // clone test
        //
        digest.update(lastV, 0, Math.floor(lastV.length/2));

        // clone the Digest
        var d:Digest = cloneDigest(digest);
        
        digest.update(lastV, Math.floor(lastV.length/2), lastV.length - Math.floor(lastV.length/2));
        digest.doFinal(resBuf, 0);

        if (!areEqual(lastDigest, resBuf))
        {
            fail3("failing clone vector test", results[results.length - 1], Hex.encode(resBuf));
        }

        d.update(lastV, Math.floor(lastV.length/2), lastV.length - Math.floor(lastV.length/2));
        d.doFinal(resBuf, 0);

        if (!areEqual(lastDigest, resBuf))
        {
            fail3("failing second clone vector test", results[results.length - 1], Hex.encode(resBuf));
        }
		
		trace(getName() + " basic test passed");
    }

    private function toByteArray(input:String):Bytes
    {
        var bytes = Bytes.alloc(input.length);
        
        //for (int i = 0; i != bytes.length; i++)
		for (i in 0...bytes.length)
        {
            bytes.set(i, /*(byte)*/input.charCodeAt(i)); // NB : might getsome UNICODE trouble here??
        }
        
        return bytes;
    }
    
    private function vectorTest(
         digest:Digest,
        count:Int,
        resBuf:Bytes ,
        input:Bytes ,
	expected:Bytes ):Void
    {
		//traceArr(expected);
        digest.update(input, 0, input.length);
        digest.doFinal(resBuf, 0);

        if (!areEqual(resBuf, expected))
        {
            fail("Vector " + count + " failed got " + Hex.encode(resBuf) + "expected "+ Hex.encode(expected));
        }
		trace(getName() + " vector test "+count+" passed");
    }
    
    private function cloneDigest(digest:Digest):Digest {
		throw "abstract";
		return null;
	}
	
	/*private function traceArr(b:Bytes) {
		var s = "";
		for (i in 0...b.length) {
			s += Std.string(b.get(i)) + ",";
		}
		trace("byte[" + s + "]");
	}*/
	
    
    //
    // optional tests
    //
    private function millionATest(
	expected:String):Void
    {
        var resBuf = Bytes.alloc(digest.getDigestSize());
        
        //for (int i = 0; i < 1000000; i++)
		for (i in 0...1000000)
        {
            digest.updateOne("a".charCodeAt(0));// (byte)'a');  // UNICODE trouble ?
        }
        
        digest.doFinal(resBuf, 0);

        if (!areEqual(resBuf, Hex.decode(expected)))
        {
            fail("Million a's failed");
        }
		trace(getName() + " millionATest test passed");
    }
    
    private function sixtyFourKTest(
	expected:String ):Void
    {
        var resBuf = Bytes.alloc(digest.getDigestSize());
        
        //for (int i = 0; i < 65536; i++)
		for (i in 0...65536)
        {
            digest.updateOne(/*(byte)*/(i & 0xff));
        }
        
        digest.doFinal(resBuf, 0);

        if (!areEqual(resBuf, Hex.decode(expected)))
        {
            fail("64k test failed");
        }
		trace(getName() + " sixtyFourKTest test passed");
    }
	
}