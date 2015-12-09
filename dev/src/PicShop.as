package
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.utils.ColorUtils;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainContext;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.colors.BgType;
	import ca.esdot.picshop.data.colors.ColorTheme;
	
	public class PicShop extends Sprite
	{
		public static var FULL_VERSION:Boolean = true;
		
		protected var mainContext:MainContext;
		protected var mainView:MainView;
		public static var stage:Stage;
		
		private var tf:TextField;
		protected var invokeUrl:String;
		
		public static function set highQuality(value:Boolean):void {
			stage.quality = (value)? StageQuality.HIGH : StageQuality.LOW;
		}
		
		public function PicShop() {
			super();
			PicShop.stage = stage;
			
			trace(NativeApplication.nativeApplication.runtimeVersion);
			
			
			BgType.DEFAULT = DeviceUtils.onIOS? BgType.WHITE_GRID: BgType.BLACK_GRID;
			ColorTheme.bgType = BgType.DEFAULT;
			
			stage.color = ColorTheme.bgColor;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.quality = DeviceUtils.onAndroid? StageQuality.LOW : StageQuality.HIGH;
			
			var hsv:Object = ColorUtils.rgb2hsv(0xfee89c);
			var color:uint = ColorUtils.hsv2rgb(47, 38.6, 99.6);
			
			if(GoViral.isSupported()){
				GoViral.create();
			}
			
			setTimeout(function(){
				mainView = new MainView(stage);
				mainContext = new MainContext(mainView);
				addChild(mainView);
				
				mainContext.openImageUrl(invokeUrl);
				/*				
				var stickerContainer:Sprite = new swc.hats.AllHats();
				var stickerList:Array = [];
				//Apply colorTransform
				var ct:ColorTransform = new ColorTransform();
				ct.color = 0xFF0000;
				while(stickerContainer.numChildren){
					stickerList.push(stickerContainer.removeChildAt(0));
				}
				var tileDialog:TileDialog = new TileDialog(stickerList);
				tileDialog.setSize(500, 500);
				DialogManager.addDialog(tileDialog);

				var optionsDialog:OptionsDialog = new OptionsDialog(500, 500, "Hello", ["1sdsadad", "2asdsadsa", "3asdasdasdsa"]);
				optionsDialog.dataProvider = ["1sdsadad", "2asdsadsa", "3asdasdasdsa"];
				optionsDialog.setButtons(["Cancel"]);
				
				DialogManager.addDialog(optionsDialog);
				
				setTimeout(function(){
					trace("DESTROY");
					DialogManager.removeDialogs();
				}, 2000);
				*/
			}, 250);
			//NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			
		}
		
		protected function onInvoke(event:*):void {
			trace(event.arguments);
		}
		
		protected function openInvokeUrl():void {
			if(!mainContext || !invokeUrl){ return; }
			mainContext.openImageUrl(invokeUrl);
		}

		
	}
}