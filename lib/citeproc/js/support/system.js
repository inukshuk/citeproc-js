var System = function () {};

System.prototype.retrieveLocale = function (lang) {
	return this.locales[lang];
};

System.prototype.retrieveItem = function (id) {
	return this.items[id];
};

System.prototype.getAbbreviations = function (context, variable) {
	return (this.abbreviations[context] || {})[variable];
};

System.prototype.update = function (attributes) {
	var name;	
	for (name in attributes) {
		if (attributes.hasOwnProperty(name)) {
			this[name] = attributes[name];
		}
	}
	return this;
};

var system = new System(), citeproc = null;
system.update({ abbreviations: { 'default': {} }, locales: {}, items: {} });
