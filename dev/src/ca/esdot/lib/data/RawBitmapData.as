package ca.esdot.lib.data
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class RawBitmapData
	{
		public var width:int;
		public var height:int;
		public var bytes:ByteArray;
		
		public function RawBitmapData(data:BitmapData = null){
			if(!data){ return; }
			bytes = data.getPixels(data.rect);
			width = data.width;
			height = data.height;
		}
		
		public function get bitmapData():BitmapData {
			var bmpData:BitmapData = new BitmapData(width, height, true, 0x0);
			bmpData.setPixels(bmpData.rect, bytes);
			return bmpData;
		}
	}
}