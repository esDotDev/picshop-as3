
package ca.esdot.lib.components
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.events.ViewEvent;
	import ca.esdot.lib.view.SizableView;
	
	import com.gskinner.motion.GTween;
	
	import fl.motion.easing.Quadratic;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class ViewStack extends SizableView
	{
		public static const TRANSITION_STARTED:String = "transitionStarted";
		public static const HIDE_COMPLETE:String = "hideComplete";
		public static const TRANSITION_COMPLETE:String = "transitionComplete";
		
		public static const TRANSITION_TYPE_VERTICAL:String = "transitionTypeVertical";
		public static const TRANSITION_TYPE_HORIZONTAL:String = "transitionTypeHorizontal";
		
		protected var _currentState:String = TRANSITION_COMPLETE;
		protected function set currentState(value:String):void {
			if(_currentState == value){ return; }
			_currentState = value;
			dispatchEvent(new Event(_currentState));
		}
		
		public function get viewCount():int { return viewList.length; }
		protected var viewList:Array;
		
		protected var _selectedIndex:int = -1;
		public function get selectedIndex():int { return _selectedIndex; }
		
		protected var _previousView:SizableView;
		public function get previousView():SizableView { return _previousView; }
		public function set previousView(value:SizableView):void {
			_previousView = value;
		}
		
		protected var _currentView:SizableView;
		public function get currentView():SizableView { return _currentView; }
		public function set currentView(value:SizableView):void {
			_currentView = value;
			//trace("[ViewStack] ", parent, currentView);
		}
		
		
		public function get inTransition():Boolean{
			return (_currentState == TRANSITION_STARTED);
		}
		
		public var destroyOnRemove:Boolean = false;
		public var transitionEase:Function = Quadratic.easeOut;
		public var transitionType:String = TRANSITION_TYPE_HORIZONTAL;
		public var tweenDuration:Number = .4;
		public var allowDuplicateInstances:Boolean = true;
		
		public function ViewStack():void {
			viewList = [];
		}
		
		override public function get width():Number {
			return viewWidth;
		}
		
		override public function get height():Number {
			return viewHeight;
		}
		
		override public function updateLayout():void {
			if(currentView){
				currentView.setSize(viewWidth, viewHeight);
			}
		}
		
		public function show():void {
			new GTween(currentView, tweenDuration, {x : 0, y: 0 }, {ease: transitionEase});
		}
		
		public function hide():void {
			var x:int = (transitionType == TRANSITION_TYPE_HORIZONTAL)? -viewWidth: 0;
			var y:int = (transitionType == TRANSITION_TYPE_VERTICAL)? -viewHeight: 0;
			new GTween(currentView, tweenDuration, {x:x, y:y }, {ease: transitionEase});
		}
		
		public function push(newView:SizableView, doTransition:Boolean = true):void {
			if(doTransition && (inTransition || (newView == currentView))){
				trace("[Viewstack] Ignore Push", "inTransition", inTransition, "sameView:",(newView == currentView));
				return; 
			}
			
			if(doTransition){
				currentState = TRANSITION_STARTED;
			}		
			//Remove old view
			if(currentView){
				previousView = currentView;
				if(doTransition){
					previousView.transitionOut();
					var x:int = (transitionType == TRANSITION_TYPE_HORIZONTAL)? -viewWidth: 0;
					var y:int = (transitionType == TRANSITION_TYPE_VERTICAL)? -viewHeight: 0;
					
					mouseEnabled = false;
					mouseChildren = false;
					//This 35ms delay is helpful on low-powered devices, for smooth transitions between the views. 
					//Seems to gives the displayList a chance to render the view before we start animating
					new GTween(previousView, tweenDuration, {x:x, y:y }, {onComplete: onHideComplete, delay:.035, ease: transitionEase}); 
				} else {
					removeChild(previousView);
				}
			}
			
			//If the new view already exists in the stack, remove it from array since it's going back on top
			if(allowDuplicateInstances == false){
				var l:int = viewList.length;
				for(var i:int = 0; i < l; i++){
					if(viewList[i] == newView){
						viewList.splice(i, 1);
						break;
					}
				}
			}
			
			//Add new view
			currentView = newView;
			if(doTransition){
				currentView.transitionIn();
				//Again, delay transition 1 frame or so
				new GTween(currentView, tweenDuration, {x : 0, y: 0 }, {onComplete: onAddComplete, delay:.035, ease: transitionEase});
				currentView.x = (transitionType == TRANSITION_TYPE_HORIZONTAL)? viewWidth: 0;
				currentView.y = (transitionType == TRANSITION_TYPE_VERTICAL)? viewHeight: 0;
			} else {
				currentView.x = 0;
				currentView.y = 0;
			}
			currentView.setSize(viewWidth, viewHeight);
			
			addChild(currentView);
			viewList.push(currentView);
			
			_selectedIndex++;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED));
		}
		
		public function addViewAt(view:SizableView, index:int):void {
			viewList.splice(index, 0, view);
			view.x = 0;
			if(index == _selectedIndex || _selectedIndex == -1){
				addChild(view);
			}
			_selectedIndex = viewList.length - 1;
		}
		
		public function removeViewAt(index:int):SizableView {
			if(!viewList || index > viewList.length-1){ return null; }
			var view:SizableView = viewList[index];
			viewList.splice(index, 1) as SizableView;
			_selectedIndex--;
			if(view && contains(view) && viewList.indexOf(view) == -1){
				removeChild(view);
			}
			if(viewList.length > 0){
				currentView = viewList[viewList.length-1];
				if(viewList.length > 1){
					previousView = viewList[viewList.length-2];
				} else {
					previousView = null;
				}
			} else {
				currentView = previousView = null;
			}	
			return view;
		}
		
		public function indexOf(view:SizableView):int {
			for(var i:int = 0, l:int = viewList.length; i < l; i++){
				if(viewList[i] == view){
					return i;
				}
			}
			return -1;
		}
		
		
		public function pop(doTransition:Boolean = true):SizableView {
			if(_currentState == TRANSITION_STARTED || viewList.length == 0){ return null; }
			
			if(doTransition){
				currentState = TRANSITION_STARTED;
			}
			
			var removedView:SizableView = viewList.pop();
			currentView = viewList[viewList.length - 1];
			//Update previous view if there is one.
			if(viewList.length > 1){
				previousView = viewList[viewList.length - 2];
			} else {
				previousView = null;
			}
			
			var x:int = (transitionType == TRANSITION_TYPE_HORIZONTAL)? viewWidth: 0;
			var y:int = (transitionType == TRANSITION_TYPE_VERTICAL)? viewHeight: 0;
			
			if(doTransition){
				
				mouseEnabled = false;
				mouseChildren = false;
				
				new GTween(removedView, tweenDuration, {x: x, y: y}, {onComplete: onRemoveComplete, ease: transitionEase});
				removedView.transitionOut();
			} else {
				removeChild(removedView);
				if(destroyOnRemove){
					destroyView(removedView);
				}
			}
			
			if(currentView){
				addChild(currentView);
				currentView.transitionIn();
				if(doTransition){
					currentView.x = -x;
					currentView.y = -y;
					new GTween(currentView, tweenDuration, {x: 0, y: 0 }, {ease: transitionEase});
				} else {
					currentView.x = currentView.y = 0;
				}
				currentView.setSize(viewWidth, viewHeight);
			}
			_selectedIndex--;
			
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED));
			return removedView;
		}
		
		
		/**
		 * Trim views from viewStack
		 **/
		public function setRootIndex(index:int, transition:Boolean = false):void {
			if(viewList.length == 0 || index > viewList.length){ return; }
			if(!transition){
				while(numChildren > 0){ removeChildAt(0); }
				_selectedIndex = index;
				currentView = viewList[index];
				currentView.x = 0;
				addChild(currentView);
				
				viewList = viewList.splice(index, 1);
			}
		}
		
		public function removeAll():void {
			while(numChildren){
				removeChildAt(0);
			}
			previousView = currentView = null;
			_selectedIndex = -1;
			viewList = [];
		}
		
		protected function onAddComplete(tween:GTween):void {
			currentState =  TRANSITION_COMPLETE;
		}
		
		protected function onHideComplete(tween:GTween):void {
			if(!previousView){ return; }
			if(contains(previousView)){
				removeChild(previousView);
			}
			currentState = HIDE_COMPLETE;
			currentState = TRANSITION_COMPLETE;
			
			mouseEnabled = true;
			mouseChildren = true;
		}
		
		protected function onRemoveComplete(tween:GTween):void {
			if(contains(tween.target as SizableView)){
				removeChild(tween.target as SizableView);
			}
			if(destroyOnRemove){
				destroyView(tween.target as SizableView);
			}
			currentState = HIDE_COMPLETE;
			currentState = TRANSITION_COMPLETE;
			
			mouseEnabled = true;
			mouseChildren = true;
		}
		
		protected function destroyView(view:SizableView):void {
			view.destroy();
		}
		
		override public function destroy():void {
			while(numChildren){
				var view:SizableView = removeChildAt(0) as SizableView;
				view.destroy();
			}
			viewList = [];
			previousView = currentView = null;
			_selectedIndex = -1;
		}
	}
}