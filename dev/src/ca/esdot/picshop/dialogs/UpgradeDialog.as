package ca.esdot.picshop.dialogs
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.ColorPanel;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import fl.motion.easing.Back;
	
	import swc.UpgradeDialogContent;
	import swc.UpgradeDialogLandscape;

	public class UpgradeDialog extends TitleDialog
	{
		public var content:Sprite;
		
		public function UpgradeDialog() {
			super(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Upgrade to Full Version?");
			if(DeviceUtils.onAndroid || DeviceUtils.onIOS || DeviceUtils.onBB10){
				setButtons([Strings.CANCEL, Strings.UPGRADE, Strings.RESTORE]);
			} else {
				setButtons([Strings.CANCEL, Strings.UPGRADE]);
			}
		}
		
		override public function transitionIn():void {
			super.transitionIn();
			new GTween(this, 1, {y: y}, {ease: Back.easeOut, delay: .35});
			y = MainView.instance.viewHeight;
			setTimeout(function(){
				y -= 1;
			}, 250);
				
		}
		
		override protected function createChildren():void {
			
			super.createChildren();
			var vtPad:Number = padding * 4;
			var hzPad:Number = padding * 2;
			//Add content from SWC, scale as large as possible.
			content = new swc.UpgradeDialogContent();
			if(!MainView.instance.isPortrait){
				content = new swc.UpgradeDialogLandscape();
			}
			ColorTheme.colorTextfield(content);
			
			var maxH:Number = MainView.instance.viewHeight;
			maxH -= (topDivider.y + buttonHeight + vtPad);
			var maxW:Number = MainView.instance.viewWidth - hzPad * 4;
			
			//Scale by width first
			content.width = maxW;
			content.scaleY = content.scaleX;
			if(content.height > maxH){//Respect max height
				content.height = maxH;
				content.scaleX = content.scaleY;
			} 
			addChild(content);
			//Calculate new view size
			_viewWidth = content.width;
			_viewHeight = topDivider.y + content.height + buttonHeight;
			updateLayout();
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			if(content){
				content.y = topDivider.y;
				content.x = 0;
			}
			
		}
	}
}