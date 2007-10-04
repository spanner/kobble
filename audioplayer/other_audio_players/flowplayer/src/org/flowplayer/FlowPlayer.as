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
import org.flowplayer.Config;
import org.flowplayer.ExternalFileConfig;
import org.flowplayer.FlashVarsConfig;
import org.flowplayer.FLVController;
import org.flowplayer.FLVDisplay;
import org.flowplayer.NewAbstractMovieClip;

import cinqetdemi.JSONConfig;

/**
 * FlowPlayer is the main video playback component.
 */
class org.flowplayer.FlowPlayer extends NewAbstractMovieClip {
	private var externalConfig:JSONConfig;
	private static var config:FlashVarsConfig;
	
	private var display:FLVDisplay;
	private var control:FLVController;

	public function FlowPlayer() {
		logger.debug("In FlowPlayer constructor");
		config = new FlashVarsConfig();
	}
	
	function onLoad()  {		
		logger.debug("FlowPlayer::onLoad");
	
		var configFile = config.getConfigFileName();
		if (configFile != undefined) {	
			logger.debug("Will use config file " + configFile);
			externalConfig = JSONConfig.getInstance();
			externalConfig.addConfigLoadListener(this);
			externalConfig.addLoadErrorListener(this);
			externalConfig.fileName = configFile;
			externalConfig.loadConfig();
		} else {
			logger.debug("No external config file specified, will use defaults");
			FlowPlayer.config.setDefaults(new ExternalFileConfig(new Object()));
			initPlayer();
		}
	}
	
	public function onConfigLoadError() {
		logger.debug("Failed to load config, will fallback to defaults");
		initPlayer();
	}
	
	public function onConfigLoaded() {		
		NewAbstractMovieClip.logger.debug("Recieved config loaded event for " + externalConfig.getConfigObject());
		
		config.setDefaults(new ExternalFileConfig(externalConfig.getConfigObject()));
		initPlayer();
	}
	
	public function initPlayer() {
		attachMovie("FLVDisplay", "display", getNextHighestDepth());

//		initClip();
//		arrange();
		this._visible = false;
		logger.debug("starting stream");

		Stage.align = "LT";
		Stage.scaleMode = "noScale";
		Stage.addListener(this.onResize);
		
		/*
		 * This fixes a timing problem that exists wit IE. It prevents resizing
		 * when reloading the page containing this player in IE. 
		 */
		this.onEnterFrame = this.internetExplorerResizeHack;
		
		startStream();
		this.onResize();
		this._visible = true;
		
		stop();		
	}
	
	public function internetExplorerResizeHack():Void {
		NewAbstractMovieClip.logger.debug("FlowPlayer::internetExplorerResizeHack()");
		if ((Stage.width > 0) && (Stage.height > 0)) {
			this.onResize();
			delete this.onEnterFrame;
		}
	}
	
	public function onResize():Void {
		NewAbstractMovieClip.logger.info("FlowPlayer:: onResize()");
        this.setSize(Stage.width, Stage.height);
		display.setSize(Stage.width, Stage.height);
		display._x = 0;
		display._y = 0;
	}
	
	private function startStream():Void {
		this.control = new FLVController(config.getPlayList(), config.getBufferLength(), config.isLooping());
		
		display.init(control);
		
		if (config.isAutoBuffering()) {
			logger.debug("FlowPlayer:: Starting buffering");
			control.startBuffering();
		}

		if (config.isAutoPlay()) {
			logger.debug("FlowPlayer:: Starting playback");
			control.play();	
		}		
	}
	
	private function arrange():Void {
		display.setSize(__width, __height);
		display._x = 0;
		display._y = 0;
//		this._width = __width;
//		this.__height = __height;
	}
	
	public static function getConfig():Config {
		return config;
	}
}
