///|
pub struct Counter[K] {
  map : @indexmap.IndexMap[K, Int]
} derive(Debug)

///|
pub fn[K : Hash + Eq] Counter::new() -> Counter[K] {
  { map: @indexmap.IndexMap::new() }
}

///|
pub fn[K : Hash + Eq] Counter::from_array(items : Array[K]) -> Counter[K] {
  let c = Counter::new()
  let mut i = 0
  while i < items.length() {
    Counter::add(c, items[i])
    i = i + 1
  }
  c
}

///|
pub fn[K : Hash + Eq] Counter::add(self : Counter[K], key : K) -> Unit {
  match self.map.get(key) {
    Some(count) => ignore(self.map.insert(key, count + 1))
    None => ignore(self.map.insert(key, 1))
  }
}

///|
pub fn[K : Hash + Eq] Counter::subtract(self : Counter[K], key : K) -> Unit {
  match self.map.get(key) {
    Some(count) =>
      if count <= 1 {
        ignore(self.map.shift_remove(key))
      } else {
        ignore(self.map.insert(key, count - 1))
      }
    None => ()
  }
}

///|
pub fn[K : Hash + Eq] Counter::get(self : Counter[K], key : K) -> Int {
  match self.map.get(key) {
    Some(count) => count
    None => 0
  }
}

///|
pub fn[K : Hash + Eq] Counter::set(
  self : Counter[K],
  key : K,
  count : Int,
) -> Unit {
  if count <= 0 {
    ignore(self.map.shift_remove(key))
  } else {
    ignore(self.map.insert(key, count))
  }
}

///|
pub fn[K] Counter::len(self : Counter[K]) -> Int {
  self.map.len()
}

///|
pub fn[K] Counter::is_empty(self : Counter[K]) -> Bool {
  self.map.is_empty()
}

///|
pub fn[K : Hash + Eq] Counter::contains(self : Counter[K], key : K) -> Bool {
  self.map.contains(key)
}

///|
pub fn[K : Hash + Eq] Counter::remove(self : Counter[K], key : K) -> Int {
  match self.map.shift_remove(key) {
    Some(count) => count
    None => 0
  }
}

///|
pub fn[K] Counter::total(self : Counter[K]) -> Int {
  let mut sum = 0
  self.map.each(fn(_k : K, v : Int) -> Unit { sum = sum + v })
  sum
}

///|
pub fn[K : Hash + Eq] Counter::most_common(
  self : Counter[K],
  n : Int,
) -> Array[(K, Int)] {
  let items = self.map
    .keys_array()
    .map(fn(k : K) -> (K, Int) { (k, Counter::get(self, k)) })
  let indexed : Array[(K, Int, Int)] = []
  let mut j = 0
  while j < items.length() {
    indexed.push((items[j].0, items[j].1, j))
    j = j + 1
  }
  indexed.sort_by(fn(a : (K, Int, Int), b : (K, Int, Int)) -> Int {
    let cmp = b.1 - a.1
    if cmp == 0 {
      a.2 - b.2
    } else {
      cmp
    }
  })
  let sorted : Array[(K, Int)] = []
  let mut i = 0
  while i < indexed.length() {
    sorted.push((indexed[i].0, indexed[i].1))
    i = i + 1
  }
  if n >= 0 && n < sorted.length() {
    let result : Array[(K, Int)] = []
    i = 0
    while i < n {
      result.push(sorted[i])
      i = i + 1
    }
    result
  } else {
    sorted
  }
}

///|
pub fn[K] Counter::elements(self : Counter[K]) -> Array[K] {
  let result : Array[K] = []
  self.map.each(fn(k : K, v : Int) -> Unit {
    let mut i = 0
    while i < v {
      ignore(result.push(k))
      i = i + 1
    }
  })
  result
}

///|
pub fn[K : Hash + Eq] Counter::clear(self : Counter[K]) -> Unit {
  self.map.clear()
}

///|
pub fn[K : Hash + Eq] Counter::retain(
  self : Counter[K],
  pred : (K, Int) -> Bool,
) -> Unit {
  self.map.retain(pred)
}

