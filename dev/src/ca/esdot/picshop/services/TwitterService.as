package ca.esdot.picshop.services
{
	
	import com.soenkerohde.twitter.Twitter;
	import com.soenkerohde.twitter.event.TwitterOAuthEvent;
	import com.soenkerohde.twitter.event.TwitterStatusEvent;
	import com.soenkerohde.twitter.event.TwitterUserEvent;
	
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.LocationChangeEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.media.StageWebView;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.iotashan.oauth.OAuthToken;
	
	public class TwitterService extends EventDispatcher
	{	
		protected var CONSUMER_KEY:String = "H6UOu7CBfyTEgGNHwm0uYw";
		protected var CONSUMER_SECRET:String = "4ZmBWA5iXiLHhk1yIDDjA3NJM1y1SEnuWMrEuhCY";
		protected var CALLBACK_URL:String = "http://picshop.ca/success";
		
		protected var accessToken:OAuthToken;
		protected var pinPending:Boolean = false;
		protected var statusPending:Boolean = false;
		protected var currentState:String;
		public var twitter:Twitter;
		public var errorMessage:String;
		protected var requestToken:String;
		private var webView:StageWebView;
		
		public function init(webView:StageWebView, key:String=null, secret:String=null) : void {
			this.webView = webView;
			this.webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onWebViewChange, false, 0, true);
			
			twitter = new Twitter(CONSUMER_KEY, CONSUMER_SECRET);
			if(key && secret){
				accessToken = new OAuthToken( key, secret );
			}
			else {
				currentState = "unauthenticated";
				twitter.addEventListener(TwitterOAuthEvent.REQUEST_TOKEN, onRequestToken, false, 0, true);
				twitter.authenticate();
			}
		}
		
		protected function onWebViewChange(event:LocationChangeEvent):void {
			trace(event.location);
		}
		
		protected function onRequestToken(event:TwitterOAuthEvent):void {
			requestToken = event.token.key;
			event.preventDefault();
			this.webView.loadURL(Twitter.AUTHORIZE + "?oauth_token=" + requestToken);
		}
		
		protected function verifyAccessToken( token : OAuthToken ) : void {
			twitter.addEventListener( TwitterUserEvent.USER_INFO, userInfoHandler );
			twitter.addEventListener( TwitterUserEvent.USER_ERROR, userErrorHandler );
			twitter.verifyAccessToken( token );
		}
		
		private function userInfoHandler( event : TwitterUserEvent ) : void {
			currentState = "authenticated";
			trace("User Info Loaded!", event.screenName);
			twitter.removeEventListener( TwitterUserEvent.USER_INFO, userInfoHandler );
			twitter.removeEventListener( TwitterUserEvent.USER_ERROR, userErrorHandler );
		}
		
		private function userErrorHandler( event : TwitterUserEvent ) : void {
			currentState = "unauthenticated";
			twitter.removeEventListener( TwitterUserEvent.USER_INFO, userInfoHandler );
			twitter.removeEventListener( TwitterUserEvent.USER_ERROR, userErrorHandler );
		}
		
		public function verifyPin( pin:String ) : void {
			pinPending = true;
			twitter.addEventListener( TwitterOAuthEvent.ACCESS_TOKEN, accessTokenHandler );
			twitter.obtainAccessToken( int( pin ) );
		}
		
		private function accessTokenHandler( event : TwitterOAuthEvent ) : void {
			var so:SharedObject = SharedObject.getLocal( "twitter" );
			so.data["accessToken"] = event.token;
			so.flush();
			
			currentState = "authenticated";
			pinPending = false;
			twitter.removeEventListener( TwitterOAuthEvent.ACCESS_TOKEN, accessTokenHandler );
			
			verifyAccessToken( event.token );
		}
		
		public function setStatus( status:String, media:File = null ) : void {
			statusPending = true;
			twitter.addEventListener( TwitterStatusEvent.STATUS_SEND, statusSendHandler );
			twitter.setStatus( accessToken, status, media );
		}
		
		private function statusSendHandler( event : TwitterStatusEvent ) : void {
			trace( "Your message was successfully sent.", "Status Updated" );
			statusPending = false;
			twitter.removeEventListener( TwitterStatusEvent.STATUS_SEND, statusSendHandler );
		}
		
		protected function logoutClickHandler( event : MouseEvent ) : void {
			var so:SharedObject = SharedObject.getLocal( "twitter" );
			so.data["accessToken"] = null;
			so.flush();
			currentState = "unauthenticated";
			init(null);
		}		

		public function uploadWithTwitPic(u:String, p:String, status:String, media:File):void {
			
			var urlVars:URLVariables = new URLVariables();
			urlVars.username = u;
			urlVars.password = p;
			urlVars.message = status;
			var urlRequest:URLRequest = new URLRequest("http://twitpic.com/api/uploadAndPost");
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = urlVars;
			
			media.upload(urlRequest, 'media');
			media.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadComplete, false, 0, true);
			
			media.addEventListener(IOErrorEvent.IO_ERROR,onUploadFailed,false, 0, false
			);
			/*
			var consumer:OAuthConsumer = new OAuthConsumer( CONSUMER_KEY, CONSUMER_SECRET );
			var oauthRequest:OAuthRequest = new OAuthRequest( "POST", "http://api.twitpic.com/2/upload.format", { status: status }, consumer, accessToken );
			// build request URL from OAuthRequst
			var requestUrl:String = oauthRequest.buildRequest( new OAuthSignatureMethod_HMAC_SHA1(), OAuthRequest.RESULT_TYPE_URL_STRING );
			// new URLReuqest with URL and OAuth params
			var request:URLRequest = new URLRequest( requestUrl );
			request.method = "POST";
			// remove status message param from URL since it is a post request
			request.url = request.url.replace( "&status=" + URLEncoding.encode( status ), "" );
			//request.url += "&oauth_version=1.0";
			// add status message to request data
			request.data = new URLVariables( "status=" + status);
			
			media.upload(request);
			
			media.addEventListener(
				DataEvent.UPLOAD_COMPLETE_DATA,
				function(event:DataEvent):void { trace("Upload Complete"); },
				false, 0, true
			);
			
			media.addEventListener(
				IOErrorEvent.IO_ERROR,
				function(event:IOErrorEvent):void { 
					trace("Upload Error"); 
				},
				false, 0, false
			);
			*/
		}
		
		protected function onUploadFailed(event:IOErrorEvent):void {
			dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.UPLOAD_FAILED));
		}
		
		protected function onUploadComplete(event:DataEvent):void {
			var xml:XML = XML(event.data);
			if(xml..@status == "ok"){
				dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.UPLOAD_COMPLETE));
			} else {
				errorMessage = xml..err[0].@msg.toString();
				dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.UPLOAD_FAILED));
			} 
		}
	}
}