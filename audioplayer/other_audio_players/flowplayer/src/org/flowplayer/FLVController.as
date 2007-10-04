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

import org.flowplayer.*;
import org.flowplayer.playlist.*;
import org.flowlib.EventDispatcher;
import org.flowlib.Observable;

/**
 * A Controller for FLV playback with progressive download.
 */
class org.flowplayer.FLVController extends Observable implements VideoControl {
	private var logger:Logger;
	var playList:PlayList;
	private var paused:Boolean = false;
	private var playing:Boolean = false;
	
	var videoContainer:Video;
	var videoMc:MovieClip;
	var bufferSeconds:Number;
	var nc:NetConnection = null;
	var ns:NetStream;
	var sound:Sound;
	var done:Boolean = false;
	var videoDurationSecs:Number = 0;
	var loop:Boolean = true;
	var buffering:Boolean = false;



	/**
	 * Creates a new controller.
	 * 
	 * @param videoContainerCompoent
	 * @param playList
	 * @param bufferLengthSeconds
	 */	
	public function FLVController(playList:PlayList, bufferLengthSeconds:Number, loop:Boolean) {
		super();
		logger = new Logger();
		logger.addPublisher ( new ConsolePublisher() );
		
		this.playList = playList;
		this.playList.addListener(PlayList.CLIP_CHANGED_EVENT, this);
		
		this.bufferSeconds = bufferLengthSeconds <= 0 ? 10 : bufferLengthSeconds;
		this.loop = loop;
		
		logger.info("Created FLVStreamController for file " + playList.currentClip().getURL() + ", looping: " + this.loop);
	}
	
	public function attachDisplay(videoMc:MovieClip, videoContainerComponent:Video):Void {
		this.videoContainer = videoContainerComponent;
		this.videoMc = videoMc;
		
		nc = new NetConnection();
		nc.connect(null);
		
		ns = new NetStream(nc);
		ns.setBufferTime(bufferSeconds);
		logger.debug("FLVController::attaching to " + videoContainer);
		videoContainer.attachVideo(ns);

		videoMc.attachAudio(ns);
		sound = new Sound(videoMc);
		setVolume(0);

		// create a status handler
		ns.onStatus = this.netStreamStatusCallback;
		// attach this to the handler function
		this.netStreamStatusCallback.streamer = this;
		
		// create a handler to retrieve FLV metadata
		ns.onMetaData = this.netStreamMetaDataCallback;
		this.netStreamMetaDataCallback.streamer = this;
	}

	/**
	 * @see VideoControl.startBuffering()
	 */
	public function startBuffering():Void {
		dispatchEvent("onStartBuffering");
		buffering = true;
		done = false;
		ns.play(playList.currentClip().getURL());
	}

	/**
	 * @see VideoControl.play()
	 */
	public function play():Void {
		logger.debug("FLVController::play");
		dispatchEvent("onPlay");
		this.playing = true;
		
		if (paused) {
			resume();
			this.paused = false;
			return;
		}

		if (! buffering || done) {
			logger.debug("FLVController::calling ns.play()");
			ns.play(playList.currentClip().getURL());
		}
		done = false;
	}

	/**
	 * @see VideoControl.toggleLoop()
	 */
	public function toggleLoop():Void {
		this.loop = ! this.loop;
		logger.debug("FLVController::loop " + this.loop);
	}
	
	/**
	 * @see VideoControl.isLooping()
	 */
	public function isLooping():Boolean {
		return this.loop;
	}
	
	/**
	 * @see VideoControl.stop()
	 */
	public function stop():Void {
		logger.debug("FLVController::stop(): stopping!");
		dispatchEvent("onStop");
		this.paused = false;
		this.playing = false;
		this.done = false;
		ns.close();
	}
	
	/**
	 * Pauses playback.
	 */
	public function pause():Void {
		logger.debug("FLVController::pause(): pausing");
		dispatchEvent("onPause");
		this.paused = true;
		ns.pause(true);
	}

	private function setIsPaused(newIsPaused:Boolean):Void {
		paused = newIsPaused;
	}
	
	/**
	 * @see VideoControl.isPaused()
	 */
	public function isPaused():Boolean {
		return paused;
	}
	
	/**
	 * @see VideoControl.resume()
	 */
	public function resume():Void {
		logger.debug("FLVController::resume()");
		dispatchEvent("onResume");
		if (! this.paused) {
			play();
		} else {
			this.paused = false;
		}
		this.playing = true;
		ns.pause(false);
	}
	
	/**
	 * Toggles pause/resume.
	 */
	public function pauseOrResume():Void {
		logger.debug("FLVController::pauseOrResume, paused " + this.paused);
		dispatchEvent("onPauseOrResume");
		this.paused = ! this.paused;
		dispatchEvent(this.paused ? "onPause" : "onResume");
		ns.pause();
	}
	
