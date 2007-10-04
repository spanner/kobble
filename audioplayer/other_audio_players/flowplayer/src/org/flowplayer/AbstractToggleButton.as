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
import org.flowplayer.NewAbstractMovieClip;

/**
 * An abstract ToggleButton.
 */
class org.flowplayer.AbstractToggleButton extends NewAbstractMovieClip {
	
	private var mcDown:MovieClip;
	private var mcUp:MovieClip;
	private var isDown:Boolean;
	
	private function getChildDescriptors():Array {
		return [
			new ClipDescriptor(getDownMcSymbolName(), "mcDown", getDownMcURL()),
			new ClipDescriptor(getUpMcSymbolName(), "mcUp", getUpMcURL())
		];
	}
	
	private function allChildrenCreated(clips:Array):Void {
		mcDown = clips[0];
		mcUp = clips[1];
		toggled.button = this;
		this.onRelease = toggled;
	}
	
	public function initState(isDown:Boolean):Void {
		this.isDown = isDown;
		changeClips();
	}
	
	public function arrange():Void {
		mcDown._x = 0;
		mcUp._x = 0;
		mcDown._y = 0;
		mcUp.y = 0;
		mcDown._width = this._width;
		mcUp._width = this._width;
		mcDown._height = this._height;
		mcUp._height = this._height;
		changeClips();
	}
	
	/**
	 * Override this function if "down image" should be attached from library.
	 */
	public function getDownMcSymbolName():String {
		return null;
	}

	/**
	 * Override this function if "up image" should be attached from library.
	 */
	public function getUpMcSymbolName():String {
		return null;
	}
	
	/**
	 * Override this function if "down image" should be loaded as an external resource.
	 * @return the URL of the image
	 */
	public function getDownMcURL():String {
		return null;
	}
	
	/**
	 * Override this function if "up image" should be loaded as an external resource.
	 * @return the URL of the image
	 */
	public function getUpMcURL():String {
		return null;
	}
	
	public function toggled():Void {
		trace("toggled");
		dispatchEvent("onToggled");
		var button:AbstractToggleButton = arguments.callee.button;
		if (button.isDownPressed())
			button.release();
		else
			button.pressDown();
	}
	
	public function pressDown():Void {
		this.isDown = true;
		changeClips();
	}
	
	public function release():Void {
		this.isDown = false;
		changeClips();
	}
	
	public function isDownPressed():Boolean {
		return isDown;
	}
	
	private function changeClips():Void {
		mcDown._visible = this.isDown;
		mcUp._visible = ! this.isDown;
	}	
}