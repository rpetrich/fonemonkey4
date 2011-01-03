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
	
searchElements: function(elem, value, key) {
	//this.debug("checking " + elems.length + " kids");		
	//var result = elems.firstWithValueForKey(value, key);
	this.debug("checking " + elem.name());
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
	
}
	
	
}

