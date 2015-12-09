package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.Spinner;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class FacebookAuthForm extends SizableView
	{
		protected var bg:Bitmap;
		protected var spinner:Spinner;
		public var stageWebView:StageWebView;
		
		public var message:String;
		public var bitmapData:BitmapData;
		protected var tf:TextField;
		
		public function FacebookAuthForm(message:String, bitmapData:BitmapData){
			this.message = message;
			this.bitmapData = bitmapData;
			
			bg = new Bitmap(SharedBitmaps.white);
			addChild(bg);
			
			spinner = new Spinner();
			addChild(spinner);
			
			tf = TextFields.getRegular(DeviceUtils.fontSize * .65, 0x0, "left");
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			stageWebView = new StageWebView();
		}
		
		public function set text(value:String):void {
			addChild(tf);
			tf.text = value;
			updateLayout();
		}
		
		public function initWebView():void {
			var pt:Point = localToGlobal(new Point());
			stageWebView.viewPort = new Rectangle(pt.x - viewWidth, pt.y - this.y, viewWidth, viewHeight);
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			spinner.x = viewWidth - spinner.width >> 1;
			spinner.y = viewHeight - spinner.height >> 1;
			
			tf.width = viewWidth * .65;
			tf.y = spinner.y + spinner.height + 10;
			tf.x = viewWidth - tf.textWidth >> 1;
		}
		
		override public function destroy():void {
			stageWebView.stage = null;
		}
	}
}