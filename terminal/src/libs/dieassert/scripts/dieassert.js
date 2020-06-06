/**
 * A console.assert which actually stop the exectution.
 * default console.assert() is a plain display, such as console.log() or console.error();
 * It doesnt stop the execution like assert() is meant to do. This is a little code to 
 * "workaround this limitation" :) thanks @jensarp
 *
 * Usage:
 * console.assert(foo === bar); // Will throw if not equal
 * console.assert(foo === bar, 'Dude, foo does not equal bar'); // Will throw with custom error message
 *
 * To trigger js debugger on failed assert, do 
 * console.assert.useDebugger = true;
 * 
 * Credit to https://gist.github.com/jeromeetienne/2651899
*/
console.assert	= function(cond, text){
	if( cond )	return;
	if( console.assert.useDebugger )	debugger;
	throw new Error(text || "Assertion failed!");
};