///|
pub struct DefaultMap[K, V] {
  map : @indexmap.IndexMap[K, V]
  default_fn : () -> V
} derive(Debug)

///|
pub fn[K : Hash + Eq, V] DefaultMap::new(
  default_fn : () -> V,
) -> DefaultMap[K, V] {
  { map: @indexmap.IndexMap::new(), default_fn }
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::insert(
  self : DefaultMap[K, V],
  key : K,
  value : V,
) -> V? {
  self.map.insert(key, value)
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::get(self : DefaultMap[K, V], key : K) -> V {
  match self.map.get(key) {
    Some(v) => v
    None => (self.default_fn)()
  }
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::get_existing(
  self : DefaultMap[K, V],
  key : K,
) -> V? {
  self.map.get(key)
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::contains(
  self : DefaultMap[K, V],
  key : K,
) -> Bool {
  self.map.contains(key)
}

///|
pub fn[K, V] DefaultMap::len(self : DefaultMap[K, V]) -> Int {
  self.map.len()
}

///|
pub fn[K, V] DefaultMap::is_empty(self : DefaultMap[K, V]) -> Bool {
  self.map.is_empty()
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::remove(
  self : DefaultMap[K, V],
  key : K,
) -> V? {
  self.map.shift_remove(key)
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::get_or_insert(
  self : DefaultMap[K, V],
  key : K,
) -> V {
  self.map.get_or_insert_with(key, self.default_fn)
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::update(
  self : DefaultMap[K, V],
  key : K,
  f : (V) -> V,
) -> Unit {
  let v = match self.map.get(key) {
    Some(existing) => f(existing)
    None => f((self.default_fn)())
  }
  ignore(self.map.insert(key, v))
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::clear(self : DefaultMap[K, V]) -> Unit {
  self.map.clear()
}

///|
pub fn[K, V] DefaultMap::keys(self : DefaultMap[K, V]) -> Iter[K] {
  self.map.keys()
}

///|
pub fn[K, V] DefaultMap::iter(self : DefaultMap[K, V]) -> Iter[(K, V)] {
  self.map.iter()
}

///|
pub fn[K, V] DefaultMap::each(
  self : DefaultMap[K, V],
  f : (K, V) -> Unit,
) -> Unit {
  self.map.each(f)
}

///|
pub impl[K, V] @traits.Collection for DefaultMap[K, V] with fn len(self) -> Int {
  self.map.len()
}

///|
pub impl[K, V] @traits.Collection for DefaultMap[K, V] with fn is_empty(self) -> Bool {
  self.map.is_empty()
}

///|
pub impl[K : Hash + Eq, V : Hash + Eq] @traits.Deterministic for DefaultMap[
  K,
  V,
] with fn fingerprint(self) -> UInt64 {
  self.map.fingerprint()
}

///|
pub impl[K : Hash + Eq, V : Hash + Eq] @traits.Deterministic for DefaultMap[
  K,
  V,
] with fn ordered_eq(self, other) -> Bool {
  self.map.ordered_eq(other.map)
}

///|
pub fn[K, V] DefaultMap::values(self : DefaultMap[K, V]) -> Iter[V] {
  self.map.values()
}

///|
pub fn[K, V] DefaultMap::keys_array(self : DefaultMap[K, V]) -> Array[K] {
  self.map.keys_array()
}

///|
pub fn[K, V] DefaultMap::values_array(self : DefaultMap[K, V]) -> Array[V] {
  self.map.values_array()
}

///|
pub fn[K, V] DefaultMap::each_entry(
  self : DefaultMap[K, V],
  f : (Int, K, V) -> Unit,
) -> Unit {
  let mut i = 0
  self.map.each(fn(k : K, v : V) -> Unit {
    f(i, k, v)
    i = i + 1
  })
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::retain(
  self : DefaultMap[K, V],
  pred : (K, V) -> Bool,
) -> Unit {
  self.map.retain(pred)
}

///|
pub fn[K : Hash + Eq, V] DefaultMap::from_array(
  default_fn : () -> V,
  pairs : Array[(K, V)],
) -> DefaultMap[K, V] {
  let dm = DefaultMap::new(default_fn)
  let mut i = 0
  while i < pairs.length() {
    ignore(DefaultMap::insert(dm, pairs[i].0, pairs[i].1))
    i = i + 1
  }
  dm
}
