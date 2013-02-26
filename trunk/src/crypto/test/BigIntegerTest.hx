package crypto.test;

import crypto.math.BigInteger;
import crypto.math.Random;
import haxe.io.Bytes;
/**
 * ...
 * @author roy
 */

 typedef SecureRandom = Random;
 
class BigIntegerTest extends SimpleTest
{
	
    private static var VALUE1 = BigInteger.fromString("1234");
    private static var VALUE2 = BigInteger.fromString("1234567890");
    private static var VALUE3 = BigInteger.fromString("12345678901234567890123");
    private static var zero = BigInteger.ZERO;
    private static var one = BigInteger.ONE;
    private static var two = BigInteger.valueOfInt(2);	

	public function new() 
	{}
	
	private function clearBitTest():Void
    {
        var value = VALUE1.clearBit(3);
        var result = BigInteger.fromString("1234");
        
        if (!value.equals(result))
        {
            fail("clearBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.clearBit(3);
        result = BigInteger.fromString("1234567890");
        
        if (!value.equals(result))
        {
            fail("clearBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.clearBit(3);
        result = BigInteger.fromString("12345678901234567890115");
        
        if (!value.equals(result))
        {
            fail("clearBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.clearBit(55);
        result = BigInteger.fromString("1234567890");
        
        if (!value.equals(result))
        {
            fail("clearBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.clearBit(55);
        result = BigInteger.fromString("12345642872437548926155");
        
        if (!value.equals(result))
        {
            fail("clearBit - expected: " + result + " got: " + value);
        }
		
		trace("clearBitTest OK");
    }
	
    private function flipBitTest()
    {
        var value = VALUE1.flipBit(3);
        var result = BigInteger.fromString("1242");
        
        if (!value.equals(result))
        {
            fail("flipBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.flipBit(3);
        result = BigInteger.fromString("1234567898");
        
        if (!value.equals(result))
        {
            fail("flipBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.flipBit(3);
        result = BigInteger.fromString("12345678901234567890115");
        
        if (!value.equals(result))
        {
            fail("flipBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.flipBit(55);
        result = BigInteger.fromString("36028798253531858");
        
        if (!value.equals(result))
        {
            fail("flipBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.flipBit(55);
        result = BigInteger.fromString("12345642872437548926155");
        
        if (!value.equals(result))
        {
            fail("flipBit - expected: " + result + " got: " + value);
        }
		trace("flipBitTest OK");
    }
	
    private function setBitTest()
    {
        var value = VALUE1.setBit(3);
        var result = BigInteger.fromString("1242");
        
        if (!value.equals(result))
        {
            fail("setBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.setBit(3);
        result = BigInteger.fromString("1234567898");
        
        if (!value.equals(result))
        {
            fail("setBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.setBit(3);
        result = BigInteger.fromString("12345678901234567890123");
        
        if (!value.equals(result))
        {
            fail("setBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.setBit(55);
        result = BigInteger.fromString("36028798253531858");
        
        if (!value.equals(result))
        {
            fail("setBit - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.setBit(55);
        result = BigInteger.fromString("12345678901234567890123");
        
        if (!value.equals(result))
        {
            fail("setBit - expected: " + result + " got: " + value);
        }
		trace("setBitTest OK");
    }
	
    private function testDivideAndRemainder()
    {
        var random = new SecureRandom();

        var n = BigInteger.fromNumbitsRandom(48, random);
        trace("n=" + Std.string(n));
		var qr = n.divideAndRemainder(n);
        if (!qr[0].equals(one) || !qr[1].equals(zero))
        {
            fail("testDivideAndRemainder - expected: 1/0 got: " + qr[0] + "/" + qr[1]);
        }
        qr = n.divideAndRemainder(one);
        if (!qr[0].equals(n) || !qr[1].equals(zero))
        {
            fail("testDivideAndRemainder - expected: " + n + "/0 got: " + qr[0] + "/" + qr[1]);
        }

        //for (int rep = 0; rep < 10; ++rep)
		for (rep in 0...10)
        {
            var a = BigInteger.fromLengthCertaintyRandom(100 - rep, 0, random);
            var b = BigInteger.fromLengthCertaintyRandom(100 + rep, 0, random);
            var c = BigInteger.fromLengthCertaintyRandom(10 + rep, 0, random);
            var d = a.multiply(b).add(c);
            var es = d.divideAndRemainder(a);

            if (!es[0].equals(b) || !es[1].equals(c))
            {
                fail("testDivideAndRemainder - expected: " + b + "/" + c + " got: " + qr[0] + "/" + qr[1]);
            }
        }
		trace("testDivideAndRemainder OK");
    }

    private function testModInverse()
    {
        var random = new SecureRandom();

        //for (int i = 0; i < 10; ++i)
		#if jssss
		trace("SKIPPING TEST WITH GENERATION OF PROBABLE PRIMES...");
		#else
		trace("test with probable primes");
		for (i in 0...10)
        {
			//trace("trying probable prime");
            var p = BigInteger.probablePrime(64, random);
			//trace("probable prime found:"+ Std.string(p));
            var q = BigInteger.fromNumbitsRandom(63, random).add(one);
			//trace("q=" + Std.string(q));
            var inv = q.modInverse(p);
			//trace("inv=" + Std.string(q));
            var inv2 = inv.modInverse(p);
			//trace("inv2=" + Std.string(q));

            if (!q.equals(inv2))
            {
				trace("FAILED modInverseWithProbablePrime #" + Std.string(i));
				trace("p=" + p.magnitude + " sign=" + p.sign);
				trace("q=" + q.magnitude + " sign=" + q.sign);
				trace(inv2.magnitude);
				trace("should be");
				trace(q.magnitude);
                fail("testModInverse failed symmetry test");
            }
			
            var check = q.multiply(inv).mod(p); 
            if (!one.equals(check))
            {
                fail("testModInverse - expected: 1  got: " + check);
            }
        }
		#end

        // ModInverse for powers of 2
        //for (int i = 1; i <= 128; ++i)
		var i = 0;
		while (i < 128)
		//for (i in 1...128)
        {
			i++;
			/*if (i == 33) {
				i = 65;
			}*/
			
            var m = one.shiftLeft(i);
			//m = BigInteger.fromString(m.toString());
            var d = BigInteger.fromNumbitsRandom(i, random).setBit(0);
			//d = BigInteger.fromString(d.toString());
			//if (i == 33) {
			//	m = BigInteger.fromString("8589934592");
			//	d = BigInteger.fromString("7123108205");
				
/*oingmodinverse
crypto.js:1897modInversePow2
crypto.js:1875pow=33
crypto.js:1878longValue()=7123108205
crypto.js:1879inv=5103030711200591973
crypto.js:2665m=8589934592
crypto.js:2666m.bitLength()=34
crypto.js:2667m.sign=1
crypto.js:2668m=[2,0]
crypto.js:889calcBitLen=33
crypto.js:2669d=7123108205
crypto.js:2670d.bitLength()=33
crypto.js:2671d.sign=1
crypto.js:2672d=[1,-1466826387]
crypto.js:889calcBitLen=33
crypto.js:2673x=4614074469
crypto.js:2674x.sign=1
crypto.js:2675x=[1,319107173]
crypto.js:889calcBitLen=33
crypto.js:2676check=4294967297
crypto.js:2677check.magnitude=[1,1]
crypto.js:2538FAIL: testModInverse(33 bits) - expected: 1  got: 4294967297*/
			//}
			//trace("doingmodinverse");
            var x = d.modInverse(m);
            var check = x.multiply(d).mod(m);
			/*if (i == 33) {
				trace("m=" + Std.string(m));
				trace("m.bitLength()=" + Std.string(m.bitLength()));
				trace("m.sign=" + Std.string(m.sign));
				trace("m=" + Std.string(m.magnitude));
				trace("d=" + Std.string(d));
				trace("d.bitLength()=" + Std.string(d.bitLength()));
				trace("d.sign=" + Std.string(d.sign));
				trace("d=" + Std.string(d.magnitude));
				trace("x=" + Std.string(x));
				trace("x.sign=" + Std.string(x.sign));
				trace("x=" + Std.string(x.magnitude));
				trace("check=" + Std.string(check));		
				trace("check.magnitude=" + Std.string(check.magnitude));		
				trace("IMASK=" +Std.string(BigInteger.IMASK));
				//throw "PAUSE";
			}*/
            if (!one.equals(check))
            {
				trace("m=" + Std.string(m));
				trace("m.bitLength()=" + Std.string(m.bitLength()));
				trace("m.sign=" + Std.string(m.sign));
				trace("m=" + Std.string(m.magnitude));
				trace("d=" + Std.string(d));
				trace("d.bitLength()=" + Std.string(d.bitLength()));
				trace("d.sign=" + Std.string(d.sign));
				trace("d=" + Std.string(d.magnitude));
				trace("x=" + Std.string(x));
				trace("x.sign=" + Std.string(x.sign));
				trace("x=" + Std.string(x.magnitude));
				trace("check=" + Std.string(check));
				trace("check.magnitude=" + Std.string(check.magnitude));
				
                fail("testModInverse("+Std.string(i)+" bits) - expected: 1  got: " + check);
                //trace("testModInverse("+Std.string(i)+" bits) - expected: 1  got: " + check);
            }
        }
		trace("testModInverse OK");
    }

    private function testNegate()
    {
        if (!zero.equals(zero.negate()))
        {
            fail("zero - negate falied");
        }
        if (!one.equals(one.negate().negate()))
        {
            fail("one - negate falied");
        }
        if (!two.equals(two.negate().negate()))
        {
            fail("two - negate falied");
        }
		trace("testNegate OK");
    }

    private function testNot()
    {
        //for (int i = -10; i <= 10; ++i)
		for (i in -10...10)
        {
            if(!BigInteger.valueOfInt(~i).equals(
                     BigInteger.valueOfInt(i).not()))
            {
                fail("Problem: ~" + i + " should be " + ~i);
            }
        }
		trace("testNot OK");
    }

    private function testOr()
    {
        for (i in -10...10) //(int i = -10; i <= 10; ++i)
        {
            for (j in -10...10) //for (int j = -10; j <= 10; ++j)
            {
                if (!BigInteger.valueOfInt(i | j).equals(
                    BigInteger.valueOfInt(i).or(BigInteger.valueOfInt(j))))
                {
                    fail("Problem: " + i + " OR " + j + " should be " + (i | j));
                }
            }
        }
		trace("testOr OK");
    }

    public function testPow()
    {
        if (!one.equals(zero.pow(0)))
        {
            fail("one pow equals failed");
        }
        if (!zero.equals(zero.pow(123)))
        {
            fail("zero pow equals failed");
        }
        if (!one.equals(one.pow(0)))
        {
            fail("one one equals failed");
        }
        if (!one.equals(one.pow(123)))
        {
            fail("1 123 equals failed");
        }

        if (!two.pow(147).equals(one.shiftLeft(147)))
        {
            fail("2 pow failed");
        }
        if (!one.shiftLeft(7).pow(11).equals(one.shiftLeft(77)))
        {
            fail("pow 2 pow failed");
        }

        var n = BigInteger.fromString("1234567890987654321");
        var result = one;

        //for (int i = 0; i < 10; ++i)
		for (i in 0...10)
        {
            try
            {
                BigInteger.valueOfInt(i).pow(-1);
                fail("expected ArithmeticException");
            }
            catch (/*ArithmeticException*/ e:Dynamic) {}

            if (!result.equals(n.pow(i)))
            {
                fail("mod pow equals failed");
            }

            result = result.multiply(n);
        }
		trace("testPow OK");
    }
	
    /*public function testToString()
    {
        var random = new SecureRandom();
        var trials = 256;

        var tests = new Array<BigInteger>(); // BigInteger2[trials];
		for (i in 0...trials) {
			tests.push(null);
		}
        //for (int i = 0; i < trials; ++i)
		for (i in 0...trials)
        {
            var len = random.nextInt(i + 1);
            tests[i] = BigInteger.fromNumbitsRandom(len, random);
        }

        //for (int radix = Character.MIN_RADIX; radix <= Character.MAX_RADIX; ++radix)
		for (radix in BigInteger.Character_MIN_RADIX...BigInteger.Character_MAX_RADIX)
        {
            //for (int i = 0; i < trials; ++i)
			for (i in 0...trials)
            {
                var n1 = tests[i];
                var s = n1.toStringRadix(radix);
                var n2 = BigInteger.fromStringRadix(s, radix);
                if (!n1.equals(n2))
                {
                    fail("testToStringRadix - radix:" + radix + ", n1:" + n1.toString(16) + ", n2:" + n2.toString(16));
                }
            }
        }
		trace("testToString OK");
    }*/

    private function xorTest()
    {
        var value = VALUE1.xor(VALUE2);
        var result = BigInteger.fromString("1234568704");
        
        if (!value.equals(result))
        {
            fail("xor - expected: " + result + " got: " + value);
        }
        
        value = VALUE1.xor(VALUE3);
        result = BigInteger.fromString("12345678901234567888921");
        
        if (!value.equals(result))
        {
            fail("xor - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.xor(VALUE1);
        result = BigInteger.fromString("12345678901234567888921");
        
        if (!value.equals(result))
        {
            fail("xor - expected: " + result + " got: " + value);
        }
        
        value = VALUE2.xor(BigInteger.fromString("-1"));
        result = BigInteger.fromString("-1234567891");
        
        if (!value.equals(result))
        {
            fail("xor - expected: " + result + " got: " + value);
        }
        
        value = VALUE3.xor(VALUE3);
        result = BigInteger.fromString("0");
        
        if (!value.equals(result))
        {
            fail("xor - expected: " + result + " got: " + value);
        }
		trace("xorTest OK");
    }
	
	
	
	
    public override function getName()
    {
        return "Big Integer Test";
    }

    public override function performTest() : Void {
		clearBitTest();
		flipBitTest();
		setBitTest();
		testDivideAndRemainder();
        testModInverse();
        testNegate();
        testNot();
        testOr();
        testPow();
		trace("SKIPPING testToString");//testToString();
		xorTest();
		
		var n1:BigInteger;
		var n2:BigInteger;
		var r1:BigInteger;
		// test division where the difference in bit length of the dividend and divisor is 32 bits 
        n1 = BigInteger.fromString("54975581388");
        n2 = BigInteger.fromString("10");
        r1 = n1.divide(n2);
        if (!(r1.toStringRadix(10) == "5497558138"))
        {
                fail("BigInteger: failed Divide Test");
        }

        // two's complement test
        var zeroBytes = BigInteger.ZERO.toByteArray();
        var oneBytes = BigInteger.ONE.toByteArray();
        var minusOneBytes = BigInteger.ONE.negate().toByteArray();
		
        var zero = BigInteger.fromBytes(zeroBytes);
		
        if (!zero.equals(BigInteger.ZERO))
        {
            fail("Failed constructing zero");
        }

        var one = BigInteger.fromBytes(oneBytes);
        if (!one.equals(BigInteger.ONE))
        {
            fail("Failed constructing one");
        }

        var minusOne = BigInteger.fromBytes(minusOneBytes);
        if (!minusOne.equals(BigInteger.ONE.negate()))
        {
            fail("Failed constructing minus one");
        }
    
        var random = new SecureRandom();
        var randomBytes = Bytes.alloc(100);// byte[100];
        //for (int i=0; i < 100; i++)
		
		/*
		for (i in 0...100)
        {
            random.nextBytes(randomBytes);
            var bcInt = BigInteger.fromBytes(randomBytes);
            var bcInt2 = BigInteger.fromBytes(bcInt.toByteArray());
            if (!bcInt.equals(bcInt2))
            {
                fail("Failed constructing random value " + i);
            }
            
//            java.math.BigInteger jdkInt = new java.math.BigInteger(randomBytes);
//            byte[] bcBytes = bcInt.toByteArray();
//            byte[] jdkBytes = jdkInt.toByteArray();
//            if (!arrayEquals(bcBytes, jdkBytes))
//            {
//                fail(""Failed constructing random value " + i);
//            }
        }
		*/
	}
	
	/**
	 * test:
	 * mod-in:
[-1198335509,-604227613,-1759154728,-1512893899,886173751,640173891,-574177734,1889459049,1875119229,-1875978236,-957421776,-287058510,200719757,-2019387775,1015534515,-862095033,]
mod-out:
[1932308834,459260903,1324239487,2043172521,1924726488,1233947460,1103946682,-808117877,-1099024647,1771056324,232443610,-2004171758,638095624,-1687958889,1708623342,2053928777,]


remainderArr(out x, in y)
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1932308834,459260903,1324239487,2043172521,1924726488,1233947460,1103946682,-808117877,-1099024647,1771056324,232443610,-2004171758,638095624,-1687958889,1708623342,2053928777,]
[-1198335509,-604227613,-1759154728,-1512893899,886173751,640173891,-574177734,1889459049,1875119229,-1875978236,-957421776,-287058510,200719757,-2019387775,1015534515,-862095033,]


	 * 
	 */
	
}