package     com.theriabook.utils
{
	// ActionScript 3 logger

	import flash.net.LocalConnection;
	import flash.utils.getTimer;
	import mx.controls.Alert;
	import flash.events.StatusEvent;
	import flash.events.SecurityErrorEvent;
	import mx.core.Application;


	public class Logger extends Object
	{
		public static var enabled : Boolean = true;
		public static var level   : uint    = LEVEL_ALL;
		//
		public static var LEVEL_DEBUG       : uint = 0x0001;
		public static var LEVEL_INFORMATION : uint = 0x0002;
		public static var LEVEL_WARNING     : uint = 0x0004;
		public static var LEVEL_ERROR       : uint = 0x0008;
		public static var LEVEL_FATAL       : uint = 0x0010;
		public static var LEVEL_START       : uint = 0x0100;
		//
		public static var LEVEL_NONE        : Number = 0xFF;
		public static var LEVEL_ALL         : Number = 0x00;
		//
		private static var s_lc:LocalConnection = null;

		public static function alert(o:Object):void
		{
			Alert.show(""+o, "alert");
		}

		public static function debug(o:Object):void
		{
			_send(LEVEL_DEBUG, o);
		}

		public static function info(o:Object):void
		{
			_send(LEVEL_INFORMATION, o);
		}

		public static function error(o:Object):void
		{
			_send(LEVEL_ERROR, o);
		}

		public static function fatal(o:Object):void
		{
			_send(LEVEL_FATAL, o);
		}

		public static function message(o:Object):void
		{
			_send(LEVEL_INFORMATION, o);
		}

		public static function warn(o:Object):void
		{
			_send(LEVEL_WARNING, o);
		}

		public static function warning(o:Object):void
		{
			_send(LEVEL_WARNING, o);
		}

		public static function trace(o:Object):void
		{
			_send(LEVEL_DEBUG, o);
		}

		//
		public static function _send(_level_:Number, o:Object):void
		{
			try
			{
				if( _level_<level )
					return;

				if( s_lc==null )
				{
					s_lc = new LocalConnection();
					s_lc.addEventListener(StatusEvent.STATUS, _onStatus);
					s_lc.addEventListener(SecurityErrorEvent.SECURITY_ERROR , _onSecError);
					s_lc.send("_xpanel1", "dispatchMessage", getTimer(), "Started "+Application.application.url, LEVEL_START);
				}
				s_lc.send("_xpanel1", "dispatchMessage", getTimer(), typeof(o)=="xml"?o.toXMLString():""+o, _level_);
			} catch(e:Error){}
		}

		private static function _onStatus(evt:StatusEvent):void
		{
			// kill status error message box
		}

		private static function _onSecError(evt:SecurityErrorEvent):void
		{
		}

	}
}
