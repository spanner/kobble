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

/**
 * VideoControl is an interface used to control the playback of a video stream.
 * It provides methods for starting, stopping, pausing and resuming the playback.
 * <p>
 * It also provides the {@link #addListener()} method that is used to add a listener
 * for different events occurring in while the video is playing.
 */
interface org.flowplayer.VideoControl {
	
	/**
	 * Toggles looping.
	 */ 
	public function toggleLoop():Void;

	/**
	 * Is this plauer looping?
	 */ 
	public function isLooping():Boolean;

	/**
	 * Starts loading the video stream into buffer.
	 */ 
	public function startBuffering():Void;

	/**
	 * Plays according to the playlist supplied to this control.
	 */ 
	public function play():Void;
	
	/**
	 * Stops the playback and resets the player clearing all buffers.
	 */ 
	public function stop():Void;
	
	/**
	 * Pauses playback.
	 */ 
	public function pause():Void;
	
	/**
	 * Resumes paused playback.
	 */ 
	public function resume():Void;
	
	/**
	 * Moves the playback position to the position designated
	 * by the specified percentage value.
	 *
	 * @param percentage the position where to seek as percentage 
	 *                   of the total video length
	 */ 
	public function seek(percentage:Number):Void;
	
	/**
	 * Pauses the video if it is currently playing or resumes
	 * it if it is paused.
	 */ 
	public function pauseOrResume():Void;
	
	/**
	 * Is this controller paused?
	 */ 
	public function isPaused():Boolean;
	
	/**
	 * Is this controller currently playing the video?
	 */ 
	public function isPlaying():Boolean;
	
	/**
	 * Gets the percentage of video currently played.
	 *
	 * @return percentage played from the total lenth of the video
	 */ 
	public function getProgressPercentage():Number;
	
	/**
	 * Gets the percentage of video loaded.
	 *
	 * @return percentage of the video's total length currently
	 *         loaded into memory buffer.
	 */ 
	public function getBufferPercentage():Number;
	
	/**
	 * Gets the format of the video e.g. 'swf' or 'flv'.
	 */ 
	public function getFormat():String;
	
	/**
	 * Adds an event listener. Currently the only supported event is <br>
	 * 'bufferFull' that is triggered when the video stream/data buffer is full.
	 * When this event occurs, the listeners <code>onBufferFull(eventObject)</code>
	 * method is called.
	 *
	 * @param eventName name of the event to listen
	 * @param targetObject listener object to be notified about the specified event
	 */ 
	public function addListener(eventName:String, targetObject:Object);
	
	/**
	 * Notifies this controller that the video clip has been changed. The controller
	 * should synchronize with it's underlying clip source (i.e. a playlist):	 */
	public function onClipChanged():Void;
}