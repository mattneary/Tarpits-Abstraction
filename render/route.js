module.exports = (function() {
	var rules = { GET: [], POST: [] }		
	var _404 = function(req, res) { res.writeHead(404); res.end(); };
	var Router = function(req, res, m /*placeholder*/) {
		((m = (rules[req.method]||[]).filter(function(rule) { 
			return rule.path.test(req.url);	// filter for a match to the pattern 
		})).length ? m.pop().cb : _404)(req, res);	// if none, 404
	};
	var _chainable = function(action) { return function(){action.apply({}, arguments); return Router;}; };			
	[["get", _chainable([].push.bind(rules["GET"]))],
	 ["post", _chainable([].push.bind(rules["POST"]))],
	 ["e404", _chainable(function(cb) { _404 = cb; })]].map(function(a){Router[a[0]] = a[1];});
	return Router;
})();