///|
pub struct SparseSet[V] {
  sparse : Array[Int]
  dense : Array[Int]
  values : Array[V?]
  mut count : Int
  capacity : Int
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl[V : Debug] Debug for SparseSet[V] with fn to_repr(self) -> Repr {
  Repr::ctor("SparseSet", [
    (Some("dense"), to_repr(self.dense)),
    (Some("values"), to_repr(self.values)),
    (Some("count"), to_repr(self.count)),
    (Some("capacity"), to_repr(self.capacity)),
  ])
}

///|
pub fn[V] SparseSet::new(capacity : Int) -> SparseSet[V] {
  let cap = if capacity <= 0 { 1 } else { capacity }
  {
    sparse: Array::make(cap, -1),
    dense: Array::make(cap, -1),
    values: Array::make(cap, None),
    count: 0,
    capacity: cap,
    fp_cache: 0UL,
    fp_dirty: true,
  }
}

///|
pub fn[V] SparseSet::capacity(self : SparseSet[V]) -> Int {
  self.capacity
}

///|
pub fn[V] SparseSet::len(self : SparseSet[V]) -> Int {
  self.count
}

///|
pub fn[V] SparseSet::is_empty(self : SparseSet[V]) -> Bool {
  self.count == 0
}

///|
pub fn[V] SparseSet::contains(self : SparseSet[V], key : Int) -> Bool {
  if key < 0 || key >= self.capacity {
    return false
  }
  let idx = self.sparse[key]
  idx >= 0 && idx < self.count && self.dense[idx] == key
}

///|
pub fn[V] SparseSet::get(self : SparseSet[V], key : Int) -> V? {
  if key < 0 || key >= self.capacity {
    return None
  }
  let idx = self.sparse[key]
  if idx >= 0 && idx < self.count && self.dense[idx] == key {
    self.values[idx]
  } else {
    None
  }
}

///|
pub fn[V] SparseSet::insert(self : SparseSet[V], key : Int, value : V) -> V? {
  if key < 0 || key >= self.capacity {
    return None
  }
  let idx = self.sparse[key]
  if idx >= 0 && idx < self.count && self.dense[idx] == key {
    let old = self.values[idx]
    self.values[idx] = Some(value)
    self.fp_dirty = true
    old
  } else {
    self.dense[self.count] = key
    self.values[self.count] = Some(value)
    self.sparse[key] = self.count
    self.count = self.count + 1
    self.fp_dirty = true
    None
  }
}

///|
pub fn[V] SparseSet::remove(self : SparseSet[V], key : Int) -> V? {
  if key < 0 || key >= self.capacity {
    return None
  }
  let idx = self.sparse[key]
  if idx < 0 || idx >= self.count || self.dense[idx] != key {
    return None
  }
  let removed = self.values[idx]
  let last = self.count - 1
  if idx != last {
    let last_key = self.dense[last]
    self.dense[idx] = last_key
    self.values[idx] = self.values[last]
    self.sparse[last_key] = idx
  }
  self.sparse[key] = -1
  self.values[self.count - 1] = None
  self.count = self.count - 1
  self.fp_dirty = true
  removed
}

///|
pub fn[V] SparseSet::clear(self : SparseSet[V]) -> Unit {
  let mut i = 0
  while i < self.count {
    self.sparse[self.dense[i]] = -1
    self.values[i] = None
    i = i + 1
  }
  self.count = 0
  self.fp_dirty = true
}

///|
pub fn[V] SparseSet::each(self : SparseSet[V], f : (Int, V) -> Unit) -> Unit {
  let mut i = 0
  while i < self.count {
    match self.values[i] {
      Some(v) => f(self.dense[i], v)
      None => ()
    }
    i = i + 1
  }
}

///|
pub fn[V] SparseSet::iter(self : SparseSet[V]) -> Iter[(Int, V)] {
  let result : Array[(Int, V)] = []
  let mut i = 0
  while i < self.count {
    match self.values[i] {
      Some(v) => result.push((self.dense[i], v))
      None => ()
    }
    i = i + 1
  }
  result.iter()
}

///|
pub fn[V] SparseSet::keys_array(self : SparseSet[V]) -> Array[Int] {
  let result : Array[Int] = []
  let mut i = 0
  while i < self.count {
    result.push(self.dense[i])
    i = i + 1
  }
  result
}

///|
pub fn[V] SparseSet::values_array(self : SparseSet[V]) -> Array[V] {
  let result : Array[V] = []
  let mut i = 0
  while i < self.count {
    match self.values[i] {
      Some(v) => result.push(v)
      None => ()
    }
    i = i + 1
  }
  result
}

///|
pub fn[V : Eq] SparseSet::value_eq(
  self : SparseSet[V],
  key : Int,
  value : V,
) -> Bool {
  match SparseSet::get(self, key) {
    Some(v) => v == value
    None => false
  }
}

///|
pub impl[V] @traits.Collection for SparseSet[V] with fn len(self) -> Int {
  self.count
}

///|
pub impl[V] @traits.Collection for SparseSet[V] with fn is_empty(self) -> Bool {
  self.count == 0
}

///|
pub impl[V : Hash + Eq] @traits.Deterministic for SparseSet[V] with fn fingerprint(
  self,
) -> UInt64 {
  if !self.fp_dirty {
    return self.fp_cache
  }
  let mut h = @fp.fnv_offset_basis
  h = @fp.fnv1a_hash_int(self.count, h)
  h = @fp.fnv1a_hash_int(self.capacity, h)
  let mut i = 0
  while i < self.count {
    h = @fp.fnv1a_hash_int(self.dense[i], h)
    match self.values[i] {
      Some(v) => h = @fp.fnv1a_hash_int(v.hash(), h)
      None => h = @fp.fnv1a_hash_int(0, h)
    }
    i = i + 1
  }
  self.fp_cache = h
  self.fp_dirty = false
  h
}

///|
pub impl[V : Hash + Eq] @traits.Deterministic for SparseSet[V] with fn ordered_eq(
  self,
  other,
) -> Bool {
  if self.count != other.count {
    return false
  }
  let mut i = 0
  while i < self.count {
    if self.dense[i] != other.dense[i] {
      return false
    }
    if self.values[i] != other.values[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn[V] SparseSet::from_array(
  capacity : Int,
  pairs : Array[(Int, V)],
) -> SparseSet[V] {
  let ss = SparseSet::new(capacity)
  let mut i = 0
  while i < pairs.length() {
    ignore(SparseSet::insert(ss, pairs[i].0, pairs[i].1))
    i = i + 1
  }
  ss
}

///|
pub fn[V] SparseSet::each_index(self : SparseSet[V], f : (Int) -> Unit) -> Unit {
  let mut i = 0
  while i < self.count {
    f(self.dense[i])
    i = i + 1
  }
}

///|
pub fn[V : Eq] SparseSet::contains_value(
  self : SparseSet[V],
  value : V,
) -> Bool {
  let mut i = 0
  while i < self.count {
    match self.values[i] {
      Some(v) => if v == value { return true }
      None => ()
    }
    i = i + 1
  }
  false
}

///|
pub fn[V] SparseSet::update(
  self : SparseSet[V],
  key : Int,
  f : (V) -> V,
) -> Bool {
  if key < 0 || key >= self.capacity {
    return false
  }
  let idx = self.sparse[key]
  if idx >= 0 && idx < self.count && self.dense[idx] == key {
    match self.values[idx] {
      Some(v) => {
        self.values[idx] = Some(f(v))
        self.fp_dirty = true
        true
      }
      None => false
    }
  } else {
    false
  }
}
