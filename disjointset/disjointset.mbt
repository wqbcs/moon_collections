///|
pub struct DisjointSet {
  parent : Array[Int]
  rank : Array[Int]
  mut count : Int
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl Debug for DisjointSet with fn to_repr(self) -> Repr {
  Repr::ctor("DisjointSet", [
    (Some("parent"), to_repr(self.parent)),
    (Some("rank"), to_repr(self.rank)),
    (Some("count"), to_repr(self.count)),
  ])
}

///|
pub fn DisjointSet::new(size : Int) -> DisjointSet {
  let n = if size <= 0 { 0 } else { size }
  let parent = Array::makei(n, fn(i : Int) -> Int { i })
  let rank = Array::make(n, 0)
  { parent, rank, count: n, fp_cache: 0UL, fp_dirty: true }
}

///|
pub fn DisjointSet::clear(self : DisjointSet) -> Unit {
  let mut i = 0
  while i < self.parent.length() {
    self.parent[i] = i
    self.rank[i] = 0
    i = i + 1
  }
  self.count = self.parent.length()
  self.fp_dirty = true
}

///|
pub fn DisjointSet::from_array(
  size : Int,
  pairs : Array[(Int, Int)],
) -> DisjointSet {
  let ds = DisjointSet::new(size)
  let mut i = 0
  while i < pairs.length() {
    ignore(DisjointSet::union(ds, pairs[i].0, pairs[i].1))
    i = i + 1
  }
  ds
}

///|
pub fn DisjointSet::find(self : DisjointSet, x : Int) -> Int {
  if x < 0 || x >= self.parent.length() {
    return -1
  }
  if self.parent[x] != x {
    self.parent[x] = DisjointSet::find(self, self.parent[x])
  }
  self.parent[x]
}

///|
pub fn DisjointSet::union(self : DisjointSet, x : Int, y : Int) -> Bool {
  let rx = DisjointSet::find(self, x)
  let ry = DisjointSet::find(self, y)
  if rx == -1 || ry == -1 {
    return false
  }
  if rx == ry {
    return false
  }
  if self.rank[rx] < self.rank[ry] {
    self.parent[rx] = ry
  } else if self.rank[rx] > self.rank[ry] {
    self.parent[ry] = rx
  } else {
    self.parent[ry] = rx
    self.rank[rx] = self.rank[rx] + 1
  }
  self.count = self.count - 1
  self.fp_dirty = true
  true
}

///|
pub fn DisjointSet::connected(self : DisjointSet, x : Int, y : Int) -> Bool {
  let rx = DisjointSet::find(self, x)
  let ry = DisjointSet::find(self, y)
  rx != -1 && ry != -1 && rx == ry
}

///|
pub fn DisjointSet::component_count(self : DisjointSet) -> Int {
  self.count
}

///|
pub fn DisjointSet::size(self : DisjointSet) -> Int {
  self.parent.length()
}

///|
pub fn DisjointSet::component_size(self : DisjointSet, x : Int) -> Int {
  let root = DisjointSet::find(self, x)
  if root == -1 {
    return 0
  }
  let mut total = 0
  let mut i = 0
  while i < self.parent.length() {
    if DisjointSet::find(self, i) == root {
      total = total + 1
    }
    i = i + 1
  }
  total
}

///|
pub fn DisjointSet::len(self : DisjointSet) -> Int {
  self.parent.length()
}

///|
pub fn DisjointSet::is_empty(self : DisjointSet) -> Bool {
  self.parent.length() == 0
}

///|
pub impl @traits.Collection for DisjointSet with fn len(self) -> Int {
  self.parent.length()
}

///|
pub impl @traits.Collection for DisjointSet with fn is_empty(self) -> Bool {
  self.parent.length() == 0
}

///|
pub impl @traits.Deterministic for DisjointSet with fn fingerprint(self) -> UInt64 {
  if !self.fp_dirty {
    return self.fp_cache
  }
  let n = self.parent.length()
  let mut i = 0
  while i < n {
    ignore(DisjointSet::find(self, i))
    i = i + 1
  }
  let mut h = @fp.fnv_offset_basis
  h = @fp.fnv1a_hash_int(self.count, h)
  i = 0
  while i < n {
    h = @fp.fnv1a_hash_int(self.parent[i], h)
    h = @fp.fnv1a_hash_int(self.rank[i], h)
    i = i + 1
  }
  self.fp_cache = h
  self.fp_dirty = false
  h
}

///|
pub impl @traits.Deterministic for DisjointSet with fn ordered_eq(self, other) -> Bool {
  let n = self.parent.length()
  if n != other.parent.length() {
    return false
  }
  if self.count != other.count {
    return false
  }
  let mut i = 0
  while i < n {
    ignore(DisjointSet::find(self, i))
    i = i + 1
  }
  i = 0
  while i < n {
    ignore(DisjointSet::find(other, i))
    i = i + 1
  }
  i = 0
  while i < n {
    if self.parent[i] != other.parent[i] {
      return false
    }
    if self.rank[i] != other.rank[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn DisjointSet::all_components(self : DisjointSet) -> Array[Array[Int]] {
  let n = self.parent.length()
  let roots : Array[Int] = []
  let mut i = 0
  while i < n {
    let root = DisjointSet::find(self, i)
    let mut found = false
    let mut j = 0
    while j < roots.length() {
      if roots[j] == root {
        found = true
      }
      j = j + 1
    }
    if !found {
      roots.push(root)
    }
    i = i + 1
  }
  let result : Array[Array[Int]] = []
  let mut k = 0
  while k < roots.length() {
    let component : Array[Int] = []
    let mut m = 0
    while m < n {
      if DisjointSet::find(self, m) == roots[k] {
        component.push(m)
      }
      m = m + 1
    }
    result.push(component)
    k = k + 1
  }
  result
}
