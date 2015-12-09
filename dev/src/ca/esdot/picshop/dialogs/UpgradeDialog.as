package ca.esdot.picshop.dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.ColorPanel;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.UpgradeDialogContent;

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
		
		override protected function createChildren():void {
			content = new swc.UpgradeDialogContent();
			content.scaleX = content.scaleY = DeviceUtils.screenScale;
			addChild(content);
			
			ColorTheme.colorTextfield(content);
			
			super.createChildren();
			
			_viewWidth = content.width + DeviceUtils.hitSize + padding * 2;
			_viewHeight = topDivider.y + content.height + buttonHeight + padding * 4;
			updateLayout();
		}
		override public function updateLayout():void {
			super.updateLayout();
				
			content.scaleY = content.scaleX = DeviceUtils.screenScale;
			content.y = topDivider.y + padding;
			content.x = titleText.x;
		}
	}
}