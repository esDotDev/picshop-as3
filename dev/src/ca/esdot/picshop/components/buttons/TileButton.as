package ca.esdot.picshop.components.buttons
{
	import flash.display.Bitmap;
	
	import ca.esdot.lib.utils.DeviceUtils;
	
	public class TileButton extends LabelButton
	{	
		protected var textCache:Bitmap;
		public var iconPadding:Number = .5;
		
		public function TileButton(label:String = "", icon:Bitmap = null, iconPadding:Number = .25) {
			this.iconPadding = iconPadding;
			textCache = new Bitmap();
			addChild(textCache);
			
			if(label){ label = label.toUpperCase(); } 
			super(label);
			
			labelText.multiline = false;
			
			if(icon){
				this.icon = icon;
			}
		}
		
		override public function set label(value:String):void {
			super.label = value;
			if(label == ""){
				labelText.visible = false;
			} else {
				labelText.visible = true;
			}	
		}
		
		override public function updateLayout():void {
			bg.width = bgDown.width = viewWidth;
			bg.height = bgDown.height = viewHeight;
			
			divider.height = viewHeight;
			divider.width = 1;
			divider.x = viewWidth - divider.width;
			
			labelText.width = viewWidth - labelText.x * 2;
			labelText.height = viewHeight * .35;
			
			
			if(icon){
				//icon.scaleX = icon.scaleY = 1;
				var padding:int = iconPadding * viewWidth;
				var scale:Number = Math.min( (viewWidth  - padding) /icon.width,  (viewHeight - padding) /icon.height);
				if(scale < 1){ icon.scaleX = icon.scaleY = scale; }
				
				icon.x = viewWidth - icon.width >> 1;
				icon.y = viewHeight - icon.height >> 1;
			}
			
			if(label != "" && icon){
				var padding:int = 5 * DeviceUtils.screenScale;
				var totalHeight:int = labelText.textHeight + padding + icon.height;
				labelText.y = viewHeight - totalHeight >> 1;
				
				icon.y = labelText.y + labelText.textHeight + padding;
			} 
			else if (label != ""){
				labelText.x = viewWidth - labelText.width >> 1;
				labelText.y = viewHeight - labelText.height >> 1;
			}
			
			labelText.x = viewWidth - labelText.width >> 1;
			
		}
	}
}