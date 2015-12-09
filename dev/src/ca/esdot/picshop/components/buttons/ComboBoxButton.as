package ca.esdot.picshop.components.buttons
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import fl.motion.easing.Quartic;
	
	import swc.LabelButton;
	
	public class ComboBoxButton extends BaseButton
	{	
		public var divider:Bitmap;
		public var labelText:TextField;
		public var underline:Bitmap;
		public var corner:Sprite;
		
		protected var _label:String;
		protected var _icon:Bitmap;
		
		public function ComboBoxButton(label:String = "", icon:Bitmap = null) {
			_label = label;
			super();
			this.icon = icon;
			align = "left";
			fontSize = DeviceUtils.fontSize * .75;
		}
		
		public function get icon():Bitmap { return _icon; } 
		public function set icon(value:Bitmap):void {
			if(_icon && contains(_icon)){
				removeChild(_icon);
			}
			_icon = value;
			if(_icon){
				addChild(_icon);
			}
		}
		
		override protected function createChildren():void {
			
			super.createChildren();
			var viewAssets:swc.LabelButton = new swc.LabelButton();
			
			labelText = viewAssets.labelText;
			ColorTheme.colorTextfield(labelText);
			//addChild(labelText);
			this.label = label;
			
			divider = new Bitmap(SharedBitmaps.backgroundAccent);
			divider.visible = false;
			addChild(divider);
			
			underline = new Bitmap(SharedBitmaps.accentColor);
			addChild(underline);
			
			corner = new Sprite();
			var g:Graphics = corner.graphics;
			g.moveTo(20, 0);
			g.beginBitmapFill(SharedBitmaps.accentColor);
			g.lineTo(20, 20); g.lineTo(0, 20); g.lineTo(20, 0);
			g.endFill();
			addChild(corner);
			
			
		}
		
		override public function destroy():void {
			super.destroy();
			ColorTheme.removeSprite(labelText);
		}
		
		public function get label():String { return _label || ""; }
		public function set label(value:String):void {
			if(value){
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
		
		public function set align(value:String):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.align = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
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
			
			var padding:int = viewHeight * .2;
			
			divider.height = viewHeight;
			divider.width = 1;
			divider.x = viewWidth - divider.width;
			
			labelText.y = viewHeight - labelText.textHeight >> 1;
			//labelText.opaqueBackground = 0xFF0000;
			if(label != "" && icon){
				icon.x = 10;
				icon.y = viewHeight - icon.height >> 1;
				
				labelText.x = icon.x + icon.width + 10;
				labelText.width = viewWidth - labelText.x - padding * 2;
			} 
			else if (label != ""){
				labelText.width = viewWidth - padding * 2;
				labelText.x = viewWidth - labelText.width >> 1;
			} 
			else if (icon){
				icon.x = viewWidth - icon.width >> 1;
				icon.y = viewHeight - icon.height >> 1;
			}
			labelText.height = 40;
			
			underline.y = labelText.y + labelText.textHeight;
			underline.x = labelText.x;
			underline.width = labelText.width;
			
			corner.height = padding;
			corner.scaleX = corner.scaleY;
			corner.x = viewWidth - corner.width - padding;
			corner.y = underline.y - corner.height;
			
			labelText.y -= padding / 4;
		}
	}
}