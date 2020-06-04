
export class Ptr {
	constructor(payload) {
		this.payload = payload;
	}
	get() {
		return this.payload;
	}
	set(v) {
		this.payload = v;
	}
}
export default Ptr;
