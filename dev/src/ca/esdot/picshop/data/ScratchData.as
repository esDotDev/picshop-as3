package ca.esdot.picshop.data
{
	import flash.utils.ByteArray;

	public class ScratchData
	{
		public var width:int;
		public var height:int;
		public var bytes:ByteArray;
		
		public function ScratchData(width:int = -1, height:int = -1, bytes:ByteArray = null){
			this.width = width;
			this.height = height;
			this.bytes = bytes;
		}
	}
}