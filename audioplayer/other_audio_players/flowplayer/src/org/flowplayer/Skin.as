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

import org.flowplayer.URLUtil;

/**
 * @author anssi
 */
class org.flowplayer.Skin {

	private var imageBaseURL:String;
	private var logoFile:String;
	private var splashFile:String;
	private var scaleSplash:Boolean;
	
	private static var instance:Skin;
	
	public static function create(imageBaseURL:String, logoFile:String, splashFile:String, scaleSplash:Boolean):Skin {
		if (instance == null) {
			instance = new Skin(imageBaseURL, logoFile, splashFile, scaleSplash);
		}
		return instance;
	}
	
	private function Skin(imageBaseURL:String, logoFile:String, splashFile:String, scaleSplash:Boolean) {
		this.imageBaseURL = imageBaseURL;
		this.logoFile = logoFile;
		this.splashFile = splashFile;
		this.scaleSplash = scaleSplash;
	}
	
	public function getPlayButtonImageURL():String {
		return URLfor('PlayButton.jpg');
	}
	
	public function getPauseButtonImageURL():String {
		return URLfor('PauseButton.jpg');
	}
	
	public function getToggleLoopOnButtonImageURL():String {
		return URLfor('LoopOnButton.jpg');
	}
	
	public function getToggleLoopOffButtonImageURL():String {
		return URLfor('LoopOffButton.jpg');
	}
	
	public function getSeekButtonImageURL():String {
		return URLfor('Dragger.jpg');
	}
	
	public function getNextButtonImageURL():String {
		return URLfor('NextButton.jpg');
	}
	
	public function getPrevButtonImageURL():String {
		return URLfor('PrevButton.jpg');
	}
	
	public function getDraggerImageURL():String {
		return URLfor('Dragger.jpg');
	}

	public function getUpScrollButtonImageURL():String {
		return URLfor('UpButton.jpg');
	}

	public function getDownScrollButtonImageURL():String {
		return URLfor('DownButton.jpg');
	}
	
	public function getScrollBarButtonImageURL():String {
		return URLfor("Scroller.jpg");
	}
	
	public function getLogoURL():String {
		return URLfor(logoFile);
	}
	
	public function getSplashURL():String {
		return URLfor(splashFile);
	}
	
	private function URLfor(fileName:String):String {
		return URLUtil.addBaseURL(imageBaseURL, fileName);
	}
}