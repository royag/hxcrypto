package crypto.test ;

import crypto.Array2;
import crypto.engines.AESFastEngine;
import crypto.BufferedBlockCipher;
import crypto.math.BigInteger;
import crypto.test.AESFastTest;
import crypto.test.BigIntegerTest;
import crypto.test.BlockCipherMonteCarloTest;
import haxe.crypto.BaseCode;
import haxe.Log;
//import haxe.BaseCode;
import haxe.io.Bytes;
//import haxe.Int64;
import crypto.math.Int64;

import crypto.AsymmetricBlockCipher;
import crypto.params.RSAPrivateCrtKeyParameters;
import crypto.engines.RSACoreEngine;
import crypto.engines.RSAEngine;
import crypto.test.RSATest;

import crypto.Digest;
import crypto.ExtendedDigest;
import crypto.digests.GeneralDigestImpl;
import crypto.digests.IGeneralDigest;
import crypto.util.Pack;
import crypto.digests.SHA1Digest;
import crypto.test.DigestTest;
import crypto.test.SHA1DigestTest;
import crypto.digests.SHA256Digest;
import crypto.test.SHA256DigestTest;
#if js
import js.Browser;
#end

/**
 * ...
 * @author test
 */

class Main 
{
	
	public static function runTests() {
		testSHA1();
		testSHA256();
		testAES();
		testBigInteger();
		testRSA();
		//test1();
	}
	
	public static function main() {
		#if js
		Log.trace = myTrace;
		Browser.window.setTimeout(function() {
			runTests();
		}, 500);
		#else
		runTests();
		#end
		
		//trace("Test");
	}
	
