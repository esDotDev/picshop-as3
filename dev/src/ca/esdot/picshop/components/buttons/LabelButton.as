package ca.esdot.picshop.components.buttons
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class LabelButton extends BaseButton
	{	
		public var divider:Bitmap;
		public var labelText:TextField;
		
		protected var _label:String;
		protected var _icon:DisplayObject;
		
		public var iconScale:Number = .4;
		
		
		public function LabelButton(label:String = "", icon:DisplayObject = null) {
			_label = label;
			super();
			if(icon is Bitmap){ (icon as Bitmap).smoothing = true; }
			this.icon = icon;
		}
		
		public function get icon():DisplayObject { return _icon; } 
		public function set icon(value:DisplayObject):void {
			if(_icon && contains(_icon)){
				removeChild(_icon);
			}
			_icon = value;
			if(_icon is Bitmap){
				(_icon as Bitmap).smoothing = true;
			}
			if(_icon){
				addChild(_icon);
			}
		}
		
		override protected function createChildren():void {
			
			super.createChildren();
			
			labelText = TextFields.getRegular(DeviceUtils.fontSize * .75, ColorTheme.textColor, "center");
			labelText.multiline = false;
			labelText.wordWrap = false;
			labelText.height = 20;
			this.label = label;
			ColorTheme.colorTextfield(labelText);
			
			divider = new Bitmap(SharedBitmaps.backgroundAccent);
			divider.visible = false;
			addChild(divider);
		}
		
		override public function destroy():void {
			super.destroy();
			ColorTheme.removeSprite(labelText);
		}
		
		public function get label():String { return _label || ""; }
		public function set label(value:String):void {
			if(value && value != ""){
				labelText.text = value;
				if(!contains(labelText)){
					addChild(labelText);
				}
			} else {
				if(contains(labelText)){
					removeChild(labelText);
				}
			}
			_label = value;
		}
		
		public function set labelColor(value:Number):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.color = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
		}
		
		public function set align(value:String):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.align = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
//			/labelText.opaqueBackground = 0xFFFFFFF;
		}
		
		public function set bold(value:Boolean):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.bold = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
		}
		
		public function set fontSize(value:Number):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.size = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
		}
		
		public function set showDivider(value:Boolean):void {
			if(divider) divider.visible = value;
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			divider.height = viewHeight;
			divider.width = 1;
			divider.x = viewWidth - divider.width;
			
			labelText.y = viewHeight - labelText.textHeight >> 1;
			var padding:int = DeviceUtils.padding;
			
			if(isPortrait && icon){
				icon.width = viewWidth * iconScale;
				icon.scaleY = icon.scaleX;
				if(icon.height > viewHeight){
					icon.height = viewHeight;
					icon.scaleX = icon.scaleY;
				}
			}
			else if(icon) {
				icon.height = viewHeight * iconScale;
				icon.scaleX = icon.scaleY;
				if(icon.width > viewWidth){
					icon.width = viewWidth;
					icon.scaleY = icon.scaleX;
				}
			}
			
			if(label != "" && icon){
				icon.x = padding;
				icon.y = viewHeight - icon.height >> 1;
				
				labelText.x = icon.x + icon.width + padding;
				labelText.width = viewWidth - labelText.x - padding;
			} 
			else if (label != ""){
				labelText.width = viewWidth - padding;
				labelText.x = viewWidth - labelText.width >> 1;
			} 
			else if (icon){
				icon.x = viewWidth - icon.width >> 1;
				icon.y = viewHeight - icon.height >> 1;
			}
			labelText.height = viewHeight - labelText.y;
			
		}
	}
}