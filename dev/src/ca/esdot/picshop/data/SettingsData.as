package ca.esdot.picshop.data
{
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.BgType;

	[RemoteClass]
	public class SettingsData
	{
		public var accentColor:Number = AccentColors.DEFAULT;
		public var bgType:String = BgType.DEFAULT;
		
		public var numStartups:int = 0;
		public var numOpenImage:int = 0;
		public var numSaves:int = 0;
		public var numUndo:int = 0;
		public var numSettingsOpened:int = 0;
		protected var _numFrameshopPrompts:int = 0;
		
		public var versionHash:Object = {};
		
		public var isPromo:Boolean = false;
		
		
		public var isAppLocked:Boolean = true;
		
		public var reviewAccepted:Boolean = false;
		
		public var t1:String = "";
		public var t2:String = "";
		public var f1:String = "";
		public var f2:String = "";
		
		
		/**
		 * ADDED IN v3.0
		 */
		protected var _unlockedFeatures:Object = {};
		protected var _numCoins:int = 0;
		protected var _userId:String;
		
		public function get userId():String {
			if(_userId == null){
				_userId = "user" + ((Math.random() * int.MAX_VALUE)|0) + "@picshop";
			}
			return _userId;
		}
		
		public function get numFrameshopPrompts():int {
			return _numFrameshopPrompts;
		}

		public function set numFrameshopPrompts(value:int):void {
			_numFrameshopPrompts = isNaN(value)? 0 : value;
		}

		public function get unlockedFeatures():Object { return _unlockedFeatures; }
		public function set unlockedFeatures(value:Object):void {
			//Don't allow it to be null (for Backwards Compatability)
			if(!value){ value = {}; } 
			_unlockedFeatures = value;
		}

		public function get numCoins():int { return _numCoins; }
		public function set numCoins(value:int):void {
			//Don't allow it to be invalid (for Backwards Compatability)
			if(value < 0 || isNaN(value)){ value = 0; }  	
			_numCoins = value;
		}


	}
}