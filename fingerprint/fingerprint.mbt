///|
pub let fnv_offset_basis : UInt64 = 14695981039346656037UL

///|
pub let fnv_prime : UInt64 = 1099511628211UL

///|
pub fn fnv1a_hash_byte(byte : Int, hash : UInt64) -> UInt64 {
  (hash ^ byte.to_uint64()) * fnv_prime
}

///|
pub fn fnv1a_hash_int(value : Int, hash : UInt64) -> UInt64 {
  let mut h = hash
  let mut uv = value.to_uint64()
  let mut i = 0
  while i < 8 {
    let byte = (uv & 0xFFUL).to_int()
    h = fnv1a_hash_byte(byte, h)
    uv = uv >> 8
    i = i + 1
  }
  h
}

///|
pub fn fnv1a_hash_string(s : String, hash : UInt64) -> UInt64 {
  let mut h = hash
  let mut i = 0
  while i < s.length() {
    h = fnv1a_hash_byte(s[i].to_int(), h)
    i = i + 1
  }
  h
}

///|
pub fn fnv1a_hash_uint64(value : UInt64, hash : UInt64) -> UInt64 {
  let mut h = hash
  let mut v = value
  let mut i = 0
  while i < 8 {
    h = fnv1a_hash_byte((v % 256UL).to_int(), h)
    v = v / 256UL
    i = i + 1
  }
  h
}

///|
pub fn fingerprint_bytes(bytes : Array[Int]) -> UInt64 {
  let mut h = fnv_offset_basis
  let mut i = 0
  while i < bytes.length() {
    h = fnv1a_hash_byte(bytes[i], h)
    i = i + 1
  }
  h
}

///|
pub fn fingerprint_ints(ints : Array[Int]) -> UInt64 {
  let mut h = fnv_offset_basis
  let mut i = 0
  while i < ints.length() {
    h = fnv1a_hash_int(ints[i], h)
    i = i + 1
  }
  h
}

///|
pub fn fingerprint_strings(strings : Array[String]) -> UInt64 {
  let mut h = fnv_offset_basis
  let mut i = 0
  while i < strings.length() {
    h = fnv1a_hash_string(strings[i], h)
    i = i + 1
  }
  h
}

///|
pub fn fingerprint_uint64s(values : Array[UInt64]) -> UInt64 {
  let mut h = fnv_offset_basis
  let mut i = 0
  while i < values.length() {
    h = fnv1a_hash_uint64(values[i], h)
    i = i + 1
  }
  h
}

///|
pub fn combine(a : UInt64, b : UInt64) -> UInt64 {
  fnv1a_hash_uint64(b, a)
}

///|
pub struct RollingFingerprint {
  mut hash : UInt64
  mut count : Int
} derive(Debug, Eq)

///|
pub fn RollingFingerprint::new() -> RollingFingerprint {
  { hash: fnv_offset_basis, count: 0 }
}

///|
pub fn RollingFingerprint::from_hash(
  hash : UInt64,
  count : Int,
) -> RollingFingerprint {
  { hash, count }
}

///|
pub fn RollingFingerprint::update_int(
  self : RollingFingerprint,
  value : Int,
) -> Unit {
  self.hash = fnv1a_hash_int(value, self.hash)
  self.count = self.count + 1
}

///|
pub fn RollingFingerprint::update_string(
  self : RollingFingerprint,
  value : String,
) -> Unit {
  self.hash = fnv1a_hash_string(value, self.hash)
  self.count = self.count + 1
}

///|
pub fn RollingFingerprint::update_uint64(
  self : RollingFingerprint,
  value : UInt64,
) -> Unit {
  self.hash = fnv1a_hash_uint64(value, self.hash)
  self.count = self.count + 1
}

///|
pub fn RollingFingerprint::update_byte(
  self : RollingFingerprint,
  value : Int,
) -> Unit {
  self.hash = fnv1a_hash_byte(value, self.hash)
  self.count = self.count + 1
}

///|
pub fn RollingFingerprint::hash(self : RollingFingerprint) -> UInt64 {
  self.hash
}

///|
pub fn RollingFingerprint::count(self : RollingFingerprint) -> Int {
  self.count
}

///|
pub fn RollingFingerprint::is_empty(self : RollingFingerprint) -> Bool {
  self.count == 0
}

///|
pub fn RollingFingerprint::combine(
  self : RollingFingerprint,
  other : RollingFingerprint,
) -> RollingFingerprint {
  {
    hash: fnv1a_hash_uint64(other.hash, self.hash),
    count: self.count + other.count,
  }
}

///|
pub fn RollingFingerprint::reset(self : RollingFingerprint) -> Unit {
  self.hash = fnv_offset_basis
  self.count = 0
}
