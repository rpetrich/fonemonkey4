var FoneMonkey = {
	
debugEnabled:false,
	
debug: function(msg) {
	if (this.debugEnabled) {
		UIALogger.logMessage(msg);
	}
},	
	
elementNamed: function(name) {
	UIATarget.localTarget().delay(1);
	UIATarget.localTarget().pushTimeout(0);	
	this.debug("Searching for " + name);
	var result = this.searchElements(UIATarget.localTarget().frontMostApp().mainWindow(), name, "name");
	if (result == null) {
		this.debug("Retrying search for " + name);
		UIATarget.localTarget().delay(1);
		result = this.searchElements(UIATarget.localTarget().frontMostApp().mainWindow(), name, "name");
	}
	if (result) {
		this.debug("searchElements returned " + result.toString());
	} else {
		UIALogger.logFail("Unable to find element named " + name);
	}
	
	UIATarget.localTarget().popTimeout();			
	return result;
},
	
	
scrollTo: function(tableName, item, group) {
	var table = FoneMonkey.elementNamed(tableName);
	var grp;
	var grps = table.groups();
	if (grps.length) {
		grp = table.groups()[group];
	} else {
		grp = table.cells();
	}
	var itm = grp[item];
	itm.logElement();
	table.scrollToElementWithName(itm.name());
},	
	
selectPickerValue: function(pickerName, row, component) {
	
	var picker = FoneMonkey.elementNamed(pickerName);
	
	return this.movePicker(picker, component, row);
	
	var wheels = picker.wheels();
	
	var wheel = wheels[component];
	var values = wheel.values();
	var itm = values[row];
	
	// errors out, see ed's apple bug #8826533 - ejs Jan 2011
	wheel.selectValue(itm);
},	
	
searchElements: function(elem, value, key) {
	//this.debug("checking " + elems.length + " kids");		
	//var result = elems.firstWithValueForKey(value, key);
	this.debug("checking " + Object.prototype.toString.call(elem) + "  elem.name()=\"" + elem.name() + "\"  elem.value()=\"" + elem.value() + "\"  value=\"" + value + "\"  key=\"" + key + "\"");
	var result = elem.withValueForKey(value, key);
	if (result.toString() != "[object UIAElementNil]") {
		this.debug("returning " + result.toString());
		return result;
	}		
	
	var elems = elem.elements();
	this.debug("checking " + elems.length + " children" );
	var i;
	for (i = 0; i < elems.length; i++) {
		var child = elems[i];		
		result = this.searchElements(child, value, key);
		if (result) {
			this.debug("returning child of " + elem.name());
			return result;
		}
	}
	this.debug(value + " not found in children of " + elem.name());
	return null;
	
},

// adapted from Apple Developer Forum Post at
// https://devforums.apple.com/message/242678#242678	
// This will move a picker index
movePicker: function(picker, pickerIndex, indexInPicker) {
	// Verify it is valid
	if (!picker.isValid()) {
		// Not valid for whatever reason
		return false;
	} // if
	
	var startPicker=picker.wheels()[pickerIndex];
	var itemCount=startPicker.values().length;
		
	// The height of a picker item in our application
	var HEIGHT_OF_PICKER_ITEMS = 40;
		
	// Grab the hit point of this object. This will be the exact center of the
	// picker
	var hitPoint = startPicker.hitpoint();
	// Keep this the same
	var hitPointX = hitPoint.x;
		
	// go to the top of the picker (select the topmost item)
	// This will move us to the previous picker item, if there is one
	var hitPointY = hitPoint.y - HEIGHT_OF_PICKER_ITEMS;
	for (var xx=0; xx<itemCount; xx++) {
		// Tap on the next item
		UIATarget.localTarget().tapWithOptions({x:hitPointX, y:hitPointY}, {touchCount:1, tapCount:1});		
		// Allow the picker to render itself
		UIATarget.localTarget().delay(1);
	} // for
		
	// go to the top of the picker (select the topmost item)
	// This will move us to the desired picker item, if there is one
	hitPointY = hitPoint.y + HEIGHT_OF_PICKER_ITEMS;
	for (var i = 0; i < indexInPicker; i++) {
		// Tap on the next item
		UIATarget.localTarget().tapWithOptions({x:hitPointX, y:hitPointY}, {touchCount:1, tapCount:1});
		// Allow the picker to render itself
		UIATarget.localTarget().delay(1);
	} // for
		
	// We performed our action successfully
	return true;
	
} // movePicker
	
	
}

