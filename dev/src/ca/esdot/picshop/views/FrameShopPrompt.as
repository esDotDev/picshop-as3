package ca.esdot.picshop.views
{
	import com.google.analytics.v4.GoogleAnalyticsAPI;
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.net.AnalyticsTracker;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import fl.motion.easing.Back;
	
	import org.osflash.signals.Signal;
	
	import swc.FrameShopPromptBlack;
	import swc.FrameShopPromptWhite;
	
	public class FrameShopPrompt extends SizableView
	{
		protected var underlay:BitmapSprite;
		protected var prompt:MovieClip;
		public var downloadClicked:Signal;
		
		public function FrameShopPrompt(){
			underlay = new BitmapSprite(SharedBitmaps.bgColor);
			underlay.alpha = .8;
			addChild(underlay);
			
			prompt = (ColorTheme.whiteMode)? new swc.FrameShopPromptWhite() : new swc.FrameShopPromptBlack();
			prompt.closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClicked, false, 0, true);
			prompt.downloadButton.addEventListener(MouseEvent.CLICK, onDownloadClicked, false, 0, true);
			addChild(prompt);
			
			downloadClicked = new Signal();
		}
		
		override public function transitionIn():void {
			new GTween(underlay, .5, {alpha: underlay.alpha}); 
			underlay.alpha = 0;
			
			new GTween(prompt, 1, {y: prompt.y}, {ease: Back.easeOut, delay: .35});
			prompt.y = -prompt.height;
			
		}
		
		protected function onCloseButtonClicked(event:MouseEvent):void {
			AnalyticsManager.frameShopDownload(false);
			close();	
		}
		
		protected function onDownloadClicked(event:MouseEvent):void {
			AnalyticsManager.frameShopDownload(true);
			downloadFrameshop();
			close();	
		}
		
		protected function downloadFrameshop():void {
			downloadClicked.dispatch();
		}
		
		protected function close():void {
			//removeChildren();
			if(parent){ parent.removeChild(this); }
		}
		
		override public function updateLayout():void {
			
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			var width:int = Capabilities.screenDPI * 4;
			if(width > viewWidth * .9){
				width = viewWidth * .9;
			}
			prompt.width = width;
			prompt.scaleY = prompt.scaleX;
			
			if(prompt.height > viewHeight * .95){
				prompt.height = viewHeight * .95;
				prompt.scaleX = prompt.scaleY;
			}
			
			prompt.x = viewWidth - prompt.width >> 1;
			prompt.y = viewHeight - prompt.height >> 1;
			
		}
	}
}