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
import org.flowplayer.ClipDescriptor;
import org.flowplayer.FLVController;
import org.flowplayer.NewAbstractMovieClip;
import org.flowplayer.playlist.PlayList;
import org.flowplayer.ProgressTracker;
import org.flowplayer.ToggleLoopButton;
import org.flowplayer.VideoControl;
import org.flowplayer.playlist.PlayListView;

/**
 * Class that encapsulates all GUI widgest.
 */
class org.flowplayer.FLVDisplay extends NewAbstractMovieClip {	
	private var videoBufferLength:Number;
	private var tracker:ProgressTracker;

	private var control:VideoControl;
	private var controlListeningRegistered:Boolean;
	private var playList:PlayList;
	
	var trackIntervalId:Number = -1;
	var bufferingIntervalId:Number = -1;
	var seekingIntervalId:Number = -1;
	var alphaChange:Number = -20;
		
//	private var PLAYLIST_HEIGHT:Number = 132;
	private var PLAYLIST_TO_CONTROLS_GAP:Number = 0;
	private var BUTTONS_TO_VIDEO_GAP:Number = 3;
	private var maxControlHeight:Number = undefined;
	
	// contained movie clips
	private var mcBuffer:MovieClip;
	private var mcSplash:MovieClip;
	private var mcLogo:MovieClip;

	private var mcFLVVideo:MovieClip;
	private var videoFLV:Video;
	private var btnPlay:MovieClip;
	private var btnPause:MovieClip;
	private var btnLoop:ToggleLoopButton;
	private var btnNext:MovieClip;
	private var btnPrev:MovieClip;
	private var mcPlayList:PlayListView;
	
	private var progressIndicatorEdgeColor;
	private var progressIndicatorCenterColor;
	
	public function init(controller:FLVController) {
		if (getConfig().showControls() && tracker == null) throw new Error("tracker is null!");
		if (controller == null) throw new Error("controller is null");
		this.control = controller;
		logger.debug("FLVDisplay:: init() with controller: " + controller);
		controller.attachDisplay(mcFLVVideo, mcFLVVideo.video);

		this.playList = getConfig().getPlayList();
						
		this.play.control = this.control;
		this.pause.control = this.control;
		this.updateProgress.control = this.control;
		this.onToggled.control = control;
		togglePlayback.control = this.control;
		
		registerAsControlListener();
		initControlStates();

		if (getConfig().showControls()) {
			createTrackUpdateInterval();
		}
	}
	
	private function getChildDescriptors():Array {
		var descriptors:Array = [ new ClipDescriptor("mcFLVVideo", "mcFLVVideo", null) ];
		
		if (useSplash()) {
			descriptors.push(new ClipDescriptor(null, "mcSplash", getSkin().getSplashURL()));
		}
		
		if (! getConfig().showControls()) return descriptors;
		
		if (useLogo())
			descriptors.push(new ClipDescriptor(null, "mcLogo", getSkin().getLogoURL()));				

		descriptors.push(new ClipDescriptor("FlowTracker", "tracker", null));
		descriptors.push(new ClipDescriptor("PlayButton", "btnPlay", getSkin().getPlayButtonImageURL()));
		descriptors.push(new ClipDescriptor("PauseButton", "btnPause", getSkin().getPauseButtonImageURL()));
		descriptors.push(new ClipDescriptor("ToggleLoopButton", "btnLoop", null));

		if (!usePlayList()) return descriptors;
		
		descriptors.push(new ClipDescriptor("PlayListView", "mcPlayList", null));
		descriptors.push(new ClipDescriptor("NextButton", "btnNext", getSkin().getNextButtonImageURL()));
		descriptors.push(new ClipDescriptor("PrevButton", "btnPrev", getSkin().getPrevButtonImageURL()));
		
		return descriptors;
	}
		
