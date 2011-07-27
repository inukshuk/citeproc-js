var System = function () {
};

System.prototype.retrieveLocale = function (lang) {
	return this.locales[lang];
};

System.prototype.retrieveItem = function (id) {
	return this.items[id];
};

System.prototype.getAbbreviations = function (name, variable) {
	return this.abbreviations[name][variable];
};