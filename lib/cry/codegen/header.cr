fun __alloc_buffer_int8(size : Int32) : Int32
  ptr = Pointer(Int8).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_uint8(size : Int32) : Int32
  ptr = Pointer(UInt8).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_int16(size : Int32) : Int32
  ptr = Pointer(Int16).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_uint16(size : Int32) : Int32
  ptr = Pointer(UInt16).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_int32(size : Int32) : Int32
  ptr = Pointer(Int32).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_uint32(size : Int32) : Int32
  ptr = Pointer(UInt32).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_int64(size : Int32) : Int32
  ptr = Pointer(Int64).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_uint64(size : Int32) : Int32
  ptr = Pointer(UInt64).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_float32(size : Int32) : Int32
  ptr = Pointer(Float32).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_float64(size : Int32) : Int32
  ptr = Pointer(Float64).malloc(size)
  ptr.address.to_i32
end

fun __alloc_buffer_void(size : Int32) : Int32
  ptr = Pointer(Void).malloc(size)
  ptr.address.to_i32
end

