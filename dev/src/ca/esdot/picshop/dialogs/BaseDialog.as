package ca.esdot.picshop.dialogs
{
	import com.vitapoly.geom.Size;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class BaseDialog extends SizableView
	{
		
		protected var padding:int = 10;
		public var fontSize:int; 
		public var bg:SizableView;
		public var buttonHeight:int = DeviceUtils.hitSize;
		
		protected var bgPadding:Number;
		
		protected var buttonContainer:Sprite;
		protected var buttonList:Array;
		protected var buttonDivider:Bitmap;
		
		public function BaseDialog(width:int = 400, height:int = 250, fontSize:int = -1){
			if(fontSize == -1){ fontSize = DeviceUtils.fontSize; }
			this.fontSize = fontSize;
			
			_viewWidth = width;
			_viewHeight = height;
			bgPadding = 1;
			createChildren();
		}
		
		override public function get width():Number {
			return (bg)? bg.width : super.width;
		}
		
		override public function get height():Number {
			return (bg)? bg.height : super.height;
		}
		
		protected function createChildren():void {
			bg =  new DialogBackground();
			addChildAt(bg, 0);
			
			buttonDivider = new Bitmap(SharedBitmaps.backgroundAccent);
			addChildAt(buttonDivider, 1);
			
			updateLayout();
		}
		
		
		public function setButtons(value:Array):void {
			if(!buttonContainer){
				buttonContainer = new Sprite();
				addChildAt(buttonContainer, getChildIndex(bg) + 1);
			}
			buttonContainer.removeChildren();
			
			var button:LabelButton;
			for(var i:int = 0, l:int = value.length; i < l; i++){
				button = new LabelButton();
				button.label = value[i];
				button.fontSize = fontSize;
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				buttonContainer.addChild(button);
			}
			updateButtons();
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			updateButtons();
		}
		
		protected function updateButtons():void {
			if(!buttonContainer){ return; }
			
			//Buttons should stretch to fill hz space - borderPadding 
			var buttonWidth:int = (viewWidth - bgPadding * 2)/buttonContainer.numChildren;
			for (var i:int = 0, l:int = buttonContainer.numChildren; i < l; i++){
				var button:LabelButton = buttonContainer.getChildAt(i) as LabelButton;
				if(i < l - 1){ button.showDivider = true; }
				button.setSize(buttonWidth, buttonHeight);
				button.x = buttonWidth * i;
			}
			buttonContainer.x = bgPadding;
			buttonContainer.y = bg.height - buttonHeight - 1;
			
			buttonDivider.width = viewWidth;
			buttonDivider.y = buttonContainer.y;
			
		}
		
		protected function onButtonClicked(event:MouseEvent):void {
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, (event.currentTarget as LabelButton).label));
		}
		
		override public function destroy():void {
			for(var i:int = buttonContainer.numChildren; i--;){
				(buttonContainer.getChildAt(i)).removeEventListener(MouseEvent.CLICK, onButtonClicked);
				try {
					(buttonContainer.getChildAt(i) as SizableView).destroy();
				} catch(e:Error){}
			}
		}
		
	
	}
}