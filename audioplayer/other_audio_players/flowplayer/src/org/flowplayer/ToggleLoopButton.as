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

import org.flowplayer.*;

/**
 * ToggleButton to control looping.
 */
class org.flowplayer.ToggleLoopButton extends AbstractToggleButton {
	
	public function getDownMcSymbolName():String {
		return "LoopOnButton";
	}

	public function getUpMcSymbolName():String {
		return "LoopOffButton";
	}
	
	public function getDownMcURL():String {
		return getSkin().getToggleLoopOnButtonImageURL();
	}
	
	public function getUpMcURL():String {
		return getSkin().getToggleLoopOffButtonImageURL();
	}
}