	/**
	 * Handles callbacks from NetStream.
	 */
	function netStreamStatusCallback(info):Void {
		arguments.callee.streamer.updateNetStreamStatus(info);
	}

	function updateNetStreamStatus(info):Void {
//		logger.debug("FLVController::Code: [" + info.code + "]");
		if (info.code.toString() == "NetStream.Play.Stop") {
			this.done = true;
//			if (playList.hasNext())
//				this.clipDone = true;
//			else if (! loop)
//				this.done = true;
			
//			if(!loop) {
//			 	this.clipDone = true;
//			 	this.done = true;
//			} else
//			 	this.clipDone = true;
			 	
//			if (playList.next() == null) {
//				if(!loop){
//				 	this.done = true;
//				}else{
//					playList.toClip(0);
//				}
//			}
			
		} else if (info.code.toString() == "NetStream.Play.Start") {
			logger.debug("FLVController::started");
		} else if (info.code.toString() == "NetStream.Buffer.Full") {
			dispatchEvent("onBufferFull");
			setVolume(100);
		}
	}
	
	/**
	 * Handles metadata callbacks from NetStream. This is used
	 * to detect the FLV duration.
	 */
	function netStreamMetaDataCallback(obj):Void {
		var player:FLVController = arguments.callee.streamer;
		player.updateNetStreamMetaData(obj);
	}
	
	function updateNetStreamMetaData(obj):Void {
		this.videoDurationSecs = obj.duration;
		logger.debug("FLVController::FLV duration: " + obj.duration + " sec.");
		logger.debug("FLVController::FLV videodatarate: " + obj.videodatarate + " Kbit/s");
		logger.debug("FLVController::FLV audiodatarate: " + obj.audiodatarate + " Kbit/s");
		logger.debug("FLVController::FLV creationdate: " + obj.creationdate);
		
		if (! isPlaying() || isPaused()) {
			logger.debug("FLVController::metadata received, pausing player");
			pause();
			ns.seek(0);
		}
		dispatchEvent("onMetaData");
	}
	
	/**
	 * Gets the percentage of the video viewed.
	 * 
	 * @see VideoControl.getProgressPercentage()
	 */
	public function getProgressPercentage():Number {
		if (done) {
			logger.debug("FLVController::done!");
			dispatchEvent("onClipDone");
			return 100;
		}
		if (! isPlaying()) {
//			logger.debug("FLVController::getProgressPercentage: not playing, percentage is zero");
			return 0;
		}
		if (videoDurationSecs == 0) {
//			logger.debug("FLVController::getProgressPercentage: video duration is zero");
			return 0;
		}
		
		var percentage:Number = (ns.time / videoDurationSecs) * 100;
		
		//logger.debug("FLVController::getProgressPercentage: current playhead time " + ns.time + ", percentage " + percentage);
		return percentage;
	}
	
	/**
	 * Gets the percentage of the video's length loaded into memory buffer.
	 * 
	 * @see VideoControl.getProgressPercentage()
	 */
	public function getBufferPercentage():Number {
		if (videoDurationSecs == 0) {
			return 0;
		}
		var percentage:Number = (ns.bytesLoaded / ns.bytesTotal) * 100;
//		logger.debug("FLVController::getBufferPercentage: bytes loaded " + ns.bytesLoaded + " of " + ns.bytesTotal);
		return percentage;
	}

	/**
	 * Seeks into the specified position. This position should be
	 * within the range of the length currently loaded in the buffer.
	 * 
	 * @param percentage a value between 0 and the value returned by {@link getBufferPercentage()}
	 * @see VideoControl.getProgressPercentage()
	 */
	public function seek(percentage:Number):Void {
		dispatchEvent("onSeek");
		// TODO: add percentage validity check!
		if (! isPlaying()) {
			return;
		}
		if (videoDurationSecs == 0) {
			return;
		}
		if (percentage < 0) {
			percentage = 0;
		}
		if (percentage > 100) {
			percentage = 100;
		}
		var targetSeconds:Number = Math.floor((percentage/100) * videoDurationSecs);
		logger.debug("FLVController::seeking to " + targetSeconds + " seconds (" + percentage + " %)");
		ns.seek(targetSeconds);
	}

	/**
	 * Returns 'flv'.
	 */
	public function getFormat():String {
		return 'flv';
	}
	
	public function setVolume(percentage:Number) {
		logger.debug("FLVController::setting volume to " + percentage + " %");
		sound.setVolume(percentage);
	}
	
	/**
	 * @see VideoControl.isPlaying()
	 */
	public function isPlaying():Boolean {
		return this.playing;
	}
	
	private function setIsPlaying(newIsPlaying:Boolean):Void {
		this.playing = newIsPlaying;
	}
	
	/**
	 * @see VideoControl#onClipChanged()
	 */
	public function onClipChanged():Void {
		logger.debug("FLVController:: received onClipChanged");
		ns.close();
		startBuffering();
	}
}
