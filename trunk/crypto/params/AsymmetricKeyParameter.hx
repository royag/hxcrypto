package crypto.params;
import crypto.CipherParameters;

/**
 * ...
 * @author test
 */
class AsymmetricKeyParameter implements CipherParameters
{
	var privateKey:Bool;

    public function new(
        privateKey:Bool)
    {
        this.privateKey = privateKey;
    }

    public function isPrivate():Bool
    {
        return privateKey;
    }
}