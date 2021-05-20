"use strict";

Object.defineProperty(Object.prototype, 'values', {
	get: function () {
		return Object.values(this);
	}
});
Object.defineProperty(Object.prototype, 'keys', {
	get: function () {
		return Object.keys(this);
	}
});
Object.defineProperty(Object.prototype, 'entries', {
	get: function () {
		return Object.entries(this);
	}
});
