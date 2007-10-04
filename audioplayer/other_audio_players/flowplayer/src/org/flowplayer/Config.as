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
 import org.flowplayer.Skin;
 import org.flowplayer.playlist.PlayList;

/**
 * AppContext is used to lookup things like configuration settings. */
interface org.flowplayer.Config {
 
  	public function getConfigFileName():String;
 	
 	public function getProgressIndicatorColor1():Number;
 	
 	public function getProgressIndicatorColor2():Number;

	public function getBaseURL():String;
	
	public function isAutoBuffering():Boolean;
	
	public function isAutoPlay():Boolean;
 	
 	public function isLooping():Boolean;
 	
 	public function getBufferLength():Number;
 	
 	public function getVideoHeight():Number;
 	
 	public function showControls():Boolean;
 	
 	public function getSkin():Skin;
 	
 	public function getSkinImagesBaseURL():String;
 	
 	public function getLogoFile():String;
 	
 	public function getSplashImageURL();
 	
 	public function scaleSplash():Boolean;

	public function useEmbeddedButtonImages():Boolean;
 	
 	public function getPlayList():PlayList;
 }