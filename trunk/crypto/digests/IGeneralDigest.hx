package crypto.digests;
import crypto.ExtendedDigest;

import haxe.io.Bytes;
import crypto.math.Int64;

interface IGeneralDigest extends ExtendedDigest
{

	//private function initAsCopy(t:GeneralDigestImpl) : Void;

    public function updateOne(
        inByte:Int):Void;

    public function update(
		inBytes:Bytes,
        inOff:Int,
		len:Int):Void;
		
    public function finish():Void;

    public function reset():Void;

    public function getByteLength():Int;
    
    function processWord(inBytes:Bytes, inOff:Int):Void;

    function processLength(bitLength:Int64):Void;

    function processBlock():Void;
	
}