	#if js
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		var hxTrace = Browser.document.getElementById("haxe:trace");
		hxTrace.innerHTML = hxTrace.innerHTML + "<br/>" + Std.string(v);
	}
	#end
	
	static function testAES() {
		trace("-------- AES test --------");
		var aesTest = new AESFastTest();
		aesTest.go();
		
	}
	
	static function testBigInteger() {
		trace("-------- BigInteger test --------");
		BigInteger.initSTATIC();
		var bigIntegerTest = new BigIntegerTest();
		bigIntegerTest.performTest();
	}
	
	static function testRSA() {
		trace("-------- RSA test --------");
		BigInteger.initSTATIC();
		var rsaTest = new RSATest();
		rsaTest.rawTest();
	}
	
	static function testSHA1() {
		var t = new SHA1DigestTest();
		t.performTest();
	}

	static function testSHA256() {
		var t = new SHA256DigestTest();
		t.performTest();
	}
	
	
	/*public static function main() {
		trace("HEISANN");
		trace("DFSDFSDFSDFSDFSD");
		throw "UGH";
		//testAES();
		//testBigInteger();
		//testRSA();
		//testSHA1();
		//testSHA256();
	}*/
	
	//static function sometest() {
	//	trace("MHM");
		//BigInteger.initSTATIC();
		//var t = new RSATest();
		//t.rawTest();
		//test2();
		
		
		/*
        var magIn = [-9472224,1769152628,1751457908,1768776992,1718579744,1634495520,1735356260,544040302];
        var mag1 = [17];
        var mag2 = [-1302736170,-433608856,-917773471,1690491388,2044295851,-1840049138,1542551377,427241942,-145486555,166181375,-301305690,-496150807,758046079,-2052347818,11964553,-211850277,-205350688,1480741725,-1626976661,59886461,812517933,549773236,-407594346,1086188070,-1056254308,1057292412,-497992466,1154474009,-1729746068,909628412,59836315,653145813];

        var i = BigInteger.fromSignumMag(1, magIn);
        var m1 = BigInteger.fromSignumMag(1, mag1);
        var m2 = BigInteger.fromSignumMag(1, mag2);
        var res = i.modPow(m1, m2);
        trace("RESULT:");
        trace(res.magnitude);
		
		var expRes = [1466572680, 1580474386, -1937087136, -1749385845, -1262030415, -2060236593, 732526231, 498974460, 882354683, 398066649, 1596521177, 306697976, -339450886, -1965385905, 256780438, 358983482, 1185178934, -1643669300, -1082616885, -1694849084, 650924010, 1866636903, -1239393432, 714617139, 2133149949, 375139799, -1084533570, 1486110781, 1855939203, -429936332, -851015745, -2030477702 ];
		
		if (res.magnitude.length != expRes.length) {
			throw "WRONG LEN";
		}
		for (i in 0...expRes.length) {
			if (expRes[i] != res.magnitude[i]) {
				
				trace("EXPECTED: ");
				trace(expRes);
				trace("GOT:");
				trace(res.magnitude);
				
				throw "ERR";
			}
			
		}*/
		
		
		//[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1932308834,459260903,1324239487,2043172521,1924726488,1233947460,1103946682,-808117877,-1099024647,1771056324,232443610,-2004171758,638095624,-1687958889,1708623342,2053928777,]
		/*var n:Array<Int> = [ -1198335509, -604227613, -1759154728, -1512893899, 886173751, 640173891, -574177734, 1889459049, 1875119229, -1875978236, -957421776, -287058510, 200719757, -2019387775, 1015534515, -862095033];
		var o = intArray(n.length);
		arraycopy(n, 0, o, 0, n.length);
		BigInteger.remainderArr(o, n);
		trace(o);
*/
		
		//test2();
		/*var b = Bytes.alloc(4);
		b.set(0, -1);
		b.set(1, -100);
		b.set(2, 100);
		b.set(3, 200);
		for (i in 0...b.length) {
			trace(b.get(i) & 0xFF);
		}*/
		//trace("HEY");
	//}
	
	static function test2() {
		//var a = Int
		trace("TEST2");
		//BigInteger.initSTATIC();
		//trace("inited");
		var test = new BigIntegerTest();
		test.performTest();
	}
	
	static function test1() 
	{
		/*trace("hello");
		var engine = new AESFastEngine();
		for (i in 0...S.length) {
			trace(S.get(i));
		}
		var a = 4;
		a |= 5;
		
		var t = new Array2<Int>(5);
		t.set(0, 0, 100);
		t.set(4, 4, 200);
		trace(t.get(0, 0));
		trace(t.get(4, 4));
		
		//var bc = new BufferedBlockCipher(null);
		
		var HEX = "0123456789ABCDEF";
		var bstr = BaseCode.decode("01FF02FE", HEX);
		var b = Bytes.ofString(bstr);
		trace(b.get(0));
		trace(b.get(1));
		trace(b.get(2));
		trace(b.get(3));*/
		//var t = new AESFastTest();
		//t.go();
		BigInteger.initSTATIC();
		var b = new BigInteger();

		var ex1024_RSA = "13144131834269512219260941993714669605006625743172006030529504645527800951523697620149903055663251854220067020503783524785523675819158836547734770656069477";
		
		b.init_sval(ex1024_RSA);
		var b2 = new BigInteger();
		b2.init_sval("534789527589723589734952734592837459283475928347592837459283475");
		
		trace(b.magnitude);
		//throw "TEST";
		trace(b2.magnitude);		
		
		trace("BEFORE MULTIPLY - VAL = " + Std.string(b2.magnitude));		
		//throw "UGH";
		BigInteger.mycnt = 1000;
		var b3 = b.multiply(b2);
		//var b3 = b2.xor(b);
		
		//trace("PRIME ? " + Std.string(b.isProbablePrime(50))); // too much
		trace("PRIME ? " + Std.string(BigInteger.fromString("3").isProbablePrime(50)));
		
		trace(b.magnitude);
		trace(b2.magnitude);
		trace(b3.magnitude); // WRONG
		
		trace("----------");
		//trace(b);
		//trace(b2);
		//trace(b3);
		// fails in Safari:
		//var n = BigInteger.fromString("3783524785523675819158836547734770656069477");
		//var n2 = BigInteger.fromString("37835247855236758191588365477347706560694772");

		
		/*var n = BigInteger.fromString("3783524785523675819158836547734770656069477");
		trace(n.magnitude);
		var n2 = BigInteger.fromString("37835247855236758191588365477347706560694772");
		var mulres = n.multiply(n2);
		trace("MULRES=" + Std.string(mulres.magnitude));
		*/
		
		//var a = Int64.ofInt(3556362740);
		//var a2 = Int64.ofInt(3362113381);
		//var ares = Int64.mul(a, a2);
		//trace(Std.string(a) + "x" + Std.string(s2) + "=" + Std.string(ares));
		
		var a = Int64.make(0, -738604556);
		var a2 = Int64.make(0, -932853915);
		var ares = Int64.mul(a, a2);
		trace("------------");
		trace(Std.string(a) + " x " + Std.string(a2) + "=" + Std.string(ares));
		trace("------------");
		//trace(b);//trace(b3);
		trace("HEISANN");
		/*
		 * should be:
1675
-1565779459
-42291850
-775802930
1120886565
-521128842
-419665217
-1577094214
2147183463
129242195
887798890
-1390767702
-1303085522		 * */
		
		//b.init_signum_mag(1, [287445236,-1071401254]);
		//trace(
		//trace(b.toString());
		trace("YO");
	}

	
	
    static inline function chr(i:Int) {
		return String.fromCharCode(i);
	}
	
	static var S = Bytes.ofString(chr(99) + chr(124) + chr(199) + chr(7) + chr(0) + chr(255) + chr(13));

	static var T0 = [0xa56363c6, 0x847c7cf8, 0x997777ee, 0x8d7b7bf6, 0x0df2f2ff];
	
	static function intArray(len:Int, ?fillnum : Int) : Array<Int> {
		if (fillnum == null) {
			fillnum = 0;
		}
		var b = new Array<Int>();
		for (i in 0...len) {
			b[i] = fillnum;
		}
		return b;
	}	
	static function arraycopy(src:Array<Int>, srcpos:Int, dst:Array<Int>, dstpos:Int, len:Int) {
		for (i in 0...len) {
			dst[i + dstpos] = src[i + srcpos];
		}
	}	
	
	static function test3() {
		//p=[-773199878,460632401] sign=1
		//crypto.js:2895q=[1773918905,-688553461] sign=1
		var pmag = [ -773199878, 460632401];
		var qmag = [1773918905, -688553461];
		var p = BigInteger.fromSignumMag(1, pmag);
		var q = BigInteger.fromSignumMag(1, qmag);
		//var inv = q.modInverse(p);
		var inv = BigInteger.fromSignumMag(1, [-1874410283,1741879142]);
		trace("INV: " + inv.magnitude);
        var inv2 = inv.modInverse(p);
        if (!q.equals(inv2)) {
			trace("ERROR: expected:");
			trace(q.magnitude);
			trace("got");
			trace(inv2.magnitude);
		} else {
			trace("FINE");
		}
	}
	
	static function test4() {
		var a = BigInteger.fromSignumMag(1, [1574036392]);
		var b = BigInteger.fromSignumMag(-1, [ -1120314150]);
		var c = a.subtract(b);
		trace(c.magnitude);
		trace("should be");
		trace([1, 453722242]);
                trace("b neg=");
                trace(b.negate().magnitude);
		
	}

}
