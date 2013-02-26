package crypto.test;

import crypto.engines.RSAEngine;
import crypto.params.RSAKeyParameters;
import crypto.params.RSAPrivateCrtKeyParameters;
import crypto.Hex;
import crypto.math.BigInteger;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */
class RSATest extends SimpleTest
{
	
    static var  mod = BigInteger.fromStringRadix("b259d2d6e627a768c94be36164c2d9fc79d97aab9253140e5bf17751197731d6f7540d2509e7b9ffee0a70a6e26d56e92d2edd7f85aba85600b69089f35f6bdbf3c298e05842535d9f064e6b0391cb7d306e0a2d20c4dfb4e7b49a9640bdea26c10ad69c3f05007ce2513cee44cfe01998e62b6c3637d3fc0391079b26ee36d5", 16);
    static var  pubExp = BigInteger.fromStringRadix("11", 16);
    static var  privExp = BigInteger.fromStringRadix("92e08f83cc9920746989ca5034dcb384a094fb9c5a6288fcc4304424ab8f56388f72652d8fafc65a4b9020896f2cde297080f2a540e7b7ce5af0b3446e1258d1dd7f245cf54124b4c6e17da21b90a0ebd22605e6f45c9f136d7a13eaac1c0f7487de8bd6d924972408ebb58af71e76fd7b012a8d0e165f3ae2e5077a8648e619", 16);
    static var  p = BigInteger.fromStringRadix("f75e80839b9b9379f1cf1128f321639757dba514642c206bbbd99f9a4846208b3e93fbbe5e0527cc59b1d4b929d9555853004c7c8b30ee6a213c3d1bb7415d03", 16);
    static var  q = BigInteger.fromStringRadix("b892d9ebdbfc37e397256dd8a5d3123534d1f03726284743ddc6be3a709edb696fc40c7d902ed804c6eee730eee3d5b20bf6bd8d87a296813c87d3b3cc9d7947", 16);
    static var  pExp = BigInteger.fromStringRadix("1d1a2d3ca8e52068b3094d501c9a842fec37f54db16e9a67070a8b3f53cc03d4257ad252a1a640eadd603724d7bf3737914b544ae332eedf4f34436cac25ceb5", 16);
    static var  qExp = BigInteger.fromStringRadix("6c929e4e81672fef49d9c825163fec97c4b7ba7acb26c0824638ac22605d7201c94625770984f78a56e6e25904fe7db407099cad9b14588841b94f5ab498dded", 16);
    static var  crtCoef = BigInteger.fromStringRadix("dae7651ee69ad1d081ec5e7188ae126f6004ff39556bde90e0b870962fa7b926d070686d8244fe5a9aa709a95686a104614834b0ada4b10f53197a5cb4c97339", 16);

    static var input = "4e6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e";

    //
    // to check that we handling byte extension by big number correctly.
    //
    static var edgeInput = "ff6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e";
    
    static var oversizedSig = Hex.decode("01ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff004e6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e");
    static var dudBlock = Hex.decode("000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff004e6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e");
    static var truncatedDataBlock = Hex.decode("0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff004e6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e");
    static var incorrectPadding = Hex.decode("0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4e6f77206973207468652074696d6520666f7220616c6c20676f6f64206d656e");
    static var missingDataBlock = Hex.decode("0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
	

	public function rawTest() {
		mod = BigInteger.fromStringRadix("b259d2d6e627a768c94be36164c2d9fc79d97aab9253140e5bf17751197731d6f7540d2509e7b9ffee0a70a6e26d56e92d2edd7f85aba85600b69089f35f6bdbf3c298e05842535d9f064e6b0391cb7d306e0a2d20c4dfb4e7b49a9640bdea26c10ad69c3f05007ce2513cee44cfe01998e62b6c3637d3fc0391079b26ee36d5", 16);
		//trace("mod=" + Std.string(mod));
        var    pubParameters = new RSAKeyParameters(false, mod, pubExp);
        var    privParameters = new RSAPrivateCrtKeyParameters(mod, pubExp, privExp, p, q, pExp, qExp, crtCoef);
        var              data = Hex.decode(edgeInput);	
		
		//trace("edgeInput-LEN = " + Std.string(edgeInput.length));
		//trace("DATA-LEN = " + Std.string(data.length));
		
		/*var s = "byte[";
		for (i in 0...data.length) {
			s += Std.string(data.get(i)) + ",";
		}
		trace("DATA:" + s);
		*/
        //
        // RAW
        //
        var   eng = new RSAEngine();
        eng.init(true, pubParameters);

		//var cv = eng.core.convertInput(data, 0, data.length);
		//trace(cv.magnitude);
		//trace(cv.sign);
		
		

        try
        {
            data = eng.processBlock(data, 0, data.length);
			
			var expHex = "576a1f885e3420128c8a656097ba7d8bb4c6f1b1853348cf2ba976971dbdbefc3497a9fb17ba03d95f28fad91247d6f8ebc463fa8ada974f0f4e28961565a73a46a465369e0798ccbf7893cb9afaa7c426cc4fea6f429e67b6205b682a9831337f2548fd165c2dd7bf5b54be5894403d6e9f6283e65fb134cd4687bf86f95e7a";
			expHex = expHex.toUpperCase();
			var hexdata = Hex.encode(data).toUpperCase();
			if (hexdata != expHex) {
				trace(hexdata);
				var s = "byte[";
				for (i in 0...data.length) {
					s += Std.string(data.get(i)) + ",";
				}
				trace("got: " + hexdata);
				trace("expected: " + expHex);
				
				var b = Bytes.alloc(1);
				b.set(0, 0x88);
				trace(b.get(0));
				trace(Hex.encode(b));
				
				throw "RAW PUBLIC FAILED";
			}
			
		//throw "OK2";
        }
        catch (e:String)
        {
            fail("RSA: failed - exception " + e);
        }

        eng.init(false, privParameters);

        try
        {
            data = eng.processBlock(data, 0, data.length);
        }
        catch (e:String)
        {
            fail2("failed - exception " + e, e);
        }

        if (!(edgeInput == Hex.encode(data).toLowerCase())) //).toString()))
        {
			trace("fail>" + edgeInput);
			trace("fail>" + Hex.encode(data).toLowerCase());
            fail("failed RAW edge Test");
        }

        data = Hex.decode(input);

        eng.init(true, pubParameters);

        try
        {
            data = eng.processBlock(data, 0, data.length);
        }
        catch (e:String)
        {
            fail2("failed - exception " + e, e);
        }

        eng.init(false, privParameters);

        try
        {
            data = eng.processBlock(data, 0, data.length);
        }
        catch (e:String)
        {
            fail2("failed - exception " + e, e);
        }

        if (!(input == Hex.encode(data).toLowerCase()))
        {
            fail("failed RAW Test");
        }
		trace("RSA raw OK");
	}
	
	public function new() 
	{
		
	}
	
}