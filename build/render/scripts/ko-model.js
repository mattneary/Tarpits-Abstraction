var Model = function(model, middleWare) {
	this.cache = {};
	this.link = ko.observable();								
	
	// all is loaded by initial get
	this.all = ko.observableArray();
	$.get('/api/'+model.toLowerCase()+'s/', function(items) {
		this.all(items);
	}.bind(this));	
	
	// current is loaded by _current
	this.current = ko.observable();
	this._current = ko.dependentObservable(function() {
		var link = middleWare.link.call(this, this.link());
		link && this.cache[link] ? this.current(this.cache[link]) : $.get('/api/'+model+'/'+link, function(item) {
			this.link(link);
			var content = middleWare ? middleWare.content(item) : item;
			this.current(content);
			this.cache[link] = content;
		}.bind(this));
	}.bind(this));
	
	this.click = function(post, evt) {
		this.link(middleWare.click.call(this, post, evt));
	};
	
	this.link.subscribe(middleWare.hash.bind(this));
};