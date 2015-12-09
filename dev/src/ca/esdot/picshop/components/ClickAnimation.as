package ca.esdot.picshop.components
{
	import ca.esdot.lib.display.SpriteSheetClip;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.data.colors.AccentColors;
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	public class ClickAnimation extends Sprite
	{
		[Embed("/assets/TouchAnimation.png")]
		public static var TouchAnimationSheet:Class;
		
		[Embed("/assets/TouchAnimation.json", mimeType="application/octet-stream")]
		public static var TouchAnimationData:Class;

		public var spriteSheet:SpriteSheetClip;
		
		public function ClickAnimation(play:Boolean = false) {
			
			spriteSheet = new SpriteSheetClip(TouchAnimationSheet, TouchAnimationData);
			spriteSheet.scaleX = spriteSheet.scaleY = DeviceUtils.screenScale * .65;
			spriteSheet.x = -(spriteSheet.frameWidth * spriteSheet.scaleX)/2;
			spriteSheet.y = -(spriteSheet.frameHeight * spriteSheet.scaleX)/2;
			
			var ct:ColorTransform =  new ColorTransform();
			ct.color = AccentColors.currentColor;
			spriteSheet.transform.colorTransform = ct;
			
			if(play){
				spriteSheet.gotoAndPlay(1);
			} else {
				spriteSheet.gotoAndStop(1);
			}
			addChild(spriteSheet);
			
			mouseEnabled = mouseChildren = false;
		}
	}
}