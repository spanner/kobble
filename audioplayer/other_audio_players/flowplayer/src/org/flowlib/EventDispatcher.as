/*
 * Copyright 2005-2006 Anssi Piirainen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import LuminicBox.Log.*;
import org.as2lib.env.event.multicaster.*;
import org.as2lib.data.holder.*;
import org.as2lib.data.holder.map.*;

/**
 * EventDispatcher holds a group of event listeners and is able
 * to dispatch events to them.
 */
class org.flowlib.EventDispatcher extends MovieClip {
	private var multicasters:Map;
	private var logger:Logger;
	
	public function EventDispatcher() {
		logger = new Logger();
		logger.addPublisher(new ConsolePublisher());
		logger.info("EventDispatcher::Constructor");
		multicasters = new HashMap();
	}
	
	private function getMultiCaster(typeName:String):EventMulticaster {
		//logger.debug("multicasters map: " + multicasters);
		return multicasters.get(typeName);
	}
				
	/**
	 * Adds a listener to the specified event
	 *
	 * @param typenName name that identifies the event to listen
	 * @param listener
	 */
	public function addEventListener(typeName:String, listener:Object) {
		var multiCaster:EventMulticaster = getMultiCaster(typeName);
		if (multiCaster == null) {
			multiCaster = new SimpleEventMulticaster(typeName);
			multicasters.put(typeName, multiCaster);
		} else {
		}
		multiCaster.addListener(listener);
	}
		
	/**
	 * Dispatches an event to all registered listeners.
	 *
	 * @param typenName name that identifies the event to dispatch
	 * @param eventObject an object to be passed over to the listener
	 */
	public function dispatchEvent(typeName:String, eventObject:Object):Void {
		logger.info(this + ":: dispatching " + typeName + ", multicaster =  " + getMultiCaster(typeName));
		if (eventObject != null)
			getMultiCaster(typeName).dispatch(eventObject);
		else
			getMultiCaster(typeName).dispatch();
	}
	
}