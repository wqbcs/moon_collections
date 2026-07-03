///|
pub struct CompactIntMap[V] {
  mut entries : Array[(Int, V)]
  mut fp_cache : UInt64
  mut fp_dirty : Bool
} derive(Debug)

///|
pub fn[V] CompactIntMap::new() -> CompactIntMap[V] {
  { entries: [], fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[V] CompactIntMap::from_array(
  pairs : Array[(Int, V)],
) -> CompactIntMap[V] {
  let m = CompactIntMap::new()
  let mut i = 0
  while i < pairs.length() {
    let (k, v) = pairs[i]
    ignore(CompactIntMap::insert(m, k, v))
    i = i + 1
  }
  m
}

///|
fn[V] CompactIntMap::binary_search(self : CompactIntMap[V], key : Int) -> Int {
  let mut lo = 0
  let mut hi = self.entries.length() - 1
  while lo <= hi {
    let mid = lo + (hi - lo) / 2
    let (k, _) = self.entries[mid]
    if k == key {
      return mid
    } else if k < key {
      lo = mid + 1
    } else {
      hi = mid - 1
    }
  }
  -(lo + 1)
}

///|
pub fn[V] CompactIntMap::insert(
  self : CompactIntMap[V],
  key : Int,
  value : V,
) -> V? {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, old) = self.entries[idx]
    self.entries[idx] = (key, value)
    self.fp_dirty = true
    Some(old)
  } else {
    let insert_pos = -(idx + 1)
    self.entries.insert(insert_pos, (key, value))
    self.fp_dirty = true
    None
  }
}

///|
pub fn[V] CompactIntMap::get(self : CompactIntMap[V], key : Int) -> V? {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, v) = self.entries[idx]
    Some(v)
  } else {
    None
  }
}

///|
pub fn[V] CompactIntMap::contains(self : CompactIntMap[V], key : Int) -> Bool {
  CompactIntMap::binary_search(self, key) >= 0
}

///|
pub fn[V] CompactIntMap::len(self : CompactIntMap[V]) -> Int {
  self.entries.length()
}

///|
pub fn[V] CompactIntMap::is_empty(self : CompactIntMap[V]) -> Bool {
  self.entries.length() == 0
}

///|
pub fn[V] CompactIntMap::remove(self : CompactIntMap[V], key : Int) -> V? {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, v) = self.entries[idx]
    ignore(self.entries.remove(idx))
    self.fp_dirty = true
    Some(v)
  } else {
    None
  }
}

///|
pub fn[V] CompactIntMap::get_or_insert(
  self : CompactIntMap[V],
  key : Int,
  default : V,
) -> V {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, v) = self.entries[idx]
    v
  } else {
    let insert_pos = -(idx + 1)
    self.entries.insert(insert_pos, (key, default))
    self.fp_dirty = true
    default
  }
}

///|
pub fn[V] CompactIntMap::get_or_insert_with(
  self : CompactIntMap[V],
  key : Int,
  default_fn : () -> V,
) -> V {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, v) = self.entries[idx]
    v
  } else {
    let value = default_fn()
    let insert_pos = -(idx + 1)
    self.entries.insert(insert_pos, (key, value))
    self.fp_dirty = true
    value
  }
}

///|
pub fn[V] CompactIntMap::min_key(self : CompactIntMap[V]) -> Int? {
  if self.entries.length() == 0 {
    None
  } else {
    let (k, _) = self.entries[0]
    Some(k)
  }
}

///|
pub fn[V] CompactIntMap::max_key(self : CompactIntMap[V]) -> Int? {
  if self.entries.length() == 0 {
    None
  } else {
    let (k, _) = self.entries[self.entries.length() - 1]
    Some(k)
  }
}

///|
pub fn[V] CompactIntMap::keys(self : CompactIntMap[V]) -> Iter[Int] {
  self.entries.iter().map(fn(pair : (Int, V)) -> Int { pair.0 })
}

///|
pub fn[V] CompactIntMap::values(self : CompactIntMap[V]) -> Iter[V] {
  self.entries.iter().map(fn(pair : (Int, V)) -> V { pair.1 })
}

///|
pub fn[V] CompactIntMap::iter(self : CompactIntMap[V]) -> Iter[(Int, V)] {
  self.entries.iter()
}

///|
pub fn[V] CompactIntMap::to_array(self : CompactIntMap[V]) -> Array[(Int, V)] {
  self.entries.iter().to_array()
}

///|
pub fn[V] CompactIntMap::keys_array(self : CompactIntMap[V]) -> Array[Int] {
  self.entries.iter().map(fn(pair : (Int, V)) -> Int { pair.0 }).to_array()
}

///|
pub fn[V] CompactIntMap::values_array(self : CompactIntMap[V]) -> Array[V] {
  self.entries.iter().map(fn(pair : (Int, V)) -> V { pair.1 }).to_array()
}

///|
pub fn[V] CompactIntMap::each(
  self : CompactIntMap[V],
  f : (Int, V) -> Unit,
) -> Unit {
  let mut i = 0
  while i < self.entries.length() {
    let (k, v) = self.entries[i]
    f(k, v)
    i = i + 1
  }
}

///|
pub fn[V] CompactIntMap::clear(self : CompactIntMap[V]) -> Unit {
  self.entries = []
  self.fp_dirty = true
}

///|
pub fn[V] CompactIntMap::update(
  self : CompactIntMap[V],
  key : Int,
  f : (V) -> V,
) -> Bool {
  let idx = CompactIntMap::binary_search(self, key)
  if idx >= 0 {
    let (_, v) = self.entries[idx]
    self.entries[idx] = (key, f(v))
    self.fp_dirty = true
    true
  } else {
    false
  }
}

///|
pub impl[V] @traits.Collection for CompactIntMap[V] with fn len(self) -> Int {
  self.entries.length()
}

///|
pub impl[V] @traits.Collection for CompactIntMap[V] with fn is_empty(self) -> Bool {
  self.entries.length() == 0
}

///|
pub impl[V : Hash + Eq] @traits.Deterministic for CompactIntMap[V] with fn fingerprint(
  self,
) -> UInt64 {
  if !self.fp_dirty {
    return self.fp_cache
  }
  let mut h = @fp.fnv_offset_basis
  let mut i = 0
  while i < self.entries.length() {
    h = @fp.fnv1a_hash_int(i, h)
    h = @fp.fnv1a_hash_int(self.entries[i].0, h)
    h = @fp.fnv1a_hash_int(self.entries[i].1.hash(), h)
    i = i + 1
  }
  self.fp_cache = h
  self.fp_dirty = false
  h
}

///|
pub impl[V : Hash + Eq] @traits.Deterministic for CompactIntMap[V] with fn ordered_eq(
  self,
  other,
) -> Bool {
  self == other
}

///|
pub impl[V : Eq] Eq for CompactIntMap[V] with fn equal(
  self : CompactIntMap[V],
  other : CompactIntMap[V],
) -> Bool {
  if self.entries.length() != other.entries.length() {
    return false
  }
  let mut i = 0
  while i < self.entries.length() {
    if self.entries[i] != other.entries[i] {
      return false
    }
    i = i + 1
  }
  true
}
