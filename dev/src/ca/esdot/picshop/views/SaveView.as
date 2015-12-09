package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.menus.SaveMenu;
	
	import fl.motion.easing.Back;
	
	public class SaveView extends SizableView
	{
		public var bottomMenu:SaveMenu;
		public var twitterView:TwitterAuthForm;
		
		public var currentView:DisplayObject;
		
		public var image:Image;
		protected var tween:GTween;
		private var inTransition:Boolean;
		
		public function SaveView() {
			bottomMenu = new SaveMenu();
			addChild(bottomMenu);
			
			image = new Image();
			image.clipEdges = false;
			image.centerImage = true;
			
			currentView = image;
		}
		
		public function set preview(value:BitmapData):void {
			image.bitmapData = value;
		}
		
		override public function transitionIn():void {
			if(!image.bitmapData){ return; }
			
			inTransition = true;
			
			var y:int  = (viewHeight - bottomMenu.height) - image.height >> 1;
			new GTween(image, TweenConstants.NORMAL, {y:0}, {ease: Back.easeOut, onComplete: onTransitionInComplete});
			image.y = viewHeight;
			addChildAt(image, 0);
		}
		
		protected function onTransitionInComplete(tween:GTween):void {
			inTransition = false;
		}
		
		override public function updateLayout():void {
			bottomMenu.y = viewHeight - bottomMenu.height;
			
			if(DeviceUtils.isTablet){
				if(isPortrait){
					bottomMenu.setSize(viewWidth, viewHeight / 6);
				} else {
					bottomMenu.setSize(viewWidth, viewHeight / 4.5);
				}
			} else {
				if(isPortrait){
					bottomMenu.setSize(viewWidth, viewHeight / 5);
				} else {
					bottomMenu.setSize(viewWidth, viewHeight / 3);
				}
			}
			
			
			if(image.bitmapData){
				var height:int = viewHeight - bottomMenu.height - 10;
				image.setSize(viewWidth, height);
				if(!inTransition){
					image.x = 0;
					image.y = 0;//(viewHeight - bottomMenu.height) - image.height >> 1;
				}
				
			}
		}
	}
}