///|
pub fn[K : Hash + Eq] Counter::add_counter(
  self : Counter[K],
  other : Counter[K],
) -> Counter[K] {
  let result = Counter::new()
  self.map.each(fn(k : K, v : Int) -> Unit { result.set(k, v) })
  other.map.each(fn(k : K, v : Int) -> Unit {
    result.set(k, Counter::get(result, k) + v)
  })
  result
}

///|
pub fn[K : Hash + Eq] Counter::subtract_counter(
  self : Counter[K],
  other : Counter[K],
) -> Counter[K] {
  let result = Counter::new()
  self.map.each(fn(k : K, v : Int) -> Unit {
    let other_v = Counter::get(other, k)
    let new_v = v - other_v
    if new_v > 0 {
      result.set(k, new_v)
    }
  })
  result
}

///|
pub fn[K] Counter::keys(self : Counter[K]) -> Iter[K] {
  self.map.keys()
}

///|
pub fn[K] Counter::iter(self : Counter[K]) -> Iter[(K, Int)] {
  self.map.iter()
}

///|
pub fn[K] Counter::each(self : Counter[K], f : (K, Int) -> Unit) -> Unit {
  self.map.each(f)
}

///|
pub impl[K] @traits.Collection for Counter[K] with fn len(self) -> Int {
  self.map.len()
}

///|
pub impl[K] @traits.Collection for Counter[K] with fn is_empty(self) -> Bool {
  self.map.is_empty()
}

///|
pub impl[K : Hash + Eq] @traits.Deterministic for Counter[K] with fn fingerprint(
  self,
) -> UInt64 {
  self.map.fingerprint()
}

///|
pub impl[K : Hash + Eq] @traits.Deterministic for Counter[K] with fn ordered_eq(
  self,
  other,
) -> Bool {
  self.map.ordered_eq(other.map)
}

///|
pub fn[K : Hash + Eq] Counter::from_array_with_weight(
  items : Array[(K, Int)],
) -> Counter[K] {
  let c = Counter::new()
  let mut i = 0
  while i < items.length() {
    let (k, w) = items[i]
    Counter::set(c, k, Counter::get(c, k) + w)
    i = i + 1
  }
  c
}

///|
pub fn[K : Hash + Eq] Counter::filter(
  self : Counter[K],
  pred : (K, Int) -> Bool,
) -> Counter[K] {
  let result = Counter::new()
  self.map.each(fn(k : K, v : Int) -> Unit {
    if pred(k, v) {
      result.set(k, v)
    }
  })
  result
}

///|
pub fn[K, R : Hash + Eq] Counter::map_keys(
  self : Counter[K],
  f : (K) -> R,
) -> Counter[R] {
  let result = Counter::new()
  self.map.each(fn(k : K, v : Int) -> Unit {
    let new_key = f(k)
    result.set(new_key, Counter::get(result, new_key) + v)
  })
  result
}

///|
pub fn[K : Hash + Eq] Counter::scale(
  self : Counter[K],
  factor : Int,
) -> Counter[K] {
  let result = Counter::new()
  self.map.each(fn(k : K, v : Int) -> Unit { result.set(k, v * factor) })
  result
}

///|
pub fn[K] Counter::max_count(self : Counter[K]) -> Int {
  if self.map.is_empty() {
    return 0
  }
  let mut max_val = 0
  self.map.each(fn(_k : K, v : Int) -> Unit { if v > max_val { max_val = v } })
  max_val
}

///|
pub fn[K] Counter::min_count(self : Counter[K]) -> Int {
  match self.map.first() {
    Some((_k, v)) => {
      let mut min_val = v
      self.map.each(fn(_k : K, v : Int) -> Unit {
        if v < min_val {
          min_val = v
        }
      })
      min_val
    }
    None => 0
  }
}

///|
pub fn[K] Counter::keys_array(self : Counter[K]) -> Array[K] {
  self.map.keys_array()
}

///|
pub fn[K] Counter::items(self : Counter[K]) -> Array[(K, Int)] {
  let result : Array[(K, Int)] = []
  self.map.each(fn(k : K, v : Int) -> Unit { result.push((k, v)) })
  result
}
