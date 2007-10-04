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

/**
 * @author anssi
 */
class org.flowplayer.URLUtil {
		
	static function addBaseURL(baseURL:String, fileName:String):String {
		if (fileName == undefined) return undefined;
		if (baseURL == '') {
			return fileName;
		}
		if (baseURL != undefined) {
			return baseURL + "/" + fileName;
		}
		if (_root._url != undefined) {
			return _root._url.substring(0, _root._url.indexOf("FlowPlayer")) + fileName;
		}
		return fileName;
	}
	
}