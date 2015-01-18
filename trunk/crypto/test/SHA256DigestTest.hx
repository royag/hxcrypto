package crypto.test;

import crypto.digests.SHA256Digest;

class SHA256DigestTest extends DigestTest
{

	private static var messages =
    [
        "",
        "a",
        "abc",
        "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
    ];
    
    private static var digests =
    [
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
        "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
    ];
    
    // 1 million 'a'
    static private var  million_a_digest = "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0";

    public function new()
    {
        super(new SHA256Digest(), messages, digests);
    }

    public override function performTest()
    {
        super.performTest();
        
        millionATest(million_a_digest);
    }

    private override function cloneDigest(digest:Digest):Digest
    {
		return new SHA256Digest().initAsCopySHA256(cast(digest,SHA256Digest));
    }	
    
    /*public static void main(
        String[]    args)
    {
        runTest(new SHA256DigestTest());
    }*/
	
}