	private function allChildrenCreated(clips:Array):Void {
		var i:Number = 0;
		mcFLVVideo = clips[i++];
		
		if (useSplash()) {
			mcSplash = clips[i++];
			logger.error("allChildrenCreated(), splash == " + mcSplash);
			mcSplash.onMouseUp = function():Void {
				this._parent.togglePlayback();
			};
		}
		
		if (useLogo())
			mcLogo = clips[i++];

		if (! getConfig().showControls()) return;		
		
		tracker = clips[i++];
		tracker.addSeekListener(this);
		
		btnPlay = clips[i++];
		btnPlay.onRelease = function():Void { 
			this._parent.play(); 
		};
		
		btnPause = clips[i++];
		btnPause.onRelease = function():Void { 
			this._parent.pause(); 
		};
		
		btnLoop = clips[i++];
		btnLoop.initState(control.isLooping());
		btnLoop.addEventListener("onToggled", this);
		
		if (! usePlayList()) return;
		
		mcPlayList = clips[i++];
		playList.addListener(PlayList.CLIP_CHANGED_EVENT, this);

		btnNext = clips[i++];
		btnNext.onRelease = function():Void {
			this._parent.playList.next();
		};

		btnPrev = clips[i++];
		btnPrev.onRelease = function():Void {
			this._parent.playList.prev();
		};
		
		initControlStates();
		createBufferingIndicator();
	}
	
	private function usePlayList():Boolean {
		var size:Number = getConfig().getPlayList().size();
		logger.debug("playlist size is " + size);
		return size > 1;
	}
	
	private function useLogo():Boolean {
		return getSkin().getLogoURL() != undefined;
	}
	
	private function createPlayListControls():Void {
		mcPlayList._visible = false;
	}
	
	private function createBufferingIndicator() {
		createEmptyMovieClip("mcBuffer", getNextHighestDepth());
		mcBuffer.createTextField("bufferText", mcBuffer.getNextHighestDepth(), 0, 0, 80, 30);
		mcBuffer.bufferText.embedFonts = true;
		mcBuffer.bufferText.text = "BUFFERING...";
		mcBuffer.bufferText.setTextFormat(getDefaultTextFormat());
	}
	
	private function arrange():Void {
		if (! allChildrenLoaded()) return;
		
		var videoHeight:Number = calculateVideoHeight();
		logger.error("VIDEO HEIGHT WILL BE " + videoHeight);
		
		arrangeClip(mcFLVVideo, 0, 0, __width, videoHeight);
		
		arrangeClip(mcBuffer, 5, mcFLVVideo._height - 17, null, null);
		
		if (getConfig().scaleSplash()) {
			mcSplash._width = __width;
			mcSplash._height = calculateVideoHeight();
		} else {
			mcSplash._x = (mcFLVVideo._width / 2) - (mcSplash._width / 2);
			mcSplash._y = (mcFLVVideo._height / 2) - (mcSplash._height / 2);
		}

		if (getConfig().showControls())
			arrangeControls();
			
		tracker._visible = true;
		mcPlayList._visible = true;		
	}
	
	private function arrangeControls():Void {
		arrangeButton(btnPause);
		arrangeButton(btnPlay);
		arrangeClipNextToAnother(btnLoop, btnPause);
		arrangeClipNextToAnother(btnPrev, btnLoop);
		arrangeClipNextToAnother(btnNext, btnPrev);
		
		var buttonsWidth:Number = buttonsWidth();
		logger.debug("buttons width " + buttonsWidth);
		tracker.setSize(__width - buttonsWidth - logoWidth() - 2, btnPlay._height);
		tracker.setX(buttonsWidth + 2);
		tracker.setY(btnPlay._y);
		
		if (useLogo())
			arrangeClipNextToAnother(mcLogo, tracker);
		
		if (mcPlayList != null) {
			logger.debug("FLVDisplay.__width " + __width);
			mcPlayList.setSize(__width, calculatePlayListHeight());
			mcPlayList._x = 0;
			mcPlayList._y = btnPlay._y + getMaxControlHeight() + PLAYLIST_TO_CONTROLS_GAP;
			mcPlayList.createAndFillList();
			mcPlayList.arrange();
			traceDims(mcPlayList, null);
		}
	}
	
	private function buttonsWidth():Number {
		if (! usePlayList()) return btnPlay._width + btnLoop._width;
		return btnPlay._width + btnLoop._width + btnPrev._width + btnNext._width;
	}
	
