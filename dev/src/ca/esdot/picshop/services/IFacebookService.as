package ca.esdot.picshop.services
{
	import flash.display.BitmapData;

	public interface IFacebookService
	{
		function init(appId:String):void 
			
		function authenticate(permissions:String = "public_profile"):void 
			
		function postPhoto(comment:String, imageData:BitmapData):void
			
		function loadAlbums():void 
			
		function loadPhotos(albumId:String):void 
			
		function loadHiResPhoto(photoId:String):void
			
		function callGraph(graphPath:String, httpMethod:String, params:Object):void
			
		function isAuthenticated():Boolean
			
		function cleanup():void
	}
}