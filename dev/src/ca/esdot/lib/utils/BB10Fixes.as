package ca.esdot.lib.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class BB10Fixes
	{
		public static var mouseX:int = 0;
		public static var mouseY:int = 0;
		
		protected static var isMouseDown:Boolean;
		protected static var tfList:Vector.<TextObject>;
		protected static var isTextVisible:Boolean;
		protected static var stage:Stage;
		
		public static function init(stage:Stage):void {
			
			BB10Fixes.stage = stage;
			isMouseDown = false;
			
			tfList = new <TextObject>[];
			isTextVisible = true;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			//Check whether text has been selected, if it has, deselect it to prevent lockups.
			stage.addEventListener(Event.ENTER_FRAME, function(){
				for(var i:int = tfList.length; i--;){
					if(tfList[i].text.selectionEndIndex - tfList[i].text.selectionBeginIndex > 1){
						//Need to toggle .visible to full prevent lockups.
						tfList[i].text.visible = false;
						tfList[i].text.setSelection(0, 1);
						setTimeout(showTextfield, 100, tfList[i]);
					}
				}
			});
			
			function showTextfield(textObject:TextObject):void {
				if(textObject.text){
					textObject.text.visible = true;
				}
			}
			
		}
		
		public static function add(text:TextField, showBitmapCache:Boolean = true):void {
			if(!stage){ return; }
			if(!text){ return; }
			var index:int = getIndexByTextfield(text);
			if(index == -1){
				text.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				text.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				text.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
				tfList.push(new TextObject(text, showBitmapCache));
			}
		}
		
		protected static function onFocusIn(event:FocusEvent):void {
			var tf:TextField = (event.currentTarget as TextField);
			if(tf.text == ""){
				tf.text = " ";
			}
			//isMouseDown = true;
		}
		
		protected static function onKeyDown(event:KeyboardEvent):void {
			var tf:TextField = (event.currentTarget as TextField);
			if(tf.text == " "){
				tf.text = "";
			}
		}
		
		public static function remove(text:DisplayObject):void {
			if(!stage){ return; }
			if(!text){ return; }
			var index:int = getIndexByTextfield(text);
			if(index != -1){
				tfList[index].text.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				tfList[index].text.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				tfList[index].text.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				tfList[index].destroy();
				tfList.splice(index, 1);
			}
		}
		
		protected static function getIndexByTextfield(text:DisplayObject):int {
			for(var i:int = tfList.length; i--;){
				if(tfList[i].text == text){ return i; }
			}
			return -1;
		}
		
		protected static function showTextfields(show:Boolean):void {
			var tf:TextField;
			var bitmap:Bitmap;
			for(var i:int = tfList.length; i--;){
				tf = tfList[i].text;
				bitmap = tfList[i].bitmap;
				if(show){
					if(bitmap){
						bitmap.parent.removeChild(bitmap);
						tfList[i].bitmap = null;
					}
				}
				else if(tfList[i].showBitmapCache){
					bitmap = drawText(tf);
					bitmap.x = tf.x;
					bitmap.y = tf.y;
					tf.parent.addChild(bitmap)
					tfList[i].bitmap = bitmap;
				}
				tf.visible = show;
			}
			isTextVisible = show;
		}
		
		protected static function onMouseDown(event:MouseEvent):void {
			isMouseDown = true;
		}
		
		protected static function onMouseMove(event:MouseEvent):void {
			if(stage.mouseX <= stage.stageWidth){ mouseX = stage.mouseX; }
			if(stage.mouseY <= stage.stageHeight){ mouseY = stage.mouseY; }
			if(!isMouseDown){ return; }
			if(isTextVisible){
				showTextfields(false);
			}
		}
		
		protected static function onMouseUp(event:MouseEvent):void {
			isMouseDown = false;
			showTextfields(true);
		}
		
		protected static function drawText(text:TextField):Bitmap {
			var rect:Rectangle = text.getBounds(text);
			var bmpData:BitmapData = new BitmapData(rect.width + 2, rect.height + 2, true, 0x0);
			var m:Matrix = new Matrix(1,0,0,1, -rect.x, -rect.y);
			bmpData.drawWithQuality(text, m, null, null, null, true, StageQuality.HIGH);
			return new Bitmap(bmpData);
		}
	}
}


import flash.display.Bitmap;
import flash.text.TextField;

class TextObject {
	
	public var text:TextField;
	public var showBitmapCache:Boolean;
	public var bitmap:Bitmap;
	
	public function TextObject(text:TextField, showBitmapCache:Boolean) {
		this.text = text;
		this.showBitmapCache = showBitmapCache;
	}
	
	public function destroy():void {
		text = null;
		showBitmapCache = false;
	}
	
}