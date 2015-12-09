package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.Spinner;
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.Strings;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	
	import swc.TwitterForm;
	
	public class TwitterAuthForm extends SizableView
	{
		protected var cancelButton:SimpleButton;
		protected var bg:Sprite;
		protected var contents:Sprite;
		protected var spinner:Spinner;
		
		protected var twitPicLogo:Sprite
		protected var form:Sprite;
		
		public var signInButton:SimpleButton;
		public var passwordMask:String = "**********";
		
		public var userNameText:TextField;
		public var passwordText:TextField;
		
		public var defaultText:String = "Username or email";
		public var defaultPass:String = "Password";
		
		public var message:String;
		public var bitmapData:BitmapData;
		
		public function TwitterAuthForm(message:String, bitmapData:BitmapData){
			
			this.message = message;
			this.bitmapData = bitmapData;
			
			contents = new Sprite();
			contents.cacheAsBitmap = true;
			
			var a:swc.TwitterForm = new swc.TwitterForm();
			form = a.authForm;
			twitPicLogo = a.twitPicLogo;
			signInButton = a.authForm.signInButton;
			cancelButton = a.authForm.cancelButton;
			cancelButton.addEventListener(MouseEvent.CLICK, removeView, false, 0, true);
			userNameText = a.authForm.userNameText;
			userNameText.text = defaultText;
			
			passwordText = a.authForm.passText;
			passwordText.text = defaultPass;
			
			bg = a.bg;
			
			while(a.numChildren){
				var c:DisplayObject = a.getChildAt(0);
				contents.addChild(c);
			}
			twitPicLogo.x = bg.width - twitPicLogo.width >> 1;
			
			addChild(contents);
			
			userNameText.addEventListener(FocusEvent.FOCUS_IN, function(){
				if(userNameText.text == defaultText){ userNameText.text = ""; }
			});
			
			passwordText.addEventListener(FocusEvent.FOCUS_IN, function(){
				if(passwordText.text == defaultPass || passwordText.text == passwordMask){ 
					passwordText.text = ""; 
				}
				passwordText.displayAsPassword = true;
			});
		}
		
		public function maskPassword():void {
			passwordText.text = passwordMask;	
		}
		
		public function get userName():String { 
			if(userNameText.text == defaultText){
				return "";
			}
			return userNameText.text; 
		}
		public function get password():String { 
			if(passwordText.text == defaultPass){
				return "";
			}
			return passwordText.text; }
		
		public function set isLoading(value:Boolean):void {
			form.visible = !value;
			if(value){
				if(!spinner){ spinner  = new Spinner(); }
				spinner.x = viewWidth - spinner.width >> 1;
				spinner.y = viewHeight - spinner.height >> 1;
				addChild(spinner);
			} else {
				removeChild(spinner);
				spinner  = null;
			}
			
		}
		
		protected function removeView(event:Event = null):void {
			if(parent){
				parent.removeChild(this);
			}
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, Strings.CANCEL));
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			form.height = Math.max(162, viewHeight * .68);
			form.scaleX = form.scaleY;
			
			twitPicLogo.y = viewHeight - twitPicLogo.height - 15;
			twitPicLogo.x = viewWidth - twitPicLogo.width >> 1;
			
			if(spinner){
				spinner.x = viewWidth - spinner.width >> 1;
				spinner.y = viewHeight - spinner.height >> 1;
			}
		}
	}
}