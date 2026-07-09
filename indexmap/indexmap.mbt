///|
pub struct Entry[K, V] {
  key : K
  value : V
} derive(Debug, Eq)

///|
pub struct IndexMap[K, V] {
  mut entries : Array[Entry[K, V]]
  mut indices : @hashmap.HashMap[K, Int]
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl[K : Debug, V : Debug] Debug for IndexMap[K, V] with fn to_repr(self) -> Repr {
  Repr::ctor("IndexMap", [(Some("entries"), to_repr(self.entries))])
}

///|
pub fn[K : Hash + Eq, V] IndexMap::new() -> IndexMap[K, V] {
  {
    entries: [],
    indices: @hashmap.HashMap([]),
    fp_cache: @fp.fnv_offset_basis,
    fp_dirty: false,
  }
}

///|
pub fn[K, V] IndexMap::len(self : IndexMap[K, V]) -> Int {
  self.entries.length()
}

///|
pub fn[K, V] IndexMap::is_empty(self : IndexMap[K, V]) -> Bool {
  self.entries.length() == 0
}

///|
pub fn[K : Hash + Eq, V] IndexMap::insert(
  self : IndexMap[K, V],
  key : K,
  value : V,
) -> V? {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let old = self.entries[idx].value
      self.entries[idx] = { key, value }
      Some(old)
    }
    None => {
      let idx = self.entries.length()
      self.entries.push({ key, value })
      self.indices.set(key, idx)
      None
    }
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::get(self : IndexMap[K, V], key : K) -> V? {
  match self.indices.get(key) {
    Some(idx) => Some(self.entries[idx].value)
    None => None
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::contains(
  self : IndexMap[K, V],
  key : K,
) -> Bool {
  self.indices.contains(key)
}

///|
pub fn[K : Hash + Eq, V] IndexMap::get_index_of(
  self : IndexMap[K, V],
  key : K,
) -> Int? {
  self.indices.get(key)
}

///|
pub fn[K, V] IndexMap::get_index(self : IndexMap[K, V], index : Int) -> (K, V)? {
  if index >= 0 && index < self.entries.length() {
    let entry = self.entries[index]
    Some((entry.key, entry.value))
  } else {
    None
  }
}

///|
pub fn[K, V] IndexMap::get_key_at(self : IndexMap[K, V], index : Int) -> K? {
  if index >= 0 && index < self.entries.length() {
    Some(self.entries[index].key)
  } else {
    None
  }
}

///|
pub fn[K, V] IndexMap::get_value_at(self : IndexMap[K, V], index : Int) -> V? {
  if index >= 0 && index < self.entries.length() {
    Some(self.entries[index].value)
  } else {
    None
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::swap_remove(
  self : IndexMap[K, V],
  key : K,
) -> V? {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let removed = self.entries[idx]
      let last = self.entries.length() - 1
      if idx != last {
        let swapped = self.entries[last]
        self.entries[idx] = swapped
        self.indices.set(swapped.key, idx)
      }
      ignore(self.entries.pop())
      self.indices.remove(key)
      Some(removed.value)
    }
    None => None
  }
}

///|
// Shared internal: remove entry at index, return it. Used by shift_remove and remove_entry.
fn[K : Hash + Eq, V] IndexMap::shift_remove_at(
  self : IndexMap[K, V],
  idx : Int,
) -> Entry[K, V] {
  let removed = self.entries[idx]
  ignore(self.entries.remove(idx))
  let mut i = idx
  while i < self.entries.length() {
    self.indices.set(self.entries[i].key, i)
    i = i + 1
  }
  removed
}

///|
pub fn[K : Hash + Eq, V] IndexMap::remove(self : IndexMap[K, V], key : K) -> V? {
  IndexMap::shift_remove(self, key)
}

///|
pub fn[K : Hash + Eq, V] IndexMap::shift_remove(
  self : IndexMap[K, V],
  key : K,
) -> V? {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let removed = IndexMap::shift_remove_at(self, idx)
      self.indices.remove(key)
      Some(removed.value)
    }
    None => None
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::swap_remove_index(
  self : IndexMap[K, V],
  index : Int,
) -> (K, V)? {
  self.fp_dirty = true
  if index < 0 || index >= self.entries.length() {
    return None
  }
  let removed = self.entries[index]
  let last = self.entries.length() - 1
  if index != last {
    let swapped = self.entries[last]
    self.entries[index] = swapped
    self.indices.set(swapped.key, index)
  }
  ignore(self.entries.pop())
  self.indices.remove(removed.key)
  Some((removed.key, removed.value))
}

///|
pub fn[K : Hash + Eq, V] IndexMap::shift_remove_index(
  self : IndexMap[K, V],
  index : Int,
) -> (K, V)? {
  self.fp_dirty = true
  if index < 0 || index >= self.entries.length() {
    return None
  }
  let removed = self.entries[index]
  ignore(self.entries.remove(index))
  let mut i = index
  while i < self.entries.length() {
    self.indices.set(self.entries[i].key, i)
    i = i + 1
  }
  self.indices.remove(removed.key)
  Some((removed.key, removed.value))
}

///|
pub fn[K, V] IndexMap::keys(self : IndexMap[K, V]) -> Iter[K] {
  self.entries.iter().map(fn(entry : Entry[K, V]) -> K { entry.key })
}

///|
pub fn[K, V] IndexMap::values(self : IndexMap[K, V]) -> Iter[V] {
  self.entries.iter().map(fn(entry : Entry[K, V]) -> V { entry.value })
}

///|
pub fn[K, V] IndexMap::iter(self : IndexMap[K, V]) -> Iter[(K, V)] {
  self.entries
  .iter()
  .map(fn(entry : Entry[K, V]) -> (K, V) { (entry.key, entry.value) })
}

///|
pub fn[K, V] IndexMap::each(self : IndexMap[K, V], f : (K, V) -> Unit) -> Unit {
  let mut i = 0
  while i < self.entries.length() {
    f(self.entries[i].key, self.entries[i].value)
    i = i + 1
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::clear(self : IndexMap[K, V]) -> Unit {
  self.fp_dirty = true
  self.entries = []
  self.indices = @hashmap.HashMap([])
}

///|
pub fn[K : Hash + Eq, V] IndexMap::retain(
  self : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> Unit {
  self.fp_dirty = true
  let new_entries : Array[Entry[K, V]] = []
  let removed_keys : Array[K] = []
  let mut i = 0
  while i < self.entries.length() {
    let entry = self.entries[i]
    if pred(entry.key, entry.value) {
      new_entries.push(entry)
    } else {
      removed_keys.push(entry.key)
    }
    i = i + 1
  }
  self.entries = new_entries
  let mut j = 0
  while j < self.entries.length() {
    self.indices.set(self.entries[j].key, j)
    j = j + 1
  }
  let mut k = 0
  while k < removed_keys.length() {
    self.indices.remove(removed_keys[k])
    k = k + 1
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::at(self : IndexMap[K, V], key : K) -> V? {
  match self.indices.get(key) {
    Some(idx) => Some(self.entries[idx].value)
    None => None
  }
}

///|
#alias("_[_]")
pub fn[K : Hash + Eq, V] IndexMap::op_index(
  self : IndexMap[K, V],
  key : K,
) -> V? {
  IndexMap::get(self, key)
}

///|
pub fn[K : Hash + Eq, V] IndexMap::op_set(
  self : IndexMap[K, V],
  key : K,
  value : V,
) -> Unit {
  self.fp_dirty = true
  ignore(IndexMap::insert(self, key, value))
}

///|
pub fn[K : Hash + Eq, V] IndexMap::reverse(self : IndexMap[K, V]) -> Unit {
  self.fp_dirty = true
  self.entries.rev_in_place()
  let mut i = 0
  while i < self.entries.length() {
    self.indices.set(self.entries[i].key, i)
    i = i + 1
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::move_to_front(
  self : IndexMap[K, V],
  key : K,
) -> Bool {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      if idx == 0 {
        return true
      }
      let entry = self.entries[idx]
      let mut i = idx
      while i > 0 {
        self.entries[i] = self.entries[i - 1]
        self.indices.set(self.entries[i].key, i)
        i = i - 1
      }
      self.entries[0] = entry
      self.indices.set(entry.key, 0)
      true
    }
    None => false
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::move_to_back(
  self : IndexMap[K, V],
  key : K,
) -> Bool {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let last = self.entries.length() - 1
      if idx == last {
        return true
      }
      let entry = self.entries[idx]
      let mut i = idx
      while i < last {
        self.entries[i] = self.entries[i + 1]
        self.indices.set(self.entries[i].key, i)
        i = i + 1
      }
      self.entries[last] = entry
      self.indices.set(entry.key, last)
      true
    }
    None => false
  }
}

///|
pub fn[K, V] IndexMap::rev_iter(self : IndexMap[K, V]) -> Iter[(K, V)] {
  self.entries
  .rev_iter()
  .map(fn(entry : Entry[K, V]) -> (K, V) { (entry.key, entry.value) })
}

///|
pub fn[K : Hash + Eq, V] IndexMap::pop_back(self : IndexMap[K, V]) -> (K, V)? {
  match self.entries.pop() {
    Some(entry) => {
      self.fp_dirty = true
      self.indices.remove(entry.key)
      Some((entry.key, entry.value))
    }
    None => None
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::pop_front(self : IndexMap[K, V]) -> (K, V)? {
  if self.entries.length() == 0 {
    return None
  }
  IndexMap::shift_remove_index(self, 0)
}

///|
pub impl[K : Eq, V : Eq] Eq for IndexMap[K, V] with fn equal(
  self : IndexMap[K, V],
  other : IndexMap[K, V],
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

///|
pub fn[K : Hash + Eq, V] IndexMap::from_array(
  pairs : Array[(K, V)],
) -> IndexMap[K, V] {
  let m = IndexMap::new()
  let mut i = 0
  while i < pairs.length() {
    let (k, v) = pairs[i]
    ignore(m.insert(k, v))
    i = i + 1
  }
  m
}

///|
pub fn[K : Hash + Eq, V] IndexMap::clone(
  self : IndexMap[K, V],
) -> IndexMap[K, V] {
  IndexMap::from_array(IndexMap::to_array(self))
}

///|
pub fn[K, V] IndexMap::entries(self : IndexMap[K, V]) -> Array[Entry[K, V]] {
  let result : Array[Entry[K, V]] = []
  let mut i = 0
  while i < self.entries.length() {
    result.push(self.entries[i])
    i = i + 1
  }
  result
}

///|
pub fn[K, V] IndexMap::keys_array(self : IndexMap[K, V]) -> Array[K] {
  let result : Array[K] = []
  let mut i = 0
  while i < self.entries.length() {
    result.push(self.entries[i].key)
    i = i + 1
  }
  result
}

///|
pub fn[K, V] IndexMap::values_array(self : IndexMap[K, V]) -> Array[V] {
  let result : Array[V] = []
  let mut i = 0
  while i < self.entries.length() {
    result.push(self.entries[i].value)
    i = i + 1
  }
  result
}

///|
pub fn[K, V] IndexMap::first(self : IndexMap[K, V]) -> (K, V)? {
  if self.entries.length() == 0 {
    None
  } else {
    let e = self.entries[0]
    Some((e.key, e.value))
  }
}

///|
pub fn[K, V] IndexMap::last(self : IndexMap[K, V]) -> (K, V)? {
  match self.entries.length() {
    0 => None
    n => {
      let e = self.entries[n - 1]
      Some((e.key, e.value))
    }
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::get_or_insert(
  self : IndexMap[K, V],
  key : K,
  default : V,
) -> V {
  match self.indices.get(key) {
    Some(idx) => self.entries[idx].value
    None => {
      self.fp_dirty = true
      let idx = self.entries.length()
      self.entries.push({ key, value: default })
      self.indices.set(key, idx)
      default
    }
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::get_or_insert_with(
  self : IndexMap[K, V],
  key : K,
  default_fn : () -> V,
) -> V {
  match self.indices.get(key) {
    Some(idx) => self.entries[idx].value
    None => {
      self.fp_dirty = true
      let value = default_fn()
      let idx = self.entries.length()
      self.entries.push({ key, value })
      self.indices.set(key, idx)
      value
    }
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::insert_before(
  self : IndexMap[K, V],
  target : K,
  key : K,
  value : V,
) -> Bool {
  self.fp_dirty = true
  match self.indices.get(target) {
    Some(target_idx) =>
      match self.indices.get(key) {
        Some(_) => false
        None => {
          self.entries.insert(target_idx, { key, value })
          self.indices.set(key, target_idx)
          let mut i = target_idx + 1
          while i < self.entries.length() {
            self.indices.set(self.entries[i].key, i)
            i = i + 1
          }
          true
        }
      }
    None => false
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::insert_after(
  self : IndexMap[K, V],
  target : K,
  key : K,
  value : V,
) -> Bool {
  self.fp_dirty = true
  match self.indices.get(target) {
    Some(target_idx) =>
      match self.indices.get(key) {
        Some(_) => false
        None => {
          let insert_idx = target_idx + 1
          self.entries.insert(insert_idx, { key, value })
          self.indices.set(key, insert_idx)
          let mut i = insert_idx + 1
          while i < self.entries.length() {
            self.indices.set(self.entries[i].key, i)
            i = i + 1
          }
          true
        }
      }
    None => false
  }
}

///|
pub fn[K : Hash + Eq + Compare, V] IndexMap::sort_keys(
  self : IndexMap[K, V],
) -> Unit {
  self.fp_dirty = true
  self.entries.sort_by(fn(a : Entry[K, V], b : Entry[K, V]) -> Int {
    a.key.compare(b.key)
  })
  let mut i = 0
  while i < self.entries.length() {
    self.indices.set(self.entries[i].key, i)
    i = i + 1
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::swap_indices(
  self : IndexMap[K, V],
  a : Int,
  b : Int,
) -> Bool {
  self.fp_dirty = true
  if a < 0 || a >= self.entries.length() {
    return false
  }
  if b < 0 || b >= self.entries.length() {
    return false
  }
  if a == b {
    return true
  }
  let entry_a = self.entries[a]
  let entry_b = self.entries[b]
  self.entries[a] = entry_b
  self.entries[b] = entry_a
  self.indices.set(entry_b.key, a)
  self.indices.set(entry_a.key, b)
  true
}

///|
pub fn[K : Hash + Eq, V] IndexMap::update(
  self : IndexMap[K, V],
  key : K,
  f : (V) -> V,
) -> Bool {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      self.entries[idx] = { key, value: f(self.entries[idx].value) }
      true
    }
    None => false
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::update_or_insert(
  self : IndexMap[K, V],
  key : K,
  f : (V) -> V,
  default : V,
) -> V {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let new_value = f(self.entries[idx].value)
      self.entries[idx] = { key, value: new_value }
      new_value
    }
    None => {
      let idx = self.entries.length()
      self.entries.push({ key, value: default })
      self.indices.set(key, idx)
      default
    }
  }
}

///|
pub fn[K : Hash + Eq, V] IndexMap::remove_entry(
  self : IndexMap[K, V],
  key : K,
) -> (K, V)? {
  self.fp_dirty = true
  match self.indices.get(key) {
    Some(idx) => {
      let removed = IndexMap::shift_remove_at(self, idx)
      self.indices.remove(key)
      Some((removed.key, removed.value))
    }
    None => None
  }
}

///|
pub impl[K, V] @traits.Collection for IndexMap[K, V] with fn len(self) -> Int {
  self.entries.length()
}

///|
pub impl[K, V] @traits.Collection for IndexMap[K, V] with fn is_empty(self) -> Bool {
  self.entries.length() == 0
}

///|
pub impl[K : Hash + Eq, V : Hash + Eq] @traits.Deterministic for IndexMap[K, V] with fn fingerprint(
  self,
) -> UInt64 {
  if self.fp_dirty {
    let mut h = @fp.fnv_offset_basis
    let mut i = 0
    while i < self.entries.length() {
      h = @fp.fnv1a_hash_int(i, h)
      h = @fp.fnv1a_hash_int(self.entries[i].key.hash(), h)
      h = @fp.fnv1a_hash_int(self.entries[i].value.hash(), h)
      i = i + 1
    }
    self.fp_cache = h
    self.fp_dirty = false
  }
  self.fp_cache
}

///|
pub impl[K : Hash + Eq, V : Hash + Eq] @traits.Deterministic for IndexMap[K, V] with fn ordered_eq(
  self,
  other,
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

///|
pub fn[K : Hash + Eq, V] IndexMap::retain_keys(
  self : IndexMap[K, V],
  pred : (K) -> Bool,
) -> Unit {
  IndexMap::retain(self, fn(k : K, _v : V) -> Bool { pred(k) })
}

///|
pub fn[K : Hash + Eq, V] IndexMap::filter(
  self : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> IndexMap[K, V] {
  let result = IndexMap::new()
  let mut i = 0
  while i < self.entries.length() {
    let entry = self.entries[i]
    if pred(entry.key, entry.value) {
      ignore(IndexMap::insert(result, entry.key, entry.value))
    }
    i = i + 1
  }
  result
}

///|
pub fn[K : Hash + Eq, V, R] IndexMap::map_values(
  self : IndexMap[K, V],
  f : (V) -> R,
) -> IndexMap[K, R] {
  let result = IndexMap::new()
  let mut i = 0
  while i < self.entries.length() {
    let entry = self.entries[i]
    ignore(IndexMap::insert(result, entry.key, f(entry.value)))
    i = i + 1
  }
  result
}

///|
pub fn[K, V] IndexMap::to_array(self : IndexMap[K, V]) -> Array[(K, V)] {
  self.entries
  .iter()
  .map(fn(entry : Entry[K, V]) -> (K, V) { (entry.key, entry.value) })
  .to_array()
}

///|
pub fn[K : Hash + Eq, V] IndexMap::merge(
  self : IndexMap[K, V],
  other : IndexMap[K, V],
  resolve : (V, V) -> V,
) -> IndexMap[K, V] {
  let result = IndexMap::new()
  self.each(fn(k : K, v : V) -> Unit { ignore(IndexMap::insert(result, k, v)) })
  other.each(fn(k : K, v : V) -> Unit {
    match IndexMap::get(result, k) {
      Some(existing) =>
        ignore(IndexMap::insert(result, k, resolve(existing, v)))
      None => ignore(IndexMap::insert(result, k, v))
    }
  })
  result
}

///|
pub fn[K : Hash + Eq, V] IndexMap::drain(
  self : IndexMap[K, V],
  pred : (K, V) -> Bool,
) -> IndexMap[K, V] {
  let drained = IndexMap::filter(self, pred)
  IndexMap::retain(self, fn(k : K, v : V) -> Bool { !pred(k, v) })
  drained
}

///|
pub fn[K : Hash + Eq, V] IndexMap::has_all(
  self : IndexMap[K, V],
  keys : Array[K],
) -> Bool {
  let mut i = 0
  while i < keys.length() {
    if !self.contains(keys[i]) {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn[K : Hash + Eq, V] IndexMap::has_any(
  self : IndexMap[K, V],
  keys : Array[K],
) -> Bool {
  let mut i = 0
  while i < keys.length() {
    if self.contains(keys[i]) {
      return true
    }
    i = i + 1
  }
  false
}
