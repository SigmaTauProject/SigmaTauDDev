
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
			
	array	: (elementType, length=undefined)=>({type:"array", length, elementType})	,
	staticArray	: (elementType, length)=>({type:"array", length, elementType})	,
	struct	: Cls=>({type:"struct", Cls})	,
	object	: Cls=>({type:"struct", Cls})	,
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
const basicSizeOf = {
	uint8	: 1	,
	int8	: 1	,
	uint16	: 2	,
	int16	: 2	,
	uint32	: 4	,
	int32	: 4	,
	bigUint64	: 8	,
	bigInt64	: 8	,
			
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
	
	sizeOf(type) {
		if (type.constructor == Array)
			return subserializer(...type.slice(1)).sizeOf(type[0]);
		
		if (basicSizeOf[type] != undefined)
			return basicSizeOf[type];
		if (typeof(type) == "object" && type.type == "array") {
			if (type.length != undefined) {
				let valueSize = this.sizeOf(type.elementType);
				if (valueSize == undefined)
					return undefined;
				return valueSize*type.length;
			}
			return undefined;
		}
		if ((typeof(type) == "object" && type.type == "struct")) {
			let valuesSize = 0;
			for (let k of Object.keys(type.Cls).filter(k=>k.startsWith("serial_"))) {
				let vs = this.sizeOf(type.Cls[k]);
				if (vs == undefined)
					return undefined;
				valuesSize += vs;
			}
			return valuesSize;
		}
		return undefined;
	}
	byteSizeOf(type, value) {
		if (type.constructor == Array)
			return subserializer(...type.slice(1)).byteSizeOf(type[0]);
		
		{
			let size = this.sizeOf(type);
			if (size != undefined)
				return  size;
		}
		
		if (typeof(type) == "object" && type.type == "array") {
			let lengthSize;
			if (type.length) {
				console.assert(value.length == type.length);
				lengthSize = 0;
			}
			else {
				if (this.getAttribute(NoLength))
					return undefined;
				lengthSize = this.byteSizeOf(this.getAttribute(LengthType), value.length);
				if (lengthSize == undefined)
					return undefined;
			}
			
			let valueSize = this.sizeOf(type.elementType);
			if (valueSize != undefined)
				return lengthSize + valueSize*value.length;
			let valuesSize = 0;
			for (let v of value) {
				let vs = this.byteSizeOf(type.elementType, v);
				if (vs == undefined)
					return undefined;
				valuesSize += vs;
			};
			return lengthSize + valuesSize;
		}
		if (typeof(type) == "object" && type.type == "struct") {
			let valuesSize = 0;
			for (let k of Object.keys(type.Cls).filter(k=>k.startsWith("serial_"))) {
				let vs = this.byteSizeOf(type.Cls[k], value[k.slice("serial_".length)]);
				if (vs == undefined)
					return undefined;
				valuesSize += vs;
			}
			return valuesSize;
		}
		console.assert(false, "Serialize Type not defined.");
	}
	
	serialize(type, value, buffer=undefined) {
		if (type.constructor == Array)
			return subserializer(...type.slice(1)).serialize(type[0], value, buffer);
		
		function defineBuffer(size) {
			buffer = buffer != undefined && buffer.byteLength >= size
				? new Uint8Array(buffer.buffer, buffer.byteOffset, size)
				: new Uint8Array(size);
		}
		
		if (basicTypes.includes(type)) {
			defineBuffer(basicSizeOf[type]);
			viewSet(dataView(buffer), type, value);
			return buffer;
		}
		if (typeof(type) == "object" && type.type == "array") {
			let noLength;
			if (type.length) {
				console.assert(value.length == type.length);
				noLength = true;
			}
			else {
				noLength = this.getAttribute(NoLength);
			}
			
			let byteLength = this.byteSizeOf(type, value);
			if (byteLength) {
				defineBuffer(byteLength);
				let workingBuffer = buffer;
				if (!noLength)
					workingBuffer = this._serializeTo(this.getAttribute(LengthType), value.length, workingBuffer);
				for (let v of value)
					workingBuffer = this._serializeTo(type.elementType, v, workingBuffer);
			}
			else {
				let builder = [];
				if (!noLength)
					builder.push(this.serialize(this.getAttribute(LengthType), value.length));
				for (let v of value)
					builder.push(this.serialize(type.elementType, v));
				byteLength = builder.sum(b=>b.byteLength);
				defineBuffer(byteLength);
				let workingBuffer = buffer;
				for (let b of builder) {
					this._copyTo(b, workingBuffer);
				}
			}
			return buffer;
		}
		if (typeof(type) == "object" && type.type == "struct") {
			let keys = Object.keys(type.Cls).filter(k=>k.startsWith("serial_")).map(k=>k.slice("serial_".length));
			
			let byteLength = this.byteSizeOf(type, value);
			if (byteLength) {
				defineBuffer(byteLength);
				let workingBuffer = buffer;
				for (let k of keys)
					workingBuffer = this._serializeTo(type.Cls["serial_"+k], value[k], workingBuffer);
			}
			else {
				let builder = [];
				for (let v of value)
					builder.push(this.serialize(type.Cls["serial_"+k], value[k]));
				byteLength = builder.sum(b=>b.byteLength);
				defineBuffer(byteLength);
				let workingBuffer = buffer;
				for (let b of builder) {
					this._copyTo(b, workingBuffer);
				}
			}
			return buffer;
		}
		console.assert(false, "Serialize Type not defined.");
	}
	
	_serializeTo(type, value, workingBuffer) {
		return chopBuffer(workingBuffer, this.serialize(type, value, workingBuffer).byteLength);
	}
	_copyTo(valueBuffer, workingBuffer) {
		workingBuffer.set(valueBuffer, 0);
		return chopBuffer(workingBuffer, valueBuffer.byteLength);
	}
	
	 deserialize(type, buffer, workingBuffer_callback=()=>{}) {
		if (type.constructor == Array)
			return subserializer(...type.slice(1)).deserialize(type[0], buffer, workingBuffer_callback);
		
		if (basicTypes.includes(type)) {
			workingBuffer_callback(chopBuffer(buffer, basicSizeOf[type]));
			return viewGet(dataView(buffer), type);
		}
		if (typeof(type) == "object" && type.type == "array") {
			let length;
			if (type.length)
				length = type.length;
			else if (!this.getAttribute(NoLength))
				length = this.deserialize(this.getAttribute(LengthType), buffer, wb=>buffer=wb);
			
			if (length != undefined) {
				let value = new Array(length);
				for (let i=0; i<length; i++)
					value[i] = this.deserialize(type.elementType, buffer, wb=>buffer=wb);
				workingBuffer_callback(buffer);
				return value;
			}
			else {
				let value = [];
				while (buffer.byteLength > 0)
					value.push(this.deserialize(type.elementType, buffer, wb=>buffer=wb));
				workingBuffer_callback(buffer);
				return value;
			}
		}
		if (typeof(type) == "object" && type.type == "struct") {
			let value = new type.Cls;
			let keys = Object.keys(type.Cls).filter(k=>k.startsWith("serial_")).map(k=>k.slice("serial_".length));
			for (let k of keys)
				value[k] = this.deserialize(type.Cls["serial_"+k], buffer, wb=>buffer=wb)
			return value;
		}
		console.assert(false, "Serialize Type not defined.");
	}
	
}

let defaultSerializer = new Serializer();
export var serialize = (...args)=>defaultSerializer.serialize(...args);
export var deserialize = (...args)=>defaultSerializer.deserialize(...args);

function dataView(buffer) {
	return new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);
}
function chopBuffer(buffer, bytes) {
	return new Uint8Array(buffer.buffer, buffer.byteOffset+bytes, buffer.byteLength-bytes);
}
// type must be basictype
function viewSet(view, type, value) {
	view["set"+type[0].toUpperCase()+type.slice(1)](0, value, true);
}
// type must be basictype
function viewGet(view, type) {
	return view["get"+type[0].toUpperCase()+type.slice(1)](0, true);
}
