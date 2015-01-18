package ;


class CryptoUtil
{

	function new() 
	{
		
	}
	
	public static function getInstance() {
		// TODO: return platform-specific implementation by conditional compilation
		return new CryptoUtil();
	}
	
}