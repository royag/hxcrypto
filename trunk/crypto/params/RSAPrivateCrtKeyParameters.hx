package crypto.params;
import crypto.math.BigInteger;

/**
 * ...
 * @author test
 */
class RSAPrivateCrtKeyParameters extends RSAKeyParameters
{
    private var   e:BigInteger;
    private var   p:BigInteger;
    private var   q:BigInteger;
    private var   dP:BigInteger;
    private var   dQ:BigInteger;
    private var   qInv:BigInteger;

    /**
     * 
     */
    public function new(
          modulus:BigInteger,
          publicExponent:BigInteger,
          privateExponent:BigInteger,
          p:BigInteger,
          q:BigInteger,
          dP:BigInteger,
          dQ:BigInteger,
          qInv:BigInteger)
    {
        super(true, modulus, privateExponent);

        this.e = publicExponent;
        this.p = p;
        this.q = q;
        this.dP = dP;
        this.dQ = dQ;
        this.qInv = qInv;
    }

    public function getPublicExponent()
    {
        return e;
    }

    public function getP()
    {
        return p;
    }

    public function getQ()
    {
        return q;
    }

    public function getDP()
    {
        return dP;
    }

    public function getDQ()
    {
        return dQ;
    }

    public function getQInv()
    {
        return qInv;
    }
	
}