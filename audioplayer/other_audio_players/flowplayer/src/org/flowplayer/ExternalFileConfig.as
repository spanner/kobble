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
 * @author anssi
 */
class org.flowplayer.ExternalFileConfig implements Config {
	private var config:Object;
	
	// playList is cached here to avoid expensive creation on repeated access
	private var playList:PlayList;
	
	public function ExternalFileConfig(configObj:Object) {
		this.config = configObj;
	}
	  	
 	public function getConfigFileName():String {
 		return config.configFileName;
 	}
 	
 	public function getProgressIndicatorColor1():Number {
 		return config.progressBarColor1 == undefined ? 0x555555 : parseInt(config.progressBarColor1, 16);
 	}
 	
 	public function getProgressIndicatorColor2():Number {
 		return config.progressBarColor2 == undefined ? 0x555555 : parseInt(config.progressBarColor2, 16);
 	}

	public function getBaseURL():String {
		return config.baseURL;
	}
	
	public function isAutoBuffering():Boolean {
		return config.autoBuffering == undefined || config.autoBuffering;
	}
	
	public function isAutoPlay():Boolean {
		return config.autoPlay;
	}
 	
 	public function isLooping():Boolean {
 		return config.loop == undefined || config.loop;
 	}
 	
 	public function getBufferLength():Number {
 		return config.bufferLength == undefined ? 20 : parseInt(config.bufferLength);
 	}
	
	public function getVideoHeight() : Number {
		return parseInt(config.videoHeight);
	}
 	
 	public function showControls():Boolean {
		return config.hideControls == undefined || ! config.hideControls;
 	}

	public function useEmbeddedButtonImages():Boolean {
		return config.useEmbeddedButtonImages == undefined || config.useEmbeddedButtonImages;
	}
			
 	public function getSkin():Skin {
 		return Skin.create(getSkinImagesBaseURL(), getLogoFile(), getSplashImageURL(), scaleSplash());
 	}

	private function getVideoFile():String {
		return URLUtil.addBaseURL(getBaseURL(), config.videoFile);
	}
 	
 	public function getPlayList():PlayList {
 		// if videoFile is defined, it will be used to create a playList for one clip
  		if (config.videoFile != undefined) {
  			if (this.playList == null)
  				this.playList = PlayList.forOneClip(null, getVideoFile());
			return this.playList;
  		}

 		if (config.playList == undefined) return null;

 		if (this.playList == null)
 			this.playList = PlayList.fromObjectsWithProps(getBaseURL(), config.playList);
 		return this.playList;
 	}

	public function getSkinImagesBaseURL() : String {
		return config.skinImagesBaseURL;
	}

	public function getLogoFile() : String {
		return config.logoFile;
	}

	public function getSplashImageURL() {
		return config.splashImageFile;
	}

	public function scaleSplash() : Boolean {
		return config.scaleSplash;
	}

}