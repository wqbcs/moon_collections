///|
pub struct BitFlags {
  bits : UInt64
} derive(Debug, Eq)

///|
pub fn BitFlags::new() -> BitFlags {
  { bits: 0UL }
}

///|
pub fn BitFlags::from_bits(bits : UInt64) -> BitFlags {
  { bits, }
}

///|
pub fn BitFlags::all() -> BitFlags {
  { bits: 0UL.lnot() }
}

///|
pub fn BitFlags::contains(self : BitFlags, flag : UInt64) -> Bool {
  (self.bits & flag) == flag
}

///|
pub fn BitFlags::intersects(self : BitFlags, other : BitFlags) -> Bool {
  (self.bits & other.bits) != 0UL
}

///|
pub fn BitFlags::is_empty(self : BitFlags) -> Bool {
  self.bits == 0UL
}

///|
pub fn BitFlags::union(self : BitFlags, other : BitFlags) -> BitFlags {
  { bits: self.bits | other.bits }
}

///|
pub fn BitFlags::intersect(self : BitFlags, other : BitFlags) -> BitFlags {
  { bits: self.bits & other.bits }
}

///|
pub fn BitFlags::difference(self : BitFlags, other : BitFlags) -> BitFlags {
  { bits: self.bits & other.bits.lnot() }
}

///|
pub fn BitFlags::symmetric_difference(
  self : BitFlags,
  other : BitFlags,
) -> BitFlags {
  { bits: self.bits ^ other.bits }
}

///|
pub fn BitFlags::complement(self : BitFlags) -> BitFlags {
  { bits: self.bits.lnot() }
}

///|
pub fn BitFlags::count_ones(self : BitFlags) -> Int {
  self.bits.popcnt()
}

///|
pub fn BitFlags::bits(self : BitFlags) -> UInt64 {
  self.bits
}

///|
pub impl BitAnd for BitFlags with fn land(self, other) {
  { bits: self.bits & other.bits }
}

///|
pub impl BitOr for BitFlags with fn lor(self, other) {
  { bits: self.bits | other.bits }
}

///|
pub impl BitXOr for BitFlags with fn lxor(self, other) {
  { bits: self.bits ^ other.bits }
}

///|
pub fn BitFlags::insert(self : BitFlags, flag : UInt64) -> BitFlags {
  { bits: self.bits | flag }
}

///|
pub fn BitFlags::remove(self : BitFlags, flag : UInt64) -> BitFlags {
  { bits: self.bits & flag.lnot() }
}

///|
pub fn BitFlags::toggle(self : BitFlags, flag : UInt64) -> BitFlags {
  { bits: self.bits ^ flag }
}

///|
pub fn BitFlags::is_subset(self : BitFlags, other : BitFlags) -> Bool {
  (self.bits & other.bits) == self.bits
}

///|
pub fn BitFlags::is_superset(self : BitFlags, other : BitFlags) -> Bool {
  BitFlags::is_subset(other, self)
}

///|
pub fn BitFlags::is_disjoint(self : BitFlags, other : BitFlags) -> Bool {
  (self.bits & other.bits) == 0UL
}

///|
pub fn BitFlags::count_zeros(self : BitFlags) -> Int {
  64 - self.bits.popcnt()
}

///|
pub fn BitFlags::to_bit_string(self : BitFlags) -> String {
  let chars : Array[String] = Array::make(64, "0")
  let mut i = 0
  while i < 64 {
    let shifted = self.bits >> i
    if (shifted & 1UL) != 0UL {
      chars[63 - i] = "1"
    }
    i = i + 1
  }
  chars.join("")
}

///|
pub fn BitFlags::none() -> BitFlags {
  { bits: 0UL }
}

///|
pub fn BitFlags::clear_all(_self : BitFlags) -> BitFlags {
  BitFlags::none()
}

///|
pub fn BitFlags::set_all(_self : BitFlags) -> BitFlags {
  BitFlags::all()
}

///|
pub fn BitFlags::len(self : BitFlags) -> Int {
  self.bits.popcnt()
}

///|
pub impl @traits.Collection for BitFlags with fn len(self) -> Int {
  self.bits.popcnt()
}

///|
pub impl @traits.Collection for BitFlags with fn is_empty(self) -> Bool {
  self.bits == 0UL
}

///|
pub impl @traits.Deterministic for BitFlags with fn fingerprint(self) -> UInt64 {
  @fp.fnv1a_hash_uint64(self.bits, @fp.fnv_offset_basis)
}

///|
pub impl @traits.Deterministic for BitFlags with fn ordered_eq(self, other) -> Bool {
  self.bits == other.bits
}
