/**
 * Logger target for XPanel 
 * @author Konstantin Kovalev aka Constantiner (constantiner@gmail.com)
 * modifications 
 * Anatole Tartakovsky - repackaged to use Logger/packaged in component
 */
package  com.theriabook.utils
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.getTimer;
	
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;
	import flash.events.EventDispatcher;
	
	[Event(name="fault", type="flash.events.Event")]
	
	public class XPanelTarget extends AbstractTarget implements IEventDispatcher
	{
		public static const FAULT:String = "fault";
		
	    [Inspectable(category="General", defaultValue="false")]
	    
		/**
	     *  Indicates if the category for this target should added to the trace.
	     */
	    public var includeCategory:Boolean = false;
  
	    [Inspectable(category="General", defaultValue=" ")]
	    
		/**
	     *  The separator string to use between fields (the default is " ")
	     */
	    public var fieldSeparator:String = " ";
    
		private var dispatcher:EventDispatcher;
		
		function XPanelTarget ()
		{
			super ();
			dispatcher = new EventDispatcher(this);
		}
		
	    /**
	     *  This method handles a <code>LogEvent</code> from an associated logger.
	     *  A target uses this method to translate the event into the appropriate
	     *  format for transmission, storage, or display.
	     *  This method will be called only if the event's level is in range of the
	     *  target's level.
	     *
	     *  <b><i>Descendants need to override this method to make it useful.</i></b>
	     */
	    public override function logEvent (event:LogEvent):void
	    {
	    	var level:int = event.level;
	    	var targetLevel:int;
	    	switch (level)
	    	{
	    		case LogEventLevel.DEBUG:
	    		{
	    			targetLevel = Logger.LEVEL_DEBUG;
	    			break;
	    		}
	    		case LogEventLevel.ERROR:
	    		{
	    			targetLevel = Logger.LEVEL_ERROR;
	    			break;
	    		}
	    		case LogEventLevel.FATAL:
	    		{
	    			targetLevel = Logger.LEVEL_FATAL;
	    			break;
	    		}
	    		case LogEventLevel.INFO:
	    		{
	    			targetLevel = Logger.LEVEL_INFORMATION;
	    			break;
	    		}
	    		case LogEventLevel.WARN:
	    		{
	    			targetLevel = Logger.LEVEL_WARNING;
	    			break;
	    		}
	    		default:
	    		{
	    			targetLevel = Logger.LEVEL_ALL;
	    			break;
	    		}
	    	}
	    		
	
	 		var category:String = includeCategory ?
								  ILogger(event.target).category + fieldSeparator :
								  "";
					  
			var message:String = event.message;
			message = (typeof message == "xml") ? 
						(message as XML).toXMLString() : message.toString();
			message = category + message;
			
			Logger._send( targetLevel, message );
	    }
	    
	    private function onConnectionStatus (event:StatusEvent):void
	    {
			switch (event.level) 
			{
				case "error":
				{
					dispatchEvent (new Event ( FAULT));
					break;
				}
			}
	    }
               
		public function addEventListener(type:String, 
									listener:Function, 
									useCapture:Boolean = false, 
									priority:int = 0, 
									useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		   
		public function dispatchEvent(evt:Event):Boolean
		{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, 
									listener:Function, 
									useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		   
		public function willTrigger(type:String):Boolean 
		{
			return dispatcher.willTrigger(type);
		}
	}
}