///|
pub struct SortedMap[K, V] {
  mut entries : Array[(K, V)]
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl[K : Debug, V : Debug] Debug for SortedMap[K, V] with fn to_repr(self) -> Repr {
  Repr::ctor("SortedMap", [(Some("entries"), to_repr(self.entries))])
}

///|
pub fn[K, V] SortedMap::new() -> SortedMap[K, V] {
  { entries: [], fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[K : Compare, V] SortedMap::from_array(
  pairs : Array[(K, V)],
) -> SortedMap[K, V] {
  let m = SortedMap::new()
  let mut i = 0
  while i < pairs.length() {
    ignore(SortedMap::insert(m, pairs[i].0, pairs[i].1))
    i = i + 1
  }
  m
}

///|
pub fn[K, V] SortedMap::from_sorted_entries(
  entries : Array[(K, V)],
) -> SortedMap[K, V] {
  { entries, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[K : Compare, V] SortedMap::clone(self : SortedMap[K, V]) -> SortedMap[K, V] {
  SortedMap::from_array(SortedMap::to_array(self))
}

///|
fn[K : Compare, V] SortedMap::binary_search(
  self : SortedMap[K, V],
  key : K,
) -> Int {
  let mut lo = 0
  let mut hi = self.entries.length() - 1
  while lo <= hi {
    let mid = lo + (hi - lo) / 2
    let (k, _) = self.entries[mid]
    let cmp = key.compare(k)
    if cmp == 0 {
      return mid
    } else if cmp < 0 {
      hi = mid - 1
    } else {
      lo = mid + 1
    }
  }
  -(lo + 1)
}

///|
pub fn[K : Compare, V] SortedMap::insert(
  self : SortedMap[K, V],
  key : K,
  value : V,
) -> V? {
  let idx = SortedMap::binary_search(self, key)
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
pub fn[K : Compare, V] SortedMap::get(self : SortedMap[K, V], key : K) -> V? {
  let idx = SortedMap::binary_search(self, key)
  if idx >= 0 {
    Some(self.entries[idx].1)
  } else {
    None
  }
}

///|
pub fn[K : Compare, V] SortedMap::contains(
  self : SortedMap[K, V],
  key : K,
) -> Bool {
  SortedMap::binary_search(self, key) >= 0
}

///|
pub fn[K, V] SortedMap::len(self : SortedMap[K, V]) -> Int {
  self.entries.length()
}

///|
pub fn[K, V] SortedMap::is_empty(self : SortedMap[K, V]) -> Bool {
  self.entries.length() == 0
}

///|
pub fn[K : Compare, V] SortedMap::remove(self : SortedMap[K, V], key : K) -> V? {
  let idx = SortedMap::binary_search(self, key)
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
pub fn[K, V] SortedMap::min_key(self : SortedMap[K, V]) -> K? {
  if self.entries.length() == 0 {
    None
  } else {
    Some(self.entries[0].0)
  }
}

///|
pub fn[K, V] SortedMap::max_key(self : SortedMap[K, V]) -> K? {
  if self.entries.length() == 0 {
    None
  } else {
    Some(self.entries[self.entries.length() - 1].0)
  }
}

///|
pub fn[K, V] SortedMap::keys(self : SortedMap[K, V]) -> Iter[K] {
  self.entries.iter().map(fn(pair : (K, V)) -> K { pair.0 })
}

///|
pub fn[K, V] SortedMap::values(self : SortedMap[K, V]) -> Iter[V] {
  self.entries.iter().map(fn(pair : (K, V)) -> V { pair.1 })
}

///|
pub fn[K, V] SortedMap::iter(self : SortedMap[K, V]) -> Iter[(K, V)] {
  self.entries.iter()
}

///|
pub fn[K, V] SortedMap::each(
  self : SortedMap[K, V],
  f : (K, V) -> Unit,
) -> Unit {
  let mut i = 0
  while i < self.entries.length() {
    f(self.entries[i].0, self.entries[i].1)
    i = i + 1
  }
}

///|
pub fn[K, V] SortedMap::clear(self : SortedMap[K, V]) -> Unit {
  self.entries = []
  self.fp_dirty = true
}

///|
pub fn[K : Compare, V] SortedMap::update(
  self : SortedMap[K, V],
  key : K,
  f : (V) -> V,
) -> Bool {
  let idx = SortedMap::binary_search(self, key)
  if idx >= 0 {
    let (k, v) = self.entries[idx]
    self.entries[idx] = (k, f(v))
    self.fp_dirty = true
    true
  } else {
    false
  }
}

///|
pub fn[K : Compare, V] SortedMap::range(
  self : SortedMap[K, V],
  from : K,
  to : K,
) -> Array[(K, V)] {
  if self.entries.length() == 0 || from.compare(to) > 0 {
    return []
  }
  // Use binary_search to find the start index (first key >= from)
  let idx = SortedMap::binary_search(self, from)
  let lo = if idx >= 0 { idx } else { -(idx + 1) }
  if lo >= self.entries.length() {
    return []
  }
  // Linear scan from start index while key <= to
  let result : Array[(K, V)] = []
  let mut i = lo
  while i < self.entries.length() {
    let (k, v) = self.entries[i]
    if k.compare(to) <= 0 {
      result.push((k, v))
    } else {
      break
    }
    i = i + 1
  }
  result
}

///|
pub fn[K : Compare, V] SortedMap::floor(
  self : SortedMap[K, V],
  key : K,
) -> (K, V)? {
  let idx = SortedMap::binary_search(self, key)
  if idx >= 0 {
    Some(self.entries[idx])
  } else {
    let insert_pos = -(idx + 1)
    if insert_pos > 0 {
      Some(self.entries[insert_pos - 1])
    } else {
      None
    }
  }
}

///|
pub fn[K, V] SortedMap::retain(
  self : SortedMap[K, V],
  pred : (K, V) -> Bool,
) -> Unit {
  let new_entries : Array[(K, V)] = []
  let mut i = 0
  while i < self.entries.length() {
    let (k, v) = self.entries[i]
    if pred(k, v) {
      new_entries.push((k, v))
    }
    i = i + 1
  }
  self.entries = new_entries
  self.fp_dirty = true
}

///|
pub fn[K : Compare, V] SortedMap::ceil(
  self : SortedMap[K, V],
  key : K,
) -> (K, V)? {
  let idx = SortedMap::binary_search(self, key)
  let pos = if idx >= 0 { idx } else { -(idx + 1) }
  if pos < self.entries.length() {
    Some(self.entries[pos])
  } else {
    None
  }
}

///|
pub fn[K, V] SortedMap::filter(
  self : SortedMap[K, V],
  pred : (K, V) -> Bool,
) -> SortedMap[K, V] {
  let new_entries : Array[(K, V)] = []
  let mut i = 0
  while i < self.entries.length() {
    let (k, v) = self.entries[i]
    if pred(k, v) {
      new_entries.push((k, v))
    }
    i = i + 1
  }
  { entries: new_entries, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[K, V, R] SortedMap::map_values(
  self : SortedMap[K, V],
  f : (V) -> R,
) -> SortedMap[K, R] {
  let new_entries : Array[(K, R)] = []
  let mut i = 0
  while i < self.entries.length() {
    new_entries.push((self.entries[i].0, f(self.entries[i].1)))
    i = i + 1
  }
  { entries: new_entries, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[K : Compare, V] SortedMap::merge(
  self : SortedMap[K, V],
  other : SortedMap[K, V],
  resolve : (V, V) -> V,
) -> SortedMap[K, V] {
  // Two-pointer merge on sorted arrays, O(n+m)
  let new_entries : Array[(K, V)] = []
  let mut i = 0
  let mut j = 0
  while i < self.entries.length() && j < other.entries.length() {
    let (k1, v1) = self.entries[i]
    let (k2, v2) = other.entries[j]
    let cmp = k1.compare(k2)
    if cmp < 0 {
      new_entries.push((k1, v1))
      i = i + 1
    } else if cmp > 0 {
      new_entries.push((k2, v2))
      j = j + 1
    } else {
      new_entries.push((k1, resolve(v1, v2)))
      i = i + 1
      j = j + 1
    }
  }
  while i < self.entries.length() {
    new_entries.push(self.entries[i])
    i = i + 1
  }
  while j < other.entries.length() {
    new_entries.push(other.entries[j])
    j = j + 1
  }
  { entries: new_entries, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn[K : Compare, V] SortedMap::get_or_insert(
  self : SortedMap[K, V],
  key : K,
  default : V,
) -> V {
  match SortedMap::get(self, key) {
    Some(v) => v
    None => {
      ignore(SortedMap::insert(self, key, default))
      default
    }
  }
}

///|
pub fn[K : Compare, V] SortedMap::get_or_insert_with(
  self : SortedMap[K, V],
  key : K,
  default_fn : () -> V,
) -> V {
  match SortedMap::get(self, key) {
    Some(v) => v
    None => {
      let value = default_fn()
      ignore(SortedMap::insert(self, key, value))
      value
    }
  }
}

///|
pub fn[K : Compare, V] SortedMap::lower_bound(
  self : SortedMap[K, V],
  key : K,
) -> (K, V)? {
  let idx = SortedMap::binary_search(self, key)
  let pos = if idx >= 0 { idx } else { -(idx + 1) }
  if pos < self.entries.length() {
    Some(self.entries[pos])
  } else {
    None
  }
}

///|
pub fn[K : Compare, V] SortedMap::upper_bound(
  self : SortedMap[K, V],
  key : K,
) -> (K, V)? {
  let idx = SortedMap::binary_search(self, key)
  let pos = if idx >= 0 { idx + 1 } else { -(idx + 1) }
  if pos < self.entries.length() {
    Some(self.entries[pos])
  } else {
    None
  }
}

///|
pub impl[K, V] @traits.Collection for SortedMap[K, V] with fn len(self) -> Int {
  self.entries.length()
}

///|
pub impl[K, V] @traits.Collection for SortedMap[K, V] with fn is_empty(self) -> Bool {
  self.entries.length() == 0
}

///|
pub impl[K : Compare + Hash + Eq, V : Hash + Eq] @traits.Deterministic for SortedMap[
  K,
  V,
] with fn fingerprint(self) -> UInt64 {
  if !self.fp_dirty {
    return self.fp_cache
  }
  let mut h = @fp.fnv_offset_basis
  let mut i = 0
  while i < self.entries.length() {
    h = @fp.fnv1a_hash_int(i, h)
    h = @fp.fnv1a_hash_int(self.entries[i].0.hash(), h)
    h = @fp.fnv1a_hash_int(self.entries[i].1.hash(), h)
    i = i + 1
  }
  self.fp_cache = h
  self.fp_dirty = false
  h
}

///|
pub impl[K : Compare + Hash + Eq, V : Hash + Eq] @traits.Deterministic for SortedMap[
  K,
  V,
] with fn ordered_eq(self, other) -> Bool {
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

///|
pub fn[K, V] SortedMap::to_array(self : SortedMap[K, V]) -> Array[(K, V)] {
  self.entries.iter().to_array()
}

///|
pub fn[K, V] SortedMap::keys_array(self : SortedMap[K, V]) -> Array[K] {
  self.entries.iter().map(fn(pair : (K, V)) -> K { pair.0 }).to_array()
}

///|
pub fn[K, V] SortedMap::values_array(self : SortedMap[K, V]) -> Array[V] {
  self.entries.iter().map(fn(pair : (K, V)) -> V { pair.1 }).to_array()
}

///|
pub impl[K : Eq, V : Eq] Eq for SortedMap[K, V] with fn equal(
  self : SortedMap[K, V],
  other : SortedMap[K, V],
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
