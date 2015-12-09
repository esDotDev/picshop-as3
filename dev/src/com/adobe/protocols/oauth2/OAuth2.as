package com.adobe.protocols.oauth2
{
	import com.adobe.protocols.dict.events.ErrorEvent;
	import com.adobe.protocols.oauth2.event.GetAccessTokenEvent;
	import com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent;
	import com.adobe.protocols.oauth2.grant.AuthorizationCodeGrant;
	import com.adobe.protocols.oauth2.grant.IGrantType;
	import com.adobe.protocols.oauth2.grant.ImplicitGrant;
	import com.adobe.protocols.oauth2.grant.ResourceOwnerCredentialsGrant;
	import com.adobe.serialization.json.JSONParseError;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.LocationChangeEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.targets.TraceTarget;
	import mx.rpc.CallResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.ObjectUtil;

	/**
	 * Event that is broadcast when results from a <code>getAccessToken</code> request are received.
	 * 
	 * @eventType com.adobe.protocols.oauth2.event.GetAccessTokenEvent.TYPE
	 * 
	 * @see #getAccessToken()
	 * @see com.adobe.protocols.oauth2.event.GetAccessTokenEvent
	 */
	[Event(name="getAccessToken", type="com.adobe.protocols.oauth2.event.GetAccessTokenEvent")]
	
	/**
	 * Event that is broadcast when results from a <code>refreshAccessToken</code> request are received.
	 * 
	 * @eventType com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent.TYPE
	 * 
	 * @see #refreshAccessToken()
	 * @see com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent
	 */
	[Event(name="refreshAccessToken", type="com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent")]
	
	/**
	 * Utility class the encapsulates APIs for interaction with an OAuth 2.0 server.
	 * Implemented against the OAuth 2.0 v2.15 specification.
	 * 
	 * @see http://tools.ietf.org/html/draft-ietf-oauth-v2-15
	 * 
	 * @author Charles Bihis (charles@whoischarles.com)
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class OAuth2 extends EventDispatcher
	{
		private var grantType:IGrantType;
		private var authEndpoint:String;
		private var tokenEndpoint:String;
		private var log:ILogger;
		private var logTarget:TraceTarget;
		
		/**
		 * Constructor to create a valid OAuth2 client object.
		 * 
		 * @param authEndpoint The authorization endpoint used by the OAuth 2.0 server
		 * @param tokenEndpoint The token endpoint used by the OAuth 2.0 server
		 * @param logLevel (Optional) The new log level for the logger to use
		 */
		public function OAuth2(authEndpoint:String, tokenEndpoint:String, logLevel:int = -1)
		{
			// save endpoint properties
			this.authEndpoint = authEndpoint;
			this.tokenEndpoint = tokenEndpoint;
			
			// set up logging
			logTarget = new TraceTarget();
			logTarget.includeCategory = true;
			logTarget.includeDate = true;
			logTarget.includeLevel = true;
			logTarget.includeTime = true;
			logTarget.level = int.MAX_VALUE;
			Log.addTarget(logTarget);
			log = Log.getLogger("com.adobe.protocols.oauth2");
			
			// initialize logging if optional logging param was passed in
			if (logLevel >= 0)
			{
				setLogLevel(logLevel);
			}  // if statement
		} // OAuth2
		
		/**
		 * Initiates the access token request workflow with the proper context as
		 * described by the passed-in grant-type object.  Upon completion, will
		 * dispatch a <code>GetAccessTokenEvent</code> event.
		 * 
		 * @param grantType An <code>IGrantType</code> object which represents the desired workflow to use when requesting an access token
		 * 
		 * @see com.adobe.protocols.oauth2.grant.IGrantType
		 * @see com.adobe.protocols.oauth2.event.GetAccessTokenEvent#TYPE
		 */
		public function getAccessToken(grantType:IGrantType):void
		{
			if (grantType is AuthorizationCodeGrant)
			{
				log.info("Initiating getAccessToken() with authorization code grant type workflow");
				getAccessTokenWithAuthorizationCodeGrant(grantType as AuthorizationCodeGrant);
			}  // if statement
			else if (grantType is ImplicitGrant)
			{
				log.info("Initiating getAccessToken() with implicit grant type workflow");
				getAccessTokenWithImplicitGrant(grantType as ImplicitGrant);
			}  // else-if statement
			else if (grantType is ResourceOwnerCredentialsGrant)
			{
				log.info("Initiating getAccessToken() with resource owner credentials grant type workflow");
				getAccessTokenWithResourceOwnerCredentialsGrant(grantType as ResourceOwnerCredentialsGrant);
			}  // else-if statement
		}  // getAccessToken
		
		/**
		 * Initiates request to refresh a given access token.  Upon completion, will dispatch
		 * a <code>RefreshAccessTokenEvent</code> event.  On success, a new refresh token may
		 * be issues, at which point the client should discard the old refresh token with the
		 * new one.
		 * 
		 * @param refreshToken A valid refresh token received during last request for an access token
		 * @param clientId The client identifier
		 * @param clientSecret The client secret
		 * 
		 * @see com.adobe.protocols.oauth2.event.RefreshAccessTokenEvent#TYPE
		 */
		public function refreshAccessToken(refreshToken:String, clientId:String, clientSecret:String, scope:String = null):void
		{
			// create result event
			var refreshAccessTokenEvent:RefreshAccessTokenEvent = new RefreshAccessTokenEvent();
			
			// set up HTTP-service call
			var httpService:HTTPService = new HTTPService();
			httpService.url = tokenEndpoint;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			
			// set up parameters
			var args:Object = new Object();
			args.grant_type = "refresh_token";
			args.client_id = clientId;
			args.client_secret = clientSecret;
			args.refresh_token = refreshToken;
			args.scope = scope;
			
			// make the call
			var getTokenResponder:CallResponder = new CallResponder();
			getTokenResponder.addEventListener(ResultEvent.RESULT, onRefreshAccessTokenResult);
			getTokenResponder.addEventListener(FaultEvent.FAULT, onRefreshAccessTokenFault);
			getTokenResponder.token = httpService.send(args);
			
			function onRefreshAccessTokenResult(event:ResultEvent):void
			{
				try
				{
					var response:Object = com.adobe.serialization.json.JSON.decode(getTokenResponder.lastResult);
					log.debug("Refresh access token response received with values:\n" + ObjectUtil.toString(response));
					refreshAccessTokenEvent.parseAccessTokenResponse(response);
				}  // try statement
				catch (error:JSONParseError)
				{
					refreshAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
					refreshAccessTokenEvent.errorMessage = "Error parsing output from refresh access token response: \"" + getTokenResponder.lastResult + "\"";					
				}  // catch statement
				
				dispatchEvent(refreshAccessTokenEvent);
			}  // onRefreshAccessTokenResult
			
			function onRefreshAccessTokenFault(event:FaultEvent):void
			{
				log.error("Error encountered during refresh access token request:\n" + ObjectUtil.toString(event.fault.content));
				
				try
				{
					var fault:Object = com.adobe.serialization.json.JSON.decode(event.fault.content as String);
					refreshAccessTokenEvent.errorCode = fault.error;
					refreshAccessTokenEvent.errorMessage = fault.error_description;
				}  // try statement
				catch (error:JSONParseError)
				{
					refreshAccessTokenEvent.errorCode = "Unknown";
					refreshAccessTokenEvent.errorMessage = "Error encountered during refresh access token request.  Unable to parse fault message: \"" + event.fault.content + "\"";
				}  // catch statement
				
				dispatchEvent(refreshAccessTokenEvent);
			}  // onRefreshAccessTokenFault
		}  // refreshAccessToken
		
		/**
		 * Modifies the log level of the logger.
		 * 
		 * <p>Initially, logging is turned off.  Passing in any value will modify the logging level
		 * of the application.  This method can accept any of the following values...
		 * 
		 * <ul>
		 * 	<li>LogEventLevel.ALL</li>
		 * 	<li>LogEventLevel.DEBUG</li>
		 * 	<li>LogEventLevel.ERROR</li>
		 * 	<li>LogEventLevel.FATAL</li>
		 * 	<li>LogEventLevel.INFO</li>
		 * 	<li>LogEventLevel.WARN</li>
		 * </ul>
		 * 
		 * To turn off logging again, simply pass in <code>int.MAX_VALUE</code>.</p>
		 * 
		 * @param logEventLevel The new log level for the logger to use
		 * 
		 * @see mx.logging.LogEventLevel.ALL
		 * @see mx.logging.LogEventLevel.DEBUG
		 * @see mx.logging.LogEventLevel.ERROR
		 * @see mx.logging.LogEventLevel.FATAL
		 * @see mx.logging.LogEventLevel.INFO
		 * @see mx.logging.LogEventLevel.WARN
		 */
		public function setLogLevel(logEventLevel:int):void
		{
			if (logEventLevel >= 0)
			{
				logTarget.level = logEventLevel;
			}  // if statement
		}  // setLogLevel
		
		/**
		 * @private
		 * 
		 * Helper function that completes get-access-token request using the authorization code grant type.
		 */
		private function getAccessTokenWithAuthorizationCodeGrant(authorizationCodeGrant:AuthorizationCodeGrant):void
		{
			// create result event
			var getAccessTokenEvent:GetAccessTokenEvent = new GetAccessTokenEvent();
			
			// add event listeners
			authorizationCodeGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChanging);
			authorizationCodeGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChanging);
			authorizationCodeGrant.stageWebView.addEventListener(Event.COMPLETE, onStageWebViewComplete);
			authorizationCodeGrant.stageWebView.addEventListener(ErrorEvent.ERROR, onStageWebViewError);
			
			// start the auth process
			var startTime:Number = new Date().time;
			log.info("Loading auth URL: " + authorizationCodeGrant.getFullAuthUrl(authEndpoint));
			authorizationCodeGrant.stageWebView.loadURL(authorizationCodeGrant.getFullAuthUrl(authEndpoint));
			
			function onLocationChanging(locationChangeEvent:LocationChangeEvent):void
			{
				log.info("Loading URL: " + locationChangeEvent.location);
				if (locationChangeEvent.location.indexOf(authorizationCodeGrant.redirectUri) == 0)
				{
					log.info("Redirect URI encountered (" + authorizationCodeGrant.redirectUri + ").  Extracting values from path.");
					
					// stop event from propogating
					locationChangeEvent.preventDefault();
					
					// determine if authorization was successful
					var queryParams:Object = extractQueryParams(locationChangeEvent.location);
					var code:String = queryParams.code;		// authorization code
					if (code != null)
					{
						log.debug("Authorization code: " + code);
						
						// set up HTTP-service call
						var httpService:HTTPService = new HTTPService();
						httpService.url = tokenEndpoint;
						httpService.method = "POST";
						httpService.contentType = "application/x-www-form-urlencoded";
						
						// set up parameters
						var args:Object = new Object();
						args.grant_type = "authorization_code";
						args.code = code;
						args.redirect_uri = authorizationCodeGrant.redirectUri;
						args.client_id = authorizationCodeGrant.clientId;
						args.client_secret = authorizationCodeGrant.clientSecret;
						
						// make the call
						log.debug("Sending access token request with the following values:\n" + ObjectUtil.toString(args));
						var getTokenResponder:CallResponder = new CallResponder();
						getTokenResponder.addEventListener(ResultEvent.RESULT, onGetAccessTokenResult);
						getTokenResponder.addEventListener(FaultEvent.FAULT, onGetAccessTokenFault);
						getTokenResponder.token = httpService.send(args);
					}  // if statement
					else
					{
						log.error("Error encountered during authorization request:\n" + ObjectUtil.toString(queryParams));
						getAccessTokenEvent.errorCode = queryParams.error;
						getAccessTokenEvent.errorMessage = queryParams.error_description;
						dispatchEvent(getAccessTokenEvent);
					}  // else statement
				}  // if statement
				
				function onGetAccessTokenResult(event:ResultEvent):void
				{
					try
					{
						var response:Object = com.adobe.serialization.json.JSON.decode(getTokenResponder.lastResult);
						log.debug("Access token response received with values:\n" + ObjectUtil.toString(response));
						getAccessTokenEvent.parseAccessTokenResponse(response);
					}  // try statement
					catch (error:JSONParseError)
					{
						getAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
						getAccessTokenEvent.errorMessage = "Error parsing output from access token response: \"" + getTokenResponder.lastResult + "\"";
					}  // catch statement
					
					dispatchEvent(getAccessTokenEvent);
				}  // onGetAccessTokenResult
				
				function onGetAccessTokenFault(event:FaultEvent):void
				{
					log.error("Error encountered during access token request:\n" + ObjectUtil.toString(event.fault.content));
					
					try
					{
						var fault:Object = com.adobe.serialization.json.JSON.decode(event.fault.content as String);
						getAccessTokenEvent.errorCode = fault.error;
						getAccessTokenEvent.errorMessage = fault.error_description;
					}  // try statement
					catch (error:JSONParseError)
					{
						getAccessTokenEvent.errorCode = "Unknown";
						getAccessTokenEvent.errorMessage = "Error encountered during access token request.  Unable to parse fault message: \"" + event.fault.content + "\"";
					}  // catch statement
					
					dispatchEvent(getAccessTokenEvent);
				}  // onGetAccessTokenFault
			}  // onLocationChange
			
			function onStageWebViewComplete(event:Event):void
			{
				log.info("Auth URL loading complete after " + (new Date().time - startTime) + "ms");
			}  // onStageWebViewComplete
			
			function onStageWebViewError(event:ErrorEvent):void
			{
				log.error("Error occurred with StageWebView: " + ObjectUtil.toString(event));
				getAccessTokenEvent.errorCode = "STAGE_WEB_VIEW_ERROR";
				getAccessTokenEvent.errorMessage = "Error occurred with StageWebView";
				dispatchEvent(getAccessTokenEvent);
			}  // onStageWebViewError
		}  // getAccessTokenWithAuthorizationCodeGrant
		
		/**
		 * @private
		 * 
		 * Helper function that completes get-access-token request using the implicit grant type.
		 */
		private function getAccessTokenWithImplicitGrant(implicitGrant:ImplicitGrant):void
		{
			// create result event
			var getAccessTokenEvent:GetAccessTokenEvent = new GetAccessTokenEvent();
			
			// add event listeners
			implicitGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChange);
			implicitGrant.stageWebView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			implicitGrant.stageWebView.addEventListener(ErrorEvent.ERROR, onStageWebViewError);
			
			// start the auth process
			log.info("Loading auth URL: " + implicitGrant.getFullAuthUrl(authEndpoint));
			implicitGrant.stageWebView.loadURL(implicitGrant.getFullAuthUrl(authEndpoint));
			
			function onLocationChange(event:LocationChangeEvent):void
			{
				log.info("Loading URL: " + event.location);
				if (event.location.indexOf(implicitGrant.redirectUri) == 0)
				{
					log.info("Redirect URI encountered (" + implicitGrant.redirectUri + ").  Extracting values from path.");
					
					// stop event from propogating
					event.preventDefault();
					
					// determine if authorization was successful
					var queryParams:Object = extractQueryParams(event.location);
					var accessToken:String = queryParams.access_token;
					if (accessToken != null)
					{
						log.debug("Access token: " + accessToken);
						getAccessTokenEvent.parseAccessTokenResponse(queryParams);
						dispatchEvent(getAccessTokenEvent);
					}  // if statement
					else
					{
						log.error("Error encountered during access token request:\n" + ObjectUtil.toString(queryParams));
						getAccessTokenEvent.errorCode = queryParams.error;
						getAccessTokenEvent.errorMessage = queryParams.error_description;
						dispatchEvent(getAccessTokenEvent);
					}  // else statement
				}  // if statement
			}  // onLocationChange
			
			function onStageWebViewError(event:ErrorEvent):void
			{
				log.error("Error occurred with StageWebView: " + ObjectUtil.toString(event));
				getAccessTokenEvent.errorCode = "STAGE_WEB_VIEW_ERROR";
				getAccessTokenEvent.errorMessage = "Error occurred with StageWebView";
				dispatchEvent(getAccessTokenEvent);
			}  // onStageWebViewError
		}  // getAccessTokenWithImplicitGrant
		
		/**
		 * @private
		 * 
		 * Helper function that completes get-access-token request using the resource owner password credentials grant type.
		 */
		private function getAccessTokenWithResourceOwnerCredentialsGrant(resourceOwnerCredentialsGrant:ResourceOwnerCredentialsGrant):void
		{
			// create result event
			var getAccessTokenEvent:GetAccessTokenEvent = new GetAccessTokenEvent();
			
			// set up HTTP-service call
			var httpService:HTTPService = new HTTPService();
			httpService.url = tokenEndpoint;
			httpService.method = "POST";
			httpService.contentType = "application/x-www-form-urlencoded";
			
			// set up parameters
			var args:Object = new Object();
			args.grant_type = "password";
			args.client_id = resourceOwnerCredentialsGrant.clientId;
			args.client_secret = resourceOwnerCredentialsGrant.clientSecret;
			args.username = resourceOwnerCredentialsGrant.username;
			args.password = resourceOwnerCredentialsGrant.password;
			args.scope = resourceOwnerCredentialsGrant.scope;
			
			// make the call
			var getTokenResponder:CallResponder = new CallResponder();
			getTokenResponder.addEventListener(ResultEvent.RESULT, onGetAccessTokenResult);
			getTokenResponder.addEventListener(FaultEvent.FAULT, onGetAccessTokenFault);
			getTokenResponder.token = httpService.send(args);
			
			function onGetAccessTokenResult(event:ResultEvent):void
			{
				try
				{
					var response:Object = com.adobe.serialization.json.JSON.decode(getTokenResponder.lastResult);
					log.debug("Access token response received with values:\n" + ObjectUtil.toString(response));
					getAccessTokenEvent.parseAccessTokenResponse(response);
				}  // try statement
				catch (error:JSONParseError)
				{
					getAccessTokenEvent.errorCode = "com.adobe.serialization.json.JSONParseError";
					getAccessTokenEvent.errorMessage = "Error parsing output from access token response: \"" + getTokenResponder.lastResult + "\"";
				}  // catch statement
				
				dispatchEvent(getAccessTokenEvent);
			}  // onGetAccessTokenResult
			
			function onGetAccessTokenFault(event:FaultEvent):void
			{
				log.error("Error encountered during access token request:\n" + ObjectUtil.toString(event.fault.content));
				
				try
				{
					var fault:Object = com.adobe.serialization.json.JSON.decode(event.fault.content as String);
					getAccessTokenEvent.errorCode = fault.error;
					getAccessTokenEvent.errorMessage = fault.error_description;
				}  // try statement
				catch (error:JSONParseError)
				{
					getAccessTokenEvent.errorCode = "Unknown";
					getAccessTokenEvent.errorMessage = "Error encountered during access token request.  Unable to parse fault message: \"" + event.fault.content + "\"";
				}  // catch statement
				
				dispatchEvent(getAccessTokenEvent);
			}  // onGetAccessTokenFault
		}  // getAccessTokenWithResourceOwnerCredentialsGrant
		
		/**
		 * @private
		 * 
		 * Helper function to extract query from URL and URL fragment.
		 */
		private function extractQueryParams(url:String):Object
		{
			var delimiter:String = (url.indexOf("?") > 0) ? "?" : "#";
			var queryParamsString:String = url.split(delimiter)[1];
			var queryParamsArray:Array = queryParamsString.split("&");
			var queryParams:Object = new Object();
			
			for each (var queryParam:String in queryParamsArray)
			{
				var keyValue:Array = queryParam.split("=");
				queryParams[keyValue[0]] = keyValue[1];	
			}  // for loop
			
			return queryParams;
		}  // extractQueryParams
	}  // class declaration
}  // package