package ca.esdot.lib.utils
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;

	public class ObjectPool
	{
		protected var poolsByClass:Object;
		protected var pool:Array;
		
		public function ObjectPool() {
			poolsByClass = {};
		}
		
		public function put(item:Object):void {
			if(!item){ return; }
			
			var type:String = getQualifiedClassName(item);
			if(!poolsByClass[type]){
				poolsByClass[type] = [];
			}
			if("reset" in item){
				item.reset();
			}
			//trace("[ObjectPool] Return: ", type);
			poolsByClass[type].push(item);
		}
		
		public function get(type:Class, ...constructorArgs):Object {
			if(!type){ return null; }
			
			var typeString:String = getQualifiedClassName(type);
			if(poolsByClass[typeString] && poolsByClass[typeString].length > 0){
				return poolsByClass[typeString].shift();
			} 
			
			trace("[ObjectPool] Create : ", type);
			var o:Object;
			switch(constructorArgs.length){
				
				case 4:
					o = new type(constructorArgs[0], constructorArgs[1], constructorArgs[2], constructorArgs[3]);
					break;
				
				case 3:
					o = new type(constructorArgs[0], constructorArgs[1], constructorArgs[2]);
					break;
				
				case 2:
					o = new type(constructorArgs[0], constructorArgs[1]);
					break;
				
				case 1:
					o = new type(constructorArgs[0]);
					break;
				
				default:
					o = new type();
			}
			return o;
			
		}
	}
}