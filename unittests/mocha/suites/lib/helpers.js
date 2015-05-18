
module.exports = {
	getParamNames : function(func) {
		var fnStr = func.toString().replace(/((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg, '');
		var result = fnStr.slice(fnStr.indexOf('(')+1, fnStr.indexOf(')')).match(/([^\s,]+)/g);
		if(result === null) {
			result = [];
		}
		return result;
	}
};
