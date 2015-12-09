package ca.esdot.lib.components
{	
	import ca.esdot.lib.view.SizableView;
	
	import com.gskinner.motion.GTween;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import qnx.ui.progress.ActivityIndicator;
	
	public class Toaster extends SizableView
	{
		[Embed(source="assets/Assets.swf", symbol="ToasterAssets")]
		protected var ToasterAssets:Class;
		
		protected var toastMessage:Sprite;
		
		protected var tween:GTween;
		protected var timer:Timer;
		
		protected var initBgHeight:int;
		protected var initTextHeight:int;
		
		protected var messageText:TextField;
		protected var bg:Sprite;
		
		public function Toaster(){
			
			var viewAssets:MovieClip = new ToasterAssets(); 
			toastMessage = new Sprite();
			toastMessage.alpha = 0;
			
			bg = viewAssets.bg;
			toastMessage.addChild(bg);
			
			messageText = viewAssets.messageText;
			toastMessage.addChild(messageText);
			
			initBgHeight = bg.height;
			initTextHeight = messageText.height;
			messageText.autoSize = TextFieldAutoSize.CENTER;
			
			tween = new GTween(toastMessage, .5, {}, {autoPlay:true});
			
			timer = new Timer(3000, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
			
		}
		
		public function show(message:String, duration:Number = -1, activity:Boolean=false):void {
			tween.onComplete = null;
			
			tween.proxy.alpha = 1;
			tween.duration = .25;
			
			messageText.text = message;
			
			var delta:Number = messageText.textHeight - initTextHeight;
			bg.height = initBgHeight + delta + 5;
			
			if(duration == -1){
				duration = 3000 + (Math.round(messageText.textHeight / initTextHeight) - 1) * 500;
			} else { duration *= 1000; }
			
			timer.delay = duration;
			timer.reset();
			timer.start();
			
			messageText.x = 15;
			
			messageText.width = bg.width - messageText.x - 5;
			positionToast();
			
			addChild(toastMessage);
		}
		
		public function positionToast():void {
			//RIGHT 
			toastMessage.x = viewWidth - toastMessage.width - 10;
			
			//CENTER 
			toastMessage.x = viewWidth - toastMessage.width >> 1;
			
			//TOP
			toastMessage.y = 22;
			
			//BOTTOM
			toastMessage.y = viewHeight - toastMessage.height - 10;
			
		}
		
		public function hide():void {
			if(!toastMessage || !contains(toastMessage)){ return; }
			tween.duration = .5;
			tween.proxy.alpha = 0;
			tween.onComplete = onHideComplete;
			
		}
		
		override public function updateLayout():void {
			positionToast();
		}
		
		protected function onHideComplete(tween:GTween):void {
			removeChild(toastMessage);
		}
		
		protected function onTimerTick(event:TimerEvent):void {
			hide();
		}
	}
}