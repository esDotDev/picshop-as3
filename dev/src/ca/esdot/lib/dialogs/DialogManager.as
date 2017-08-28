package ca.esdot.lib.dialogs
{
	import com.gskinner.motion.GTween;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.dialogs.BaseDialog;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.events.DialogEvent;

	public class DialogManager 
	{
		protected static var root:DisplayObjectContainer;
		
		protected static var openDialogs:Vector.<DialogData>;
		protected static var dataByDialog:Dictionary;
		
		protected static var viewWidth:int;
		protected static var viewHeight:int;
		protected static var stage:Stage;
		
		public static var lockModal:Boolean;
		public static function set closeCallback(value:Function):void {
			if(currentDialog){
				dataByDialog[currentDialog].closeCallback = value;
			}
		}
		
		public static function init(rootView:DisplayObjectContainer):void {
			openDialogs = new <DialogData>[];
			dataByDialog = new Dictionary(true);
			
			root = rootView;
			
			if(root && (root is Stage || root.stage)){
				stage = (root is Stage)? root as Stage : root.stage;
				viewWidth = stage.stageWidth;
				viewHeight = stage.stageHeight;
				stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true);
			}
		}
		
		protected static function createUnderlay():Sprite {
			var underlay:Sprite = new Sprite();
			underlay.graphics.beginFill(ColorTheme.bgColor, 1);
			underlay.graphics.drawRect(0, 0, 10, 10);
			underlay.graphics.endFill();	
			underlay.addEventListener(MouseEvent.CLICK, onUnderlayClicked, false, 0, true);
			underlay.alpha = 0;
			new GTween(underlay, .35, {alpha: .65});
			return underlay;
		}
		
		protected static function onUnderlayClicked(event:MouseEvent):void {
			if(!dataByDialog[currentDialog].lockModal){
				removeDialog(currentDialog);
			}
		}
		
		protected static function onMouseDown(event:MouseEvent):void {
			event.stopImmediatePropagation();
		}
		
		protected static function onStageResized(event:Event):void {
			viewWidth = stage.stageWidth;
			viewHeight = stage.stageHeight;
			
			setSize(viewWidth, viewHeight);
		}
		
		public static function get currentDialog():Sprite { 
			if(openDialogs.length > 0){
				return openDialogs[openDialogs.length-1].sprite;
			}
			return null; 
		}
		
		
		public static function addDialog(type:Object, lockModal:Boolean=false, showUnderlay:Boolean=true, removeExisting:Boolean = true):Sprite {
			if(!root){
				trace("[DialogManager] 'rootView' is undefined, make sure you called DialogManaer.init(root)");
				return null; 
			}
			if(removeExisting){
				removeDialogs();
			}
			
			root.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 1, true);
			DialogManager.lockModal = lockModal;
			
			var dialog:Sprite;
			if(type is Sprite) {
				dialog = type as Sprite;
			} else if(type is Class){
				dialog = new type();
			}
			
			if(!dialog){ 
				trace("[DialogManager] Error: Unable to find dialog for type: ", type);
				return null; 
			}
			
			var underlay:Sprite;
			if(showUnderlay){
				underlay = createUnderlay();
				root.addChild(underlay);
			}
			var data:DialogData = new DialogData(dialog, underlay, lockModal);
			dataByDialog[dialog] = data;
			openDialogs.push(data);
			
			root.addChild(dialog);
			
			if(viewWidth <= 0){
				setSize(root.width, root.height);
			} else {
				setSize(viewWidth, viewHeight);
			}
			dialog.addEventListener(Event.CANCEL, onDialogCancel, false, 0, true);
			return dialog;
		}
		
		
		public static function removeDialog(dialog:Sprite):void {
			var data:DialogData = dataByDialog[dialog];
			var underlay:Sprite = data.underlay;
			
			dataByDialog[dialog] = null;
			delete dataByDialog[dialog];
			
			if(dialog && root.contains(dialog)){
				dialog.removeEventListener(Event.CANCEL, onDialogCancel);
				root.removeChild(dialog);
				if(openDialogs.indexOf(data) != -1){
					openDialogs.splice(openDialogs.indexOf(data), 1);
				}
				if(dialog is SizableView){
					(dialog as SizableView).destroy();
				}
				dialog = null;
				
				if(data.closeCallback != null){
					data.closeCallback();
					data.closeCallback = null;
				}
				if(dialog is BaseDialog){
					(dialog as BaseDialog).destroy();
				}
			}
			if(underlay && root.contains(underlay)){
				root.removeChild(underlay);
			}
			if(openDialogs.length == 0){
				root.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		public static function removeDialogs():void {
			for(var i:int = openDialogs.length - 1; i >= 0; i--){
				removeDialog(openDialogs[i].sprite);
			}
		}
		
		protected static function onDialogCancel(event:Event):void {
			removeDialogs();
		}
		
		public static function setSize(width:int=0, height:int=0):void {
			viewWidth = width;
			viewHeight = height;
			
			for(var i:int = 0, l:int = openDialogs.length; i < l; i++){
				var data:DialogData = openDialogs[i];
				var dialog:Sprite = data.sprite;
				var underlay:Sprite = data.underlay;
			
				underlay.width = width;
				underlay.height = height;
				
				if(dialog){
					var orgWidth:int = width;
					if(dialog.width > viewWidth){
						dialog.width = viewWidth * .9;
						dialog.scaleY = dialog.scaleX;
					}
					center(dialog);
				}
			}
		}
		
		public static function center(dialog:Sprite):void {
			if(!dialog){ return; }
			dialog.x = viewWidth - dialog.width >> 1;
			dialog.y = viewHeight - dialog.height >> 1;
		}
		
		public static function alert(title:String, message:String):TitleDialog {
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, title, message);
			dialog.setButtons(["Ok"]);
			dialog.addEventListener(ButtonEvent.CLICKED, DialogManager.alertClicked, false, 0, true);
			DialogManager.addDialog(dialog);
			return dialog;
		}
		
		public static function alertClicked(event:ButtonEvent):void {
			removeDialogs();
		}
		
	}
}
import flash.display.Sprite;

class DialogData {

	public var sprite:Sprite;
	public var lockModal:Boolean;
	public var underlay:Sprite;
	public var closeCallback:Function;
	
	public function DialogData(sprite:Sprite, underlay:Sprite, lockModal:Boolean){
		this.sprite = sprite;
		this.lockModal = lockModal;
		this.underlay = underlay;
	}
	
}