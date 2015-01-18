package crypto;
import haxe.io.Bytes;

/**
 * ...
 * @author test
 */

class KeyParameter implements CipherParameters
{

	var key:Bytes;
	
	public function new(key:Bytes) 
	{
		// Does this make a copy or not ?
		
		//trace("new KeyParameter with key:");
		//trace(key);
		this.key = Bytes.ofData(key.getData()); // new Bytes(key.length, key.getData());
	}
	
	public function getKey() : Bytes {
		return key;
	}
	
	
	/*
private byte[]  key;

    public KeyParameter(
        byte[]  key)
    {
        this(key, 0, key.length);
    }

    public KeyParameter(
        byte[]  key,
        int     keyOff,
        int     keyLen)
    {
        this.key = new byte[keyLen];

        System.arraycopy(key, keyOff, this.key, 0, keyLen);
    }

    public byte[] getKey()
    {
        return key;
    }	 * 
	 */ 
}