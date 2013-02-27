package crypto.test;

import crypto.digests.SHA1Digest;

class SHA1DigestTest extends DigestTest
{

	private static var messages =
    [
         "",
         "a",
         "abc",
         "abcdefghijklmnopqrstuvwxyz"
    ];
    
    private static var digests =
    [
        "da39a3ee5e6b4b0d3255bfef95601890afd80709",
        "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8",
        "a9993e364706816aba3e25717850c26c9cd0d89d",
        "32d10c7b8cf96570ca04ce37f2a19d84240d3a89"
    ];
    
    public function new()
    {
        super(new SHA1Digest(), messages, digests);
    }

    private override function cloneDigest(digest:Digest):Digest
    {
        //return new SHA1Digest((SHA1Digest)digest);
	return new SHA1Digest().initAsCopySHA1(cast(digest,SHA1Digest));
    }
    
    /*public static void main(
        String[]    args)
    {
        runTest(new SHA1DigestTest());
    }*/
	
}