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
import org.flowplayer.URLUtil;
import org.flowplayer.Skin;
import org.flowplayer.playlist.PlayList;

/**
 * AppContext is used to lookup things like configuration settings. */
class org.flowplayer.FlashVarsConfig implements Config {
  	
  	private var defaults:Config;
  	private var playList:PlayList;
  	
  	public function setDefaults(defaults:Config):Void {
  		this.defaults = defaults;
  	}
  	
 	public function getConfigFileName():String {
 		return URLUtil.addBaseURL(getBaseURL(), _root.configFileName);
 	}
 	
 	public function getProgressIndicatorColor1():Number {
 		return _root.progressBarColor1 == undefined ? defaults.getProgressIndicatorColor1() : parseInt(_root.progressBarColor1, 16);
 	}
 	
 	public function getProgressIndicatorColor2():Number {
 		return _root.progressBarColor2 == undefined ? defaults.getProgressIndicatorColor2() : parseInt(_root.progressBarColor2, 16);
 	}

	public function getBaseURL():String {
		if (_root.baseURL == undefined) return defaults.getBaseURL();
		return _root.baseURL;
	}
	
	public function isAutoBuffering():Boolean {
		if (_root.autoBuffering == undefined) return defaults.isAutoBuffering();
		return "true" == _root.autoBuffering;
	}
	
	public function isAutoPlay():Boolean {
		if (_root.autoPlay == undefined) return defaults.isAutoPlay();
		return "true" == _root.autoPlay;
	}
 	
 	public function isLooping():Boolean {
 		if (_root.loop == undefined) return defaults.isLooping();
 		return "true" == _root.loop;
 	}
 	
 	public function getBufferLength():Number {
 		if (_root.bufferLength == undefined) return defaults.getBufferLength();
 		return parseInt(_root.bufferLength);
 	}

 	public function getVideoHeight() : Number {
 		if (_root.videoHeight == undefined) return defaults.getVideoHeight();
		return parseInt(_root.videoHeight);
	}
 	
 	public function showControls():Boolean {
 		if (_root.hideControls == undefined) return defaults.showControls();
		return "false" == _root.hideControls;
 	}
  	
	public function useEmbeddedButtonImages():Boolean {
		if (_root.useEmbeddedButtonImages == undefined) return defaults.useEmbeddedButtonImages();
		return "true" == _root.useEmbeddedButtonImages;
	}
 	
 	public function getSkin():Skin {
 		return Skin.create(getSkinImagesBaseURL(), getLogoFile(), getSplashImageURL());
 	}
 	
 	public function getPlayList():PlayList {
 		if (_root.videoFile != undefined) {
 			if (this.playList == null)
 				this.playList = PlayList.forOneClip(null, getVideoFile());
 				return this.playList;
 		}
 		return defaults.getPlayList();
 	}

	private function getVideoFile():String {
		return URLUtil.addBaseURL(getBaseURL(), _root.videoFile);
	}

	public function getSkinImagesBaseURL() : String {
		if (_root.skinImagesBaseURL == undefined) return defaults.getSkinImagesBaseURL();
		return _root.skinImagesBaseURL;
	}

	public function getLogoFile() : String {
		if (_root.logoFile == undefined) return defaults.getLogoFile();
		return _root.logoFile;
	}

	public function getSplashImageURL() {
		if (_root.splashImageFile == undefined) return defaults.getSplashImageURL();
		return _root.splashImageFile;
	}

	public function scaleSplash() : Boolean {
		if (_root.scaleSplash == undefined) return defaults.scaleSplash();
		return _root.scaleSplash;
	}

}