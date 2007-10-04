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
import org.flowplayer.playlist.*;
import org.flowlib.Observable;
import org.flowplayer.URLUtil;

/**
 * @author anssi
 */
class org.flowplayer.playlist.PlayList extends Observable {
	private var clips:Array;
	private var current:Number;
	public static var CLIP_CHANGED_EVENT:String = "onClipChanged";
	
	public function PlayList(clips:Array) {
		this.clips = clips;
		current = 0;
	}
	
	public static function forOneClip(clipName:String, clipURL:String) {
		return new PlayList([new Clip(clipName, clipURL)]);
	}
	
	public static function fromObjectsWithProps(baseURL:String, objects:Array):PlayList {
		var clips:Array = new Array();
		for (var i = 0; i < objects.length; i++) {
			var clipObj:Object = objects[i];
			clips[i] = new Clip(clipObj.name, URLUtil.addBaseURL(baseURL, clipObj.url));
		}
		return new PlayList(clips);
	}

	public function all():Array {
		return clips;
	}
	
	public function hasNext():Boolean {
		return current < clips.length - 1; 
	}
	
	public function next():Clip {
		if (current == clips.length -1) return null;
		var clip:Clip = clips[++current];
		dispatchEvent(PlayList.CLIP_CHANGED_EVENT, clip);
		return clip;
	}
	
	public function prev():Clip {
		if (current == 0) return null;
		var clip:Clip = clips[--current];
		dispatchEvent(PlayList.CLIP_CHANGED_EVENT, clip);
		return clip;
	}
	
	public function currentClip():Clip {
		return clips[current];
	}
	
	public function size():Number {
		return clips.length;
	}
	
	public function currentIndex():Number {
		return current;
	}
	
	public function toClip(index:Number):Clip {
		if (index < 0) return null;
		if (index >= clips.length) return null;
		current = index;
		var clip:Clip = clips[current];
		dispatchEvent(PlayList.CLIP_CHANGED_EVENT, clip);
		return clip;
	}
}