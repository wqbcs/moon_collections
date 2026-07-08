///|
pub struct IndexSet[K] {
  map : IndexMap[K, Unit]
} derive(Debug)

///|
pub fn[K : Hash + Eq] IndexSet::new() -> IndexSet[K] {
  { map: IndexMap::new() }
}

///|
pub fn[K : Hash + Eq] IndexSet::insert(self : IndexSet[K], key : K) -> Unit {
  ignore(self.map.insert(key, ()))
}

///|
pub fn[K : Hash + Eq] IndexSet::contains(self : IndexSet[K], key : K) -> Bool {
  self.map.contains(key)
}

///|
pub fn[K : Hash + Eq] IndexSet::remove(self : IndexSet[K], key : K) -> Bool {
  match self.map.remove(key) {
    Some(_) => true
    None => false
  }
}

///|
pub fn[K] IndexSet::len(self : IndexSet[K]) -> Int {
  self.map.len()
}

///|
pub fn[K] IndexSet::is_empty(self : IndexSet[K]) -> Bool {
  self.map.is_empty()
}

///|
pub fn[K : Hash + Eq] IndexSet::get_index_of(
  self : IndexSet[K],
  key : K,
) -> Int? {
  self.map.get_index_of(key)
}

///|
pub fn[K] IndexSet::get_index(self : IndexSet[K], index : Int) -> K? {
  match self.map.get_index(index) {
    Some((k, _)) => Some(k)
    None => None
  }
}

///|
pub fn[K] IndexSet::keys(self : IndexSet[K]) -> Iter[K] {
  self.map.keys()
}

///|
pub fn[K] IndexSet::iter(self : IndexSet[K]) -> Iter[K] {
  self.map.keys()
}

///|
pub fn[K] IndexSet::each(self : IndexSet[K], f : (K) -> Unit) -> Unit {
  self.map.each(fn(k : K, _v : Unit) -> Unit { f(k) })
}

///|
pub fn[K : Hash + Eq] IndexSet::clear(self : IndexSet[K]) -> Unit {
  self.map.clear()
}

///|
pub fn[K : Hash + Eq] IndexSet::retain(
  self : IndexSet[K],
  pred : (K) -> Bool,
) -> Unit {
  self.map.retain(fn(k : K, _v : Unit) -> Bool { pred(k) })
}

///|
pub fn[K : Hash + Eq] IndexSet::shift_remove(
  self : IndexSet[K],
  key : K,
) -> Bool {
  match self.map.shift_remove(key) {
    Some(_) => true
    None => false
  }
}

///|
pub fn[K : Hash + Eq] IndexSet::reverse(self : IndexSet[K]) -> Unit {
  self.map.reverse()
}

///|
pub fn[K : Hash + Eq] IndexSet::move_to_front(
  self : IndexSet[K],
  key : K,
) -> Bool {
  self.map.move_to_front(key)
}

///|
pub fn[K : Hash + Eq] IndexSet::move_to_back(
  self : IndexSet[K],
  key : K,
) -> Bool {
  self.map.move_to_back(key)
}

///|
pub fn[K] IndexSet::rev_iter(self : IndexSet[K]) -> Iter[K] {
  self.map.rev_iter().map(fn(pair : (K, Unit)) -> K { pair.0 })
}

///|
pub fn[K : Hash + Eq] IndexSet::pop_back(self : IndexSet[K]) -> K? {
  match self.map.pop_back() {
    Some((k, _)) => Some(k)
    None => None
  }
}

///|
pub fn[K : Hash + Eq] IndexSet::pop_front(self : IndexSet[K]) -> K? {
  match self.map.pop_front() {
    Some((k, _)) => Some(k)
    None => None
  }
}

///|
pub impl[K : Eq] Eq for IndexSet[K] with fn equal(
  self : IndexSet[K],
  other : IndexSet[K],
) -> Bool {
  self.map == other.map
}

///|
pub impl[K] @traits.Collection for IndexSet[K] with fn len(self) -> Int {
  self.map.len()
}

///|
pub impl[K] @traits.Collection for IndexSet[K] with fn is_empty(self) -> Bool {
  self.map.is_empty()
}

///|
pub impl[K : Hash + Eq] @traits.Deterministic for IndexSet[K] with fn fingerprint(
  self,
) -> UInt64 {
  self.map.fingerprint()
}

///|
pub impl[K : Hash + Eq] @traits.Deterministic for IndexSet[K] with fn ordered_eq(
  self,
  other,
) -> Bool {
  self.map.ordered_eq(other.map)
}

///|
pub fn[K : Hash + Eq] IndexSet::from_array(items : Array[K]) -> IndexSet[K] {
  let s = IndexSet::new()
  let mut i = 0
  while i < items.length() {
    IndexSet::insert(s, items[i])
    i = i + 1
  }
  s
}

///|
pub fn[K : Hash + Eq] IndexSet::clone(self : IndexSet[K]) -> IndexSet[K] {
  IndexSet::from_array(IndexSet::to_array(self))
}

///|
pub fn[K] IndexSet::to_array(self : IndexSet[K]) -> Array[K] {
  self.map.keys_array()
}

///|
pub fn[K : Hash + Eq] IndexSet::union(
  self : IndexSet[K],
  other : IndexSet[K],
) -> IndexSet[K] {
  let result = IndexSet::new()
  self.each(fn(k : K) -> Unit { IndexSet::insert(result, k) })
  other.each(fn(k : K) -> Unit { IndexSet::insert(result, k) })
  result
}

///|
pub fn[K : Hash + Eq] IndexSet::intersect(
  self : IndexSet[K],
  other : IndexSet[K],
) -> IndexSet[K] {
  let result = IndexSet::new()
  self.each(fn(k : K) -> Unit {
    if other.contains(k) {
      IndexSet::insert(result, k)
    }
  })
  result
}

///|
pub fn[K : Hash + Eq] IndexSet::difference(
  self : IndexSet[K],
  other : IndexSet[K],
) -> IndexSet[K] {
  let result = IndexSet::new()
  self.each(fn(k : K) -> Unit {
    if !other.contains(k) {
      IndexSet::insert(result, k)
    }
  })
  result
}

///|
pub fn[K : Hash + Eq] IndexSet::symmetric_difference(
  self : IndexSet[K],
  other : IndexSet[K],
) -> IndexSet[K] {
  let result = IndexSet::new()
  self.each(fn(k : K) -> Unit {
    if !other.contains(k) {
      IndexSet::insert(result, k)
    }
  })
  other.each(fn(k : K) -> Unit {
    if !self.contains(k) {
      IndexSet::insert(result, k)
    }
  })
  result
}

///|
pub fn[K : Hash + Eq] IndexSet::is_subset(
  self : IndexSet[K],
  other : IndexSet[K],
) -> Bool {
  let mut all_in = true
  self.each(fn(k : K) -> Unit { if !other.contains(k) { all_in = false } })
  all_in
}

///|
pub fn[K : Hash + Eq] IndexSet::is_superset(
  self : IndexSet[K],
  other : IndexSet[K],
) -> Bool {
  other.is_subset(self)
}

///|
pub fn[K : Hash + Eq] IndexSet::is_disjoint(
  self : IndexSet[K],
  other : IndexSet[K],
) -> Bool {
  let mut found = false
  self.each(fn(k : K) -> Unit { if other.contains(k) { found = true } })
  !found
}

///|
pub fn[K : Hash + Eq] IndexSet::extend_(
  self : IndexSet[K],
  items : Array[K],
) -> Unit {
  let mut i = 0
  while i < items.length() {
    IndexSet::insert(self, items[i])
    i = i + 1
  }
}
