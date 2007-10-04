import org.flowlib.EventDispatcher;

import cinqetdemi.JSON;

import LuminicBox.Log.ConsolePublisher;
import LuminicBox.Log.Logger;

/**
 * cinqetdemi.JSONConfig is a class that handles loading, reading and translating JSON config files.
 * Modified by Anssi Piirainen to use as2lib event dispatcher instead of the MX ones.
 * 
 * Usage:
 
	import cinqetdemi.JSONConfig;
	import mx.utils.Delegate;
	
	var config:JSONConfig = JSONConfig.getInstance();
	config.addConfigLoadListener(this);
	config.addLoadErrorListener(this);
	config.loadConfig();
	
	function onConfigLoad()
	{
	    trace(config);
	    trace(JSONConfig.getConfig()); //A shortcut with static access
	}
	
	function onConfigError()
	{
	    trace('Gosh darn it!');
	}
 * 
 * By default, the config file will be loaded from config.js in the same directory as the swf. You may also
 * specify the file name using the .fileName property before calling loadConfig().
 * 
 * The loading will time out after 7 seconds and dispatch an error event
 * 
 * License: BSD
 * By Patrick Mineault, www.5etdemi.com, www.5etdemi.com/blog
 */

class cinqetdemi.JSONConfig
{
	private var dispatcher:EventDispatcher;
	private static var logger:Logger;	
	var fileName:String = "config.py";
	
	var config:Object;

	static var inst:JSONConfig;

	var timeoutInt : Number;

	private var lv : LoadVars;
	
	private static var ON_LOAD_EVENT_NAME:String = "onConfigLoaded";
	private static var ON_ERROR_EVENT_NAME:String = "onConfigLoadError";
	
	/**
	 * Private constructor
	 */
	private function JSONConfig()
	{
		logger = new Logger();
		logger.addPublisher(new ConsolePublisher());
		logger.debug("Creating JSONConfig");
		dispatcher = new EventDispatcher();
		
		onLvLoad.scope = this;
		onLvTimeout.scope = this;
	}
	
	/**
	 * Call after adding event listeners
	 */
	public function loadConfig():Void
	{
		timeoutInt = setInterval(this, 'onLvTimeout', 7000);
		
		lv = new LoadVars();
		lv.onData = this.onLvLoad;
		logger.debug("Loading config file from " + fileName);
		lv.load(fileName);
	}
	
	/**
	 * Called when xml loading has timed out
	 */
	private function onLvTimeout():Void
	{
		clearInterval(arguments.callee.scope.timeoutInt);
		arguments.callee.scope.dispatchEvent(ON_ERROR_EVENT_NAME, null);
	}
	
	/**
	 * Receives the XML load event
	 */
	private function onLvLoad(str:String):Void
	{
		if(str == null)
		{
			//That was actually an error
			arguments.callee.scope.onLvTimeout();
			return;
		}
		clearInterval(arguments.callee.scope.timeoutInt);
		try
		{
			arguments.callee.scope.config = JSON.parse(str);
		}
		catch(error:Error)
		{
			logger.error(error.toString());
		}
		logger.info("JSONConfig: Config file loaded successfully ");
		arguments.callee.scope.dispatchEvent(ON_LOAD_EVENT_NAME, null);
	}
	
	/**
	 * Returns the config object
	 */
	static function getConfig():Object
	{
		return getInstance().config;
	}
	
	public function getConfigObject():Object {
		return config;
	}
	
	/**
	 * Singleton access
	 */
	static function getInstance():JSONConfig
	{
		if(inst == null)
		{
			inst = new JSONConfig();
		}
		return inst;
	}
		
	public function addConfigLoadListener(listener:Object):Void {
		dispatcher.addEventListener(ON_LOAD_EVENT_NAME, listener);
	}
	
	public function addLoadErrorListener(listener:Object):Void {
		dispatcher.addEventListener(ON_ERROR_EVENT_NAME, listener);
	}
		
	private function dispatchEvent(typeName:String, eventObject:Object):Void {
		dispatcher.dispatchEvent(typeName, eventObject);
	}
	
}