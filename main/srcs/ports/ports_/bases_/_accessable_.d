 module ports_.bases_._accessable_;

mixin template Accessable(T) {
	alias TRef = T*;
	static if (is(T == class) || isPointer!T) {
		alias TStore = T;
		bool isNull(const TStore store) {
			return store is null;
		}
		void nullify(ref TStore store) {
			store = null;
		}
		TRef refify(ref TStore store) {
			return &store;
		}
		T valueify(TStore store) {
			return store;
		}
		T valueify(TRef store) {
			return *store;
		}
	}
	else {
		alias TStore = Nullable!T;
		TRef refify(ref TStore store) {
			return &store.get();
		}
		T valueify(TStore store) {
			return store.get;
		}
		T valueify(TRef store) {
			return *store;
		}
	}
}