	private function logoWidth():Number {
		if (! useLogo()) return 0;
		return mcLogo._width;
	}
			
	private function calculateVideoHeight():Number {
		if (! getConfig().showControls()) return __height;
		
		var configuredHeight:Number = getConfig().getVideoHeight();
		if (configuredHeight > 0) {
			logger.info("Using configured video height " + configuredHeight);
			return configuredHeight;
		}
		
		var height = __height - getMaxControlHeight() - BUTTONS_TO_VIDEO_GAP;
		if (mcPlayList == null) return height;
		
		return height - mcPlayList.getDefaultHeight();
	}
	
	private function calculatePlayListHeight():Number {
		var height:Number = mcPlayList.getAdjustedHeight(__height - btnPlay._y - getMaxControlHeight());
		logger.info("PLAYLIST HEIGHT WILL BE " + height + " calculated from " + __height);
		traceDims(this, "this");
		traceDims(btnPlay, "btnPlay");
		return height;	
	}
//	
//	private function videoHeightConfigured():Boolean {
//		return getConfig().getVideoHeight() > 0;
//	}
	
	private function getMaxControlHeight():Number {
		if (maxControlHeight == undefined)
			maxControlHeight = maxHeight([btnPlay, btnPause, btnNext, btnPrev, mcLogo]);
		return maxControlHeight;
	}
	
	private function arrangeButton(button:MovieClip):Void {
		button._x = 0;
		button._y = mcFLVVideo._height + BUTTONS_TO_VIDEO_GAP;
	}
	
	private function arrangeClipNextToAnother(clip:MovieClip, another:MovieClip) {
		arrangeClip(clip, another._x + another._width, another._y, null, null);
	}
	
	private function registerAsControlListener():Void {
		if (controlListeningRegistered) return;
		logger.debug("FLVDisplay::registering myself as control listener");
		control.addListener("onMetaData", this);
		control.addListener("onPlay", this);
		control.addListener("onStop", this);
		control.addListener("onPause", this);
		control.addListener("onResume", this);
		control.addListener("onStartBuffering", this);
		control.addListener("onBufferFull", this);
		control.addListener("onClipDone", this);
		
		controlListeningRegistered = true;
		initControlStates();
	}
	
	private function createTrackUpdateInterval():Void {
		if (trackIntervalId == -1) {
			// set some properties to the updateProgress() method
			logger.debug("FLVDisplay::CREATING TRACK UPDATE INTEVAL: control = " + control);
			updateProgress.player = this;
			updateProgress.tracker = tracker;
	
			trackIntervalId = setInterval(updateProgress, 200);
			logger.debug("FLVDisplay::created tracking update interval with id " + trackIntervalId);
		}
	}
	
	private function startBufferingIndicator():Void {
		updateBufferingIndicatorCallback.player = this;
		mcBuffer._visible = true;
		if (bufferingIntervalId == -1) {
			bufferingIntervalId = setInterval(updateBufferingIndicatorCallback, 200);
			logger.debug("created buffering indicator update interval with id " + bufferingIntervalId + " buffer indicator clip: " + mcBuffer);
		}
	}

	private function deleteBufferingInterval():Void {
		logger.debug("deleting buffering interval");
		clearInterval(bufferingIntervalId);
		bufferingIntervalId = -1;
	}
	
	private function deleteTrackUpdateInterval():Void {
		clearInterval(trackIntervalId);
		trackIntervalId = -1;
		logger.debug("FLVDisplay::deleted interval");
	}
	
	function updateProgress():Void {
		var percentage:Number = arguments.callee.control.getProgressPercentage();
		var bufferPercentage:Number = arguments.callee.control.getBufferPercentage();
//		logger.debug("FLVDisplay::updateProgress, control: "+ arguments.callee.control + ", percentage " + percentage);
	
		if (percentage == 100) {
			logger.debug("FLVDisplay::video done");
			arguments.callee.tracker.updateProgress(0);
		} else {
//			logger.debug("FLVDisplay::updating tracker " + arguments.callee.tracker);
			arguments.callee.tracker.updateProgress(percentage);
			arguments.callee.tracker.setMaxSeek(bufferPercentage);
		}
	}
	
