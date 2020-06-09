module watch_var_;

import std.algorithm;
import std.functional;
 
struct WatchVar(T) {
	T _value;
	
	Listeners!T listeners;
	void listen(listeners.Listener listener) {
		listeners.listen(listener);
	}
	void unlisten(listeners.Listener listener) {
		listeners.unlisten(listener);
	}
	
	this(T init) {
		_value = init;
	}
	
	@property
	T value() {
		return _value;
	}
	void setValue(T n) {
		_value = n;
		listeners.call(n);
	}
	void setValue(alias filterPredicate)(T n) if (is(typeof(unaryFun!filterPredicate))) {
		_value = n;
		listeners.call!filterPredicate(n);
	}
}

struct WatchArray(T) {
	T[] _values;
	
	Listeners!size_t addListeners;
	Listeners!size_t removeListeners;
	void addListen(addListeners.Listener listener) {
		addListeners.listen(listener);
	}
	void addUnlisten(addListeners.Listener listener) {
		addListeners.unlisten(listener);
	}
	void removeListen(removeListeners.Listener listener) {
		removeListeners.listen(listener);
	}
	void removeUnlisten(removeListeners.Listener listener) {
		removeListeners.unlisten(listener);
	}
	
	this(T[] init) {
		_values = init;
	}
	
	auto opIndex(size_t index) {
		return _values[index];
	}
	
	@property
	T[] values() {
		return _values;
	}
	void addValue(T n) {
		_values ~= n;
		addListeners.call(_values.length-1);
	}
	void addValue(alias filterPredicate)(T n) if (is(typeof(unaryFun!filterPredicate))) {
		_values ~= n;
		addListeners.call!filterPredicate(_values.length-1);
	}
	void removeValue(size_t i) {
		removeListeners.call(i);
		_values = _values.remove(i);
	}
	void removeValue(alias filterPredicate)(size_t i) if (is(typeof(unaryFun!filterPredicate))) {
		removeListeners.call!filterPredicate(i);
		_values = _values.remove(i);
	}
}

struct Listeners(Ts...) {
	alias Listener = void delegate(Ts);
	Listener[] listeners = [];
	void listen(Listener listener) {
		listeners ~= listener;
	}
	void unlisten(Listener listener) {
		assert(false, "Unimpelmented");
	}
	void call(Ts args) {
		listeners.each!(l=>l(args));
	}
	void call(alias filterPredicate)(Ts args) if (is(typeof(unaryFun!filterPredicate))) {
		listeners.filter!filterPredicate.each!(l=>l(args));
	}
}

