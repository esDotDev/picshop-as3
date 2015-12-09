package ca.esdot.picshop.dialogs
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.BorderBox;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.views.FacebookAuthForm;
	import ca.esdot.picshop.views.TwitterAuthForm;
	
	import swc.FacebookHeader;
	import swc.InstgramHeader;
	import swc.TextFieldCorner;
	import swc.TwitterHeader;

	public class ShareDialog extends BaseDialog
	{
		protected var _type:String;
		
		public var whiteBg:Bitmap;
		public var image:Image;
		public var header:Sprite;
		public var border:BorderBox;
		public var imageBorder:BorderBox;
		
		public var textField:TextField;
		public var textCorner:Sprite;
		public var defaultText:String;

		private var formMask:Bitmap;
		private var currentForm:SizableView;
		protected var divider:Bitmap;
		public function get message():String {
			if(textField.text == defaultText){
				return "";
			}
			return textField.text;
		}
		
		public function ShareDialog(type:String, bitmapData:BitmapData){
			_type = type;
			if(type == ShareEvent.FACEBOOK){
				header = new swc.FacebookHeader();
				defaultText = "Say something...";
			} else if(type == ShareEvent.TWITTER){
				defaultText = "What's happening?";
				header = new swc.TwitterHeader();
			}
			else if(type == ShareEvent.INSTAGRAM){
				defaultText = "Add Description";
				header = new swc.InstgramHeader();
			}
			addChild(header);
			
			image = new Image();
			image.useScrollRect = true;
			image.bitmapData = bitmapData;
			
			super(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight);
			
			addChild(image);
			addChild(imageBorder);
			
			bg.alpha = 0;
			
			bgPadding = 0;
			setButtons([Strings.DISCARD, Strings.SEND]);
			addChild(buttonContainer);
			addChild(border);
		}
		
		public function get type():String {
			return _type;
		}

		override public function get width():Number {
			return viewWidth;
		}
		
		override protected function createChildren():void {
			whiteBg = new Bitmap(SharedBitmaps.white);
			addChild(whiteBg);
			
			divider = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(divider);
			
			var bd:BitmapData = new BitmapData(1, 1, false);
			bd.draw(header);
			border = new BorderBox(1, bd);
			addChild(border);
			
			imageBorder = new BorderBox(1, SharedBitmaps.bgColor);
			addChild(imageBorder);
			
			textField = TextFields.getRegular(DeviceUtils.fontSize * .8, 0x353535, "left");
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
			textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
			textField.multiline = textField.wordWrap = textField.selectable = textField.mouseEnabled = true;
			textField.type = TextFieldType.INPUT;
			textField.text = defaultText;
			textField.requestSoftKeyboard();
			
			if(type == ShareEvent.TWITTER){
				textField.maxChars = 140;
			} else {
				textField.maxChars = 300;
			}
			addChild(textField);
			
			textCorner = new swc.TextFieldCorner();
			addChild(textCorner);
			
			super.createChildren();
			
			
		}
		
		protected function onFocusOut(event:FocusEvent):void {
			
		}
		
		protected function onFocusIn(event:FocusEvent):void {
			if(textField.text == defaultText){
				textField.text = "";
			}
		}
		
		protected function onTextChanged(event:Event):void {
			textField.scrollV = textField.maxScrollV;
			textCorner.y = Math.min(textField.y + textField.textHeight - 5, textField.y + textField.height);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			header.height = (viewHeight * .15);
			header.scaleX = header.scaleY;
			header.getChildAt(0).width = viewWidth / header.scaleX;
			
			whiteBg.y = header.height;// + 10;
			whiteBg.height = viewHeight - whiteBg.y;
			whiteBg.width = viewWidth;
			
			var h:int;
			var w:int = Math.min(viewWidth * .5);
			if(image.bitmapData.width > image.bitmapData.height){
				//w += 1.25; h *= .75;
			} 
			
			if(viewWidth > viewHeight){
				h = (whiteBg.height - buttonHeight) * .95;
				image.setSize(w, h);
				image.y = whiteBg.y + (whiteBg.height - buttonHeight - h >> 1);
				image.x = viewWidth - image.width - padding;
				
				textField.x = 15;
				textField.y = image.y - 5;
				textField.width = image.x - textField.x - 10;
				textField.height = whiteBg.height - 20;
				
				textCorner.x = 10;
				textCorner.y = textField.y + textField.textHeight - 5;
				
				imageBorder.width = w;
				imageBorder.height = h;
				imageBorder.x = image.x;
				imageBorder.y = image.y;
			} 
			else {
				h = (whiteBg.height - buttonHeight) * .95;
				image.setSize(viewWidth - padding * 2, h * .75);
				image.y = whiteBg.y + padding;
				image.x = padding;
				
				textField.x = 15;
				textField.y = image.y + image.height + padding;
				textField.width = image.width;
				textField.height = h - image.height;
				
				textCorner.x = 10;
				textCorner.y = textField.y + textField.textHeight - 5;
				
				imageBorder.width = image.width;
				imageBorder.height = image.height;
				imageBorder.x = image.x;
				imageBorder.y = image.y;
			}
			
			
			border.y = whiteBg.y;
			border.setSize(whiteBg.width, whiteBg.height);
			
			divider.width = viewWidth;
			divider.height = 1;
			
		}
		
		override protected function updateButtons():void {
			super.updateButtons();
			if(buttonContainer){
				divider.y = buttonContainer.y - 1;
			}
		}
		
		public function addForm(form:SizableView):void {
			addChild(form);
			currentForm = form;
			form.x = border.width;
			form.addEventListener(ButtonEvent.CLICKED, onFormClicked, false, 0, true);
			form.y = border.y;
			
			if(form is FacebookAuthForm){
				form.setSize(border.width, border.height - buttonHeight);
				(form as FacebookAuthForm).initWebView();
				setButtons([Strings.CANCEL]);
			} else {
				form.setSize(border.width, border.height);
			}
			new GTween(form, TweenConstants.NORMAL, {x: border.x}, {ease: TweenConstants.EASE_OUT});
			if(formMask){ removeChild(formMask); }
			formMask = new Bitmap(new BitmapData(viewWidth, viewHeight, false, 0x0));
			addChild(formMask);
			form.mask = formMask;
		}
		
		protected function onFormClicked(event:ButtonEvent):void {
			if(event.label == Strings.CANCEL){
				dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, Strings.DISCARD));
				currentForm.destroy();
			}
		}
	}
}