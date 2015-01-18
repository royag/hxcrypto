package crypto.params;

import crypto.math.BigInteger;
/**
 * ...
 * @author test
 */
class RSAKeyParameters extends AsymmetricKeyParameter
{
    private var      modulus:BigInteger;
    private var      exponent:BigInteger;

    public function new(
        isPrivate:Bool     ,
        modulus:BigInteger  ,
        exponent:BigInteger  )
    {
        super(isPrivate);
		//trace("modulus=" + Std.string(modulus));
		//trace("exponent=" + Std.string(exponent));

        this.modulus = modulus;
        this.exponent = exponent;
    }   

    public function getModulus():BigInteger
    {
        return modulus;
    }

    public function getExponent():BigInteger
    {
        return exponent;
    }
	
}