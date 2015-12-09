package ca.esdot.lib.view
{
	import flash.display.Sprite;
	
	import ca.esdot.lib.components.layouts.ILayout;
	import ca.esdot.lib.events.ViewEvent;
	
	public class SizableView extends Sprite implements ISizableView
	{
		protected var _viewWidth:Number = 0;
		protected var _viewHeight:Number = 0;
		
		protected var prevWidth:Number;
		protected var prevHeight:Number;
		
		public var layout:ILayout;
		
		public function get isPortrait():Boolean {
			return viewWidth < viewHeight;
		}
		
		public function get viewHeight():Number {
			return _viewHeight;
		}
		
		public function get viewWidth():Number {
			return _viewWidth;
		}
		
		public function transitionIn():void {
			dispatchEvent(new ViewEvent(ViewEvent.TRANSITION_IN_COMPLETE));
		}
		
		public function transitionOut():void {
			dispatchEvent(new ViewEvent(ViewEvent.TRANSITION_OUT_COMPLETE));
		}
		
		override public function set width(value:Number):void {
			setSize(value, height);
		}
		
		override public function set height(value:Number):void {
			setSize(width, value);
		}
		
		public function get isSizeSet():Boolean {
			return (_viewWidth > 0 || _viewHeight > 0);
		}
		
		public function setSize(width:int, height:int):void {
			if(isNaN(width) || isNaN(height)){ return; }
			prevWidth = (isNaN(_viewWidth) || _viewWidth == 0)? width : viewWidth;
			prevHeight = (isNaN(_viewHeight) || _viewHeight == 0)? height : _viewHeight;
			
			_viewWidth = width;
			_viewHeight = height;
			
			updateLayout();
		}
		
		public function updateLayout():void {
			if(layout){
				layout.update(this);
			}
		}
		
		public function destroy():void {
			//OVerride in subclass	
		}
	}
}


