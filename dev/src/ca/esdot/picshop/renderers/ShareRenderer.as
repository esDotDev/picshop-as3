package ca.esdot.picshop.renderers
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import swc.ReviewAppRenderer;
	
	public class ShareRenderer extends Sprite
	{
		public var bg:Bitmap;
		
		public function ShareRenderer(){
			var viewAssets:swc.ShareRenderer = new swc.ShareRenderer();
			addChild(viewAssets);
			
			viewAssets.twitterButton.addEventListener(MouseEvent.CLICK, onTwitterClick, false, 0, true);
			viewAssets.facebookButton.addEventListener(MouseEvent.CLICK, onFacebookClick, false, 0, true);
		}	
		
		protected function onFacebookClick(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.facebook.com/sharer/sharer.php?u=http://app.lk/picshop"));
		}
		
		protected function onTwitterClick(event:MouseEvent):void {
			var msg:String = "PicShop is an amazing photo editor! Check it out @ http://app.lk/picshop";
			
			if(GoViral.isSupported() && GoViral.goViral.isTweetSheetAvailable()){
				GoViral.goViral.showTweetSheet(msg + " #picshop");
			} else {
				navigateToURL(new URLRequest("https://twitter.com/intent/tweet?text="+msg+"&hashtags=picshop"));
			}
			
		}
	}
}