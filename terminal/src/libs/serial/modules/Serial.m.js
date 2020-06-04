
export
const SerialType = {
	uint8	: "uint8"	,
	int8	: "int8"	,
	uint16	: "uint16"	,
	int16	: "int16"	,
	uint32	: "uint32"	,
	int32	: "int32"	,
	bigUint64	: "bigUint64"	,
	bigInt64	: "bigInt64"	,
			
	float32	: "float32"	,
	float64	: "float64"	,
			
	array	: elementType=>({type:"array", elementType:elementType})	,
	struct	: "struct"	,
};

const basicTypes = [
	SerialType.uint8	,
	SerialType.int8	,
	SerialType.uint16	,
	SerialType.int16	,
	SerialType.uint32	,
	SerialType.int32	,
	SerialType.uint64	,
	SerialType.int64	,
	
	SerialType.float32	,
	SerialType.float64	,
];
const sizeof = {
	uint8	: 1	,
	int8	: 1	,
	uint16	: 2	,
	int16	: 2	,
	uint32	: 4	,
	int32	: 4	,
	uint64	: 8	,
	int64	: 8	,
			
	float32	: 4	,
	float64	: 8	,
}

export
function NoLength(value=true) {
	if (!(this instanceof NoLength)){
		return new NoLength(value);
	}
	this.value = value;
}
export
function LengthType(value) {
	if (!(this instanceof LengthType)){
		return new LengthType(value);
	}
	this.value = value;
}
////export
////function Callback(value) {
////	if (!(this instanceof Callback)){
////		return new Callback(value);
////	}
////	this.value = value;
////}
export
function ElementAttributes(...values) {
	if (!(this instanceof ElementAttributes)){
		return new ElementAttributes(values);
	}
	this.value = values;
}

export
class Serializer {
	constructor(...attributes) {
		this.attributes = attributes;
	}
	
	getAttribute(Attribute) {
		return [NoLength(false),LengthType(SerialType.uint16), ...this.attributes].reverse().find(a=>a instanceof Attribute).value;
	}
	
	subserializer(...moreAttributes) {
		return new Serializer(...this.attributes, ...moreAttributes);
	}
	
	serialize(type, value) {
		if (basicTypes.includes(type)) {
			let buffer = new Uint8Array(sizeof[type]);
			let view = new DataView(buffer.buffer);
			viewSet(view, type, value);
			return buffer;
		}
		else if (typeof(type) == "object" && type.type == "array") {
			let noLength = this.getAttribute(NoLength);
			let lengthType = this.getAttribute(LengthType);
			let dataOffset = noLength?0:sizeof[lengthType];
			let buffer = new Uint8Array(dataOffset + sizeof[type.elementType]*value.length);
			let view = new DataView(buffer.buffer);
			if (!noLength) {
				viewSet(view, lengthType, value.length);
				view = new DataView(buffer.buffer, dataOffset);
			}
			for (let v of value) {
				viewSet(view, type.elementType, v);
				view = new DataView(buffer.buffer, view.byteOffset + sizeof[type.elementType]);
			}
			return buffer;
		}
		else console.assert(false, "Serialize Type not defined.");
	}
	
	 deserialize(type, buffer, leftOver_callback=()=>{}) {
		if (basicTypes.includes(type)) {
			let view = new DataView(buffer.buffer);
			leftOver_callback(buffer.slice(sizeof[type]));
			return viewGet(view, type);
		}
		else if (typeof(type) == "object" && type.type == "array") {
			let noLength = this.getAttribute(NoLength);
			let lengthType = this.getAttribute(LengthType);
			let view = new DataView(buffer.buffer);
			if (!noLength) {
				let value = new Array(viewGet(view, lengthType));
				view = new DataView(buffer.buffer, sizeof[lengthType]);
				for (let i=0; i<value.length; i++) {
					value[i] = viewGet(view, type.elementType);
					view = new DataView(buffer.buffer, view.byteOffset + sizeof[type.elementType]);
				}
				leftOver_callback(buffer.slice(sizeof[lengthType] * value.length));
				return value;
			}
			else {
				let value = [];
				while (view.byteLength > 0) {
					value.push(viewGet(view, type.elementType));
					view = new DataView(buffer.buffer, view.byteOffset + sizeof[type.elementType]);
				}
				return value;
			}
		}
		else console.assert(false, "Serialize Type not defined.");
	}
}

let defaultSerializer = new Serializer();
export var serialize = (...args)=>defaultSerializer.serialize(...args);
export var deserialize = (...args)=>defaultSerializer.deserialize(...args);

// type must be basictype
function viewSet(view, type, value) {
	view["set"+type[0].toUpperCase()+type.slice(1)](0, value, true);
}
// type must be basictype
function viewGet(view, type) {
	return view["get"+type[0].toUpperCase()+type.slice(1)](0, true);
}