	function updateBufferingIndicatorCallback():Void {
		arguments.callee.player.updateBufferingIndicator();
	}
	
	function updateBufferingIndicator():Void {
		mcBuffer._alpha = mcBuffer._alpha + alphaChange;
//		logger.debug("FLVDisplay:: updated buffering indicator alpha to " + mcBuffer._alpha);
		calculateAlphaChange();	
	}
	
	function calculateAlphaChange():Void {
		if (mcBuffer._alpha < 20 || mcBuffer._alpha > 80)
			alphaChange = - alphaChange;
	}
	
	public function play():Void {
		logger.debug("FLVDisplay.play()");
		if (control.isPaused()) {
			control.resume();
		} else {
			control.play();
		}
	}
	
	public function pause():Void {
		logger.debug("FLVDisplay.pause()");
		control.pause();
	};
	
	public function togglePlayback() {
		var isOverVideo:Boolean = mcSplash._visible ? isMouseOverClip(mcSplash) : isMouseOverClip(mcFLVVideo);
		logger.debug("FLVDisplay::togglePlayback(), playing = " + control.isPlaying() + ", on clip = " + isOverVideo + " mcFLVVideo = " + mcFLVVideo);
		if (! isOverVideo) return;
		
		if (! control.isPlaying())
			control.play();
		else
			control.pauseOrResume();
	}
	
	public function onToggled(): Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::FlvDisplay.onToggled");
		var control:FLVController = arguments.callee.control;
		control.toggleLoop();
	}
	
	/**
	 * Callback for controller.
	 */
	public function onSeek(tracker:ProgressTracker) {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onSeek, tracker = " + tracker);
		control.seek(tracker.getSeekPosition());
	}

	/**
	 * Callback for controller.
	 */
	public function onStartBuffering():Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onStartBuffering()");
		startBufferingIndicator();
	}

	public function onBufferFull():Void {
		deleteBufferingInterval();
		mcBuffer._visible = false;
		
		if (! useSplash() || control.isPlaying()) {
			mcFLVVideo._visible = true;
			mcSplash._visible = false;
		}
	}
	
	public function onClipDone():Void {
		if (! playList.hasNext()) {
			if(control.isLooping()){
				logger.debug("moving to clip zero");
				playList.toClip(0);
			} else {
				logger.debug("loop is off, stopping");
				control.stop();
			}
		} else
			playList.next();
	}
	
	private function useSplash():Boolean {
		return getSkin().getSplashURL() != undefined;
	}

	/**
	 * Callback for controller.
	 */
	public function onPlay():Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onPlay(), mcSplash = " + mcSplash);
		startBufferingIndicator();
		createTrackUpdateInterval();
		
		onResume();
	}
	
	/**
	 * Callback for controller.
	 */
	public function onStop():Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onStop()");
//		deleteTrackUpdateInterval();
		btnPlay._visible = true;
		btnPause._visible = false;
	}
	
	/**
	 * Callback for controller.
	 */
	public function onPause():Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onPause()");
		btnPlay._visible = true;
		btnPause._visible = false;
	}	

	/**
	 * Callback for controller.
	 */
	public function onResume():Void {
		NewAbstractMovieClip.logger.debug("FLVDisplay::onResume()");
		btnPlay._visible = false;
		btnPause._visible = true;
		mcFLVVideo._visible = true;
		
		mcSplash.removeMovieClip();
		mcFLVVideo.onMouseUp = function():Void {
			this._parent.togglePlayback();
		};
		
	}	
	
	public function onMetaData(eventObject) {
		logger.debug("FLVDisplay:: onMetaData()");
		mcBuffer._visible = false;
			
		deleteBufferingInterval();
	}	
	
	private function initControlStates() : Void {
		if (hasSize(btnPlay))
			btnPlay._visible = ! getConfig().isAutoPlay();
		if (hasSize(btnPause))
			btnPause._visible = ! btnPlay._visible;
		if (hasSize(btnLoop))
			btnLoop.initState(control.isLooping());
	}

}