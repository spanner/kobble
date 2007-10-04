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
import org.flowlib.*;

/**
 * @author anssi
 */
class org.flowlib.Observable {
	private var dispatcher:EventDispatcher;

	public function Observable() {
		dispatcher = new EventDispatcher();
	}
		
	public function addListener(typeName:String, listener:Object) {
		dispatcher.addEventListener(typeName, listener);
	}
		
	private function dispatchEvent(typeName:String):Void {
		dispatcher.dispatchEvent(typeName, null);
	}

}