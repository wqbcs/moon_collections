///|
pub struct BitSet {
  bits : Array[UInt64]
  mut len : Int
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl Eq for BitSet with fn equal(self, other) -> Bool {
  if self.len != other.len {
    return false
  }
  let mut i = 0
  while i < self.bits.length() {
    if self.bits[i] != other.bits[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub impl Debug for BitSet with fn to_repr(self) -> Repr {
  Repr::ctor("BitSet", [
    (Some("bits"), to_repr(self.bits)),
    (Some("len"), to_repr(self.len)),
  ])
}

///|
pub fn BitSet::new(capacity : Int) -> BitSet {
  let bits_per_block = 64
  let cap = if capacity <= 0 { 0 } else { capacity }
  let num_blocks = if cap == 0 {
    1
  } else {
    (cap + bits_per_block - 1) / bits_per_block
  }
  {
    bits: Array::make(num_blocks, 0UL),
    len: cap,
    fp_cache: 0UL,
    fp_dirty: true,
  }
}

///|
pub fn BitSet::from_indices(indices : Array[Int]) -> BitSet {
  let mut max_idx = 0
  let mut i = 0
  while i < indices.length() {
    if indices[i] > max_idx {
      max_idx = indices[i]
    }
    i = i + 1
  }
  let bs = BitSet::new(max_idx + 1)
  let mut j = 0
  while j < indices.length() {
    bs.set(indices[j])
    j = j + 1
  }
  bs
}

///|
fn BitSet::ensure_capacity(self : BitSet, index : Int) -> Unit {
  let bits_per_block = 64
  let needed = index / bits_per_block + 1
  while self.bits.length() < needed {
    self.bits.push(0UL)
  }
  if index >= self.len {
    self.len = index + 1
  }
  self.fp_dirty = true
}

///|
pub fn BitSet::set(self : BitSet, index : Int) -> Unit {
  if index < 0 {
    return
  }
  BitSet::ensure_capacity(self, index)
  let bits_per_block = 64
  let bi = index / bits_per_block
  let bo = index % bits_per_block
  let mask = 1UL << bo
  self.bits[bi] = self.bits[bi] | mask
  self.fp_dirty = true
}

///|
pub fn BitSet::clear(self : BitSet, index : Int) -> Unit {
  if index < 0 {
    return
  }
  let bits_per_block = 64
  let bi = index / bits_per_block
  if bi >= self.bits.length() {
    return
  }
  let bo = index % bits_per_block
  let mask = (1UL << bo).lnot()
  self.bits[bi] = self.bits[bi] & mask
  self.fp_dirty = true
}

///|
pub fn BitSet::toggle(self : BitSet, index : Int) -> Unit {
  if index < 0 {
    return
  }
  BitSet::ensure_capacity(self, index)
  let bits_per_block = 64
  let bi = index / bits_per_block
  let bo = index % bits_per_block
  let mask = 1UL << bo
  self.bits[bi] = self.bits[bi] ^ mask
  self.fp_dirty = true
}

///|
pub fn BitSet::contains(self : BitSet, index : Int) -> Bool {
  if index < 0 {
    return false
  }
  let bits_per_block = 64
  let bi = index / bits_per_block
  if bi >= self.bits.length() {
    return false
  }
  let bo = index % bits_per_block
  let shifted = self.bits[bi] >> bo
  (shifted & 1UL) != 0UL
}

///|
pub fn BitSet::count_ones(self : BitSet) -> Int {
  let mut total = 0
  let mut i = 0
  while i < self.bits.length() {
    total = total + self.bits[i].popcnt()
    i = i + 1
  }
  total
}

///|
pub fn BitSet::count_zeros(self : BitSet) -> Int {
  self.len - BitSet::count_ones(self)
}

///|
pub fn BitSet::is_empty(self : BitSet) -> Bool {
  BitSet::count_ones(self) == 0
}

///|
pub fn BitSet::length(self : BitSet) -> Int {
  self.len
}

///|
pub fn BitSet::clone(self : BitSet) -> BitSet {
  let new_bits : Array[UInt64] = []
  let mut i = 0
  while i < self.bits.length() {
    new_bits.push(self.bits[i])
    i = i + 1
  }
  { bits: new_bits, len: self.len, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn BitSet::extend_(self : BitSet, additional : Int) -> Unit {
  if additional <= 0 {
    return
  }
  let bits_per_block = 64
  let new_len = self.len + additional
  let needed = (new_len + bits_per_block - 1) / bits_per_block
  while self.bits.length() < needed {
    self.bits.push(0UL)
  }
  self.len = new_len
  self.fp_dirty = true
}

///|
pub fn BitSet::union(self : BitSet, other : BitSet) -> BitSet {
  let max_len = if self.bits.length() > other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  let result = self.clone()
  while result.bits.length() < max_len {
    result.bits.push(0UL)
  }
  let mut i = 0
  while i < other.bits.length() {
    result.bits[i] = result.bits[i] | other.bits[i]
    i = i + 1
  }
  if other.len > result.len {
    result.len = other.len
  }
  result
}

///|
pub fn BitSet::intersect(self : BitSet, other : BitSet) -> BitSet {
  let min_len = if self.bits.length() < other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  let result = BitSet::new(
    if self.len > other.len {
      self.len
    } else {
      other.len
    },
  )
  while result.bits.length() < min_len {
    result.bits.push(0UL)
  }
  let mut i = 0
  while i < min_len {
    result.bits[i] = self.bits[i] & other.bits[i]
    i = i + 1
  }
  result
}

///|
pub fn BitSet::difference(self : BitSet, other : BitSet) -> BitSet {
  let max_len = if self.bits.length() > other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  let result = self.clone()
  while result.bits.length() < max_len {
    result.bits.push(0UL)
  }
  let mut i = 0
  while i < other.bits.length() && i < result.bits.length() {
    result.bits[i] = result.bits[i] & other.bits[i].lnot()
    i = i + 1
  }
  result
}

///|
pub fn BitSet::symmetric_difference(self : BitSet, other : BitSet) -> BitSet {
  let max_len = if self.bits.length() > other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  let result = self.clone()
  while result.bits.length() < max_len {
    result.bits.push(0UL)
  }
  let mut i = 0
  while i < other.bits.length() {
    result.bits[i] = result.bits[i] ^ other.bits[i]
    i = i + 1
  }
  if other.len > result.len {
    result.len = other.len
  }
  result
}

///|
pub fn BitSet::complement(self : BitSet) -> BitSet {
  if self.len == 0 {
    return BitSet::none()
  }
  let result = self.clone()
  let mut i = 0
  while i < result.bits.length() {
    result.bits[i] = result.bits[i].lnot()
    i = i + 1
  }
  // mask out bits beyond self.len in the last block
  let bits_per_block = 64
  let last_bit_count = self.len % bits_per_block
  if last_bit_count != 0 {
    let last_block = result.bits.length() - 1
    let mask = (1UL << last_bit_count) - 1UL
    result.bits[last_block] = result.bits[last_block] & mask
  }
  result
}

///|
pub fn BitSet::is_subset(self : BitSet, other : BitSet) -> Bool {
  let mut i = 0
  while i < self.bits.length() {
    if i < other.bits.length() {
      let check = self.bits[i] & other.bits[i].lnot()
      if check != 0UL {
        return false
      }
    } else if self.bits[i] != 0UL {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn BitSet::is_superset(self : BitSet, other : BitSet) -> Bool {
  BitSet::is_subset(other, self)
}

///|
pub fn BitSet::is_disjoint(self : BitSet, other : BitSet) -> Bool {
  let min_len = if self.bits.length() < other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  let mut i = 0
  while i < min_len {
    let check = self.bits[i] & other.bits[i]
    if check != 0UL {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn BitSet::to_bit_string(self : BitSet) -> String {
  let chars : Array[String] = Array::make(self.len, "0")
  let mut i = 0
  while i < self.len {
    if BitSet::contains(self, i) {
      chars[i] = "1"
    }
    i = i + 1
  }
  chars.join("")
}

///|
pub fn BitSet::clear_all(self : BitSet) -> Unit {
  let mut i = 0
  while i < self.bits.length() {
    self.bits[i] = 0UL
    i = i + 1
  }
  self.fp_dirty = true
}

///|
pub fn BitSet::set_all(self : BitSet) -> Unit {
  if self.len == 0 {
    return
  }
  let mut i = 0
  while i < self.bits.length() {
    self.bits[i] = 0UL.lnot()
    i = i + 1
  }
  // mask out bits beyond self.len in the last block
  let bits_per_block = 64
  let last_bit_count = self.len % bits_per_block
  if last_bit_count != 0 {
    let last_block = self.bits.length() - 1
    let mask = (1UL << last_bit_count) - 1UL
    self.bits[last_block] = self.bits[last_block] & mask
  }
  self.fp_dirty = true
}

///|
pub fn BitSet::none() -> BitSet {
  { bits: [0UL], len: 0, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn BitSet::capacity(self : BitSet) -> Int {
  self.bits.length() * 64
}

///|
pub fn BitSet::first_one(self : BitSet) -> Int? {
  let bits_per_block = 64
  let mut block = 0
  while block < self.bits.length() {
    if self.bits[block] != 0UL {
      let base = block * bits_per_block
      let limit = if base + bits_per_block < self.len {
        base + bits_per_block
      } else {
        self.len
      }
      let mut i = base
      while i < limit {
        if BitSet::contains(self, i) {
          return Some(i)
        }
        i = i + 1
      }
    }
    block = block + 1
  }
  None
}

///|
pub fn BitSet::last_one(self : BitSet) -> Int? {
  if self.len == 0 {
    return None
  }
  let bits_per_block = 64
  let mut block = self.bits.length() - 1
  while block >= 0 {
    if self.bits[block] != 0UL {
      let base = block * bits_per_block
      let limit = if base + bits_per_block < self.len {
        base + bits_per_block
      } else {
        self.len
      }
      let mut i = limit - 1
      while i >= base {
        if BitSet::contains(self, i) {
          return Some(i)
        }
        i = i - 1
      }
    }
    block = block - 1
  }
  None
}

///|
pub fn BitSet::next_one(self : BitSet, from : Int) -> Int? {
  if from < 0 || from >= self.len {
    return None
  }
  let bits_per_block = 64
  let start_block = from / bits_per_block
  let mut block = start_block
  while block < self.bits.length() {
    if self.bits[block] != 0UL {
      let base = block * bits_per_block
      let start_i = if block == start_block { from } else { base }
      let limit = if base + bits_per_block < self.len {
        base + bits_per_block
      } else {
        self.len
      }
      let mut i = start_i
      while i < limit {
        if BitSet::contains(self, i) {
          return Some(i)
        }
        i = i + 1
      }
    }
    block = block + 1
  }
  None
}

///|
pub fn BitSet::prev_one(self : BitSet, from : Int) -> Int? {
  if from < 0 || self.len == 0 {
    return None
  }
  let start = if from < self.len { from } else { self.len - 1 }
  let bits_per_block = 64
  let start_block = start / bits_per_block
  let mut block = start_block
  while block >= 0 {
    if self.bits[block] != 0UL {
      let base = block * bits_per_block
      let end_i = if block == start_block {
        start
      } else {
        base + bits_per_block - 1
      }
      let limit = base
      let mut i = if end_i >= self.len { self.len - 1 } else { end_i }
      while i >= limit {
        if BitSet::contains(self, i) {
          return Some(i)
        }
        i = i - 1
      }
    }
    block = block - 1
  }
  None
}

///|
pub fn BitSet::to_indices(self : BitSet) -> Array[Int] {
  let result : Array[Int] = []
  let mut i = 0
  while i < self.len {
    if BitSet::contains(self, i) {
      result.push(i)
    }
    i = i + 1
  }
  result
}

///|
pub fn BitSet::resize(self : BitSet, new_len : Int) -> Unit {
  if new_len < 0 {
    return
  }
  let bits_per_block = 64
  let needed = (new_len + bits_per_block - 1) / bits_per_block
  while self.bits.length() < needed {
    self.bits.push(0UL)
  }
  self.len = new_len
  self.fp_dirty = true
}

///|
pub fn BitSet::truncate(self : BitSet, new_len : Int) -> Unit {
  if new_len < 0 || new_len >= self.len {
    return
  }
  let mut i = new_len
  while i < self.len {
    BitSet::clear(self, i)
    i = i + 1
  }
  self.len = new_len
  self.fp_dirty = true
}

///|
pub fn BitSet::is_strict_subset(self : BitSet, other : BitSet) -> Bool {
  if !BitSet::is_subset(self, other) {
    return false
  }
  self.count_ones() < other.count_ones()
}

///|
pub fn BitSet::any(self : BitSet) -> Bool {
  BitSet::count_ones(self) > 0
}

///|
pub fn BitSet::all_set(self : BitSet) -> Bool {
  BitSet::count_ones(self) == self.len
}

///|
pub fn BitSet::first_zero(self : BitSet) -> Int? {
  let bits_per_block = 64
  let mut block = 0
  while block < self.bits.length() {
    let base = block * bits_per_block
    let limit = if base + bits_per_block < self.len {
      base + bits_per_block
    } else {
      self.len
    }
    let effective_bits = limit - base
    // Skip blocks entirely beyond self.len (after truncate, bits.length > needed)
    if effective_bits <= 0 {
      block = block + 1
      continue
    }
    let all_ones = 0UL.lnot()
    let block_ones_mask = if effective_bits < bits_per_block {
      (1UL << effective_bits) - 1UL
    } else {
      all_ones
    }
    if (self.bits[block] & block_ones_mask) != block_ones_mask {
      let mut i = base
      while i < limit {
        if !BitSet::contains(self, i) {
          return Some(i)
        }
        i = i + 1
      }
    }
    block = block + 1
  }
  None
}

///|
pub fn BitSet::last_zero(self : BitSet) -> Int? {
  if self.len == 0 {
    return None
  }
  let bits_per_block = 64
  let mut block = self.bits.length() - 1
  while block >= 0 {
    let base = block * bits_per_block
    let limit = if base + bits_per_block < self.len {
      base + bits_per_block
    } else {
      self.len
    }
    let effective_bits = limit - base
    // Skip blocks entirely beyond self.len (after truncate, bits.length > needed)
    if effective_bits <= 0 {
      block = block - 1
      continue
    }
    let all_ones = 0UL.lnot()
    let block_ones_mask = if effective_bits < bits_per_block {
      (1UL << effective_bits) - 1UL
    } else {
      all_ones
    }
    if (self.bits[block] & block_ones_mask) != block_ones_mask {
      let mut i = limit - 1
      while i >= base {
        if !BitSet::contains(self, i) {
          return Some(i)
        }
        i = i - 1
      }
    }
    block = block - 1
  }
  None
}

///|
pub fn BitSet::iter_ones(self : BitSet) -> Iter[Int] {
  BitSet::to_indices(self).iter()
}

///|
pub fn BitSet::iter_zeros(self : BitSet) -> Iter[Int] {
  let result : Array[Int] = []
  let mut i = 0
  while i < self.len {
    if !BitSet::contains(self, i) {
      result.push(i)
    }
    i = i + 1
  }
  result.iter()
}

///|
pub fn BitSet::union_with(self : BitSet, other : BitSet) -> Unit {
  let max_len = if self.bits.length() > other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  while self.bits.length() < max_len {
    self.bits.push(0UL)
  }
  let mut i = 0
  while i < other.bits.length() {
    self.bits[i] = self.bits[i] | other.bits[i]
    i = i + 1
  }
  if other.len > self.len {
    self.len = other.len
  }
  self.fp_dirty = true
}

///|
pub fn BitSet::intersect_with(self : BitSet, other : BitSet) -> Unit {
  let mut i = 0
  while i < self.bits.length() {
    if i < other.bits.length() {
      self.bits[i] = self.bits[i] & other.bits[i]
    } else {
      self.bits[i] = 0UL
    }
    i = i + 1
  }
  if other.len < self.len {
    self.len = other.len
  }
  self.fp_dirty = true
}

///|
pub fn BitSet::difference_with(self : BitSet, other : BitSet) -> Unit {
  let max_len = if self.bits.length() > other.bits.length() {
    self.bits.length()
  } else {
    other.bits.length()
  }
  while self.bits.length() < max_len {
    self.bits.push(0UL)
  }
  let mut i = 0
  while i < other.bits.length() {
    self.bits[i] = self.bits[i] & other.bits[i].lnot()
    i = i + 1
  }
  self.fp_dirty = true
}

///|
pub impl @traits.Collection for BitSet with fn len(self) -> Int {
  self.len
}

///|
pub impl @traits.Collection for BitSet with fn is_empty(self) -> Bool {
  BitSet::count_ones(self) == 0
}

///|
pub impl @traits.Deterministic for BitSet with fn fingerprint(self) -> UInt64 {
  if !self.fp_dirty {
    return self.fp_cache
  }
  let mut h = @fp.fnv_offset_basis
  h = @fp.fnv1a_hash_int(self.len, h)
  let mut i = 0
  while i < self.bits.length() {
    h = @fp.fnv1a_hash_uint64(self.bits[i], h)
    i = i + 1
  }
  self.fp_cache = h
  self.fp_dirty = false
  h
}

///|
pub impl @traits.Deterministic for BitSet with fn ordered_eq(self, other) -> Bool {
  if self.len != other.len {
    return false
  }
  let mut i = 0
  while i < self.bits.length() {
    if self.bits[i] != other.bits[i] {
      return false
    }
    i = i + 1
  }
  true
}
