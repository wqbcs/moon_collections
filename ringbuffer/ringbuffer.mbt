///|
pub struct RingBuffer[T] {
  data : Array[T?]
  mut head : Int
  mut tail : Int
  mut count : Int
  capacity : Int
  mut fp_cache : UInt64
  mut fp_dirty : Bool
}

///|
pub impl[T : Debug] Debug for RingBuffer[T] with fn to_repr(self) -> Repr {
  Repr::ctor("RingBuffer", [
    (Some("data"), to_repr(self.data)),
    (Some("head"), to_repr(self.head)),
    (Some("tail"), to_repr(self.tail)),
    (Some("count"), to_repr(self.count)),
    (Some("capacity"), to_repr(self.capacity)),
  ])
}

///|
pub fn[T] RingBuffer::new(capacity : Int) -> RingBuffer[T] {
  let cap = if capacity <= 0 { 1 } else { capacity }
  {
    data: Array::make(cap, None),
    head: 0,
    tail: 0,
    count: 0,
    capacity: cap,
    fp_cache: 0UL,
    fp_dirty: true,
  }
}

///|
pub fn[T] RingBuffer::capacity(self : RingBuffer[T]) -> Int {
  self.capacity
}

///|
pub fn[T] RingBuffer::len(self : RingBuffer[T]) -> Int {
  self.count
}

///|
pub fn[T] RingBuffer::is_empty(self : RingBuffer[T]) -> Bool {
  self.count == 0
}

///|
pub fn[T] RingBuffer::is_full(self : RingBuffer[T]) -> Bool {
  self.count == self.capacity
}

///|
pub fn[T] RingBuffer::clear(self : RingBuffer[T]) -> Unit {
  let mut i = 0
  while i < self.capacity {
    self.data[i] = None
    i = i + 1
  }
  self.head = 0
  self.tail = 0
  self.count = 0
  self.fp_dirty = true
}

///|
pub fn[T] RingBuffer::push_back(self : RingBuffer[T], item : T) -> T? {
  self.fp_dirty = true
  if self.count == self.capacity {
    let old = self.data[self.head]
    self.data[self.tail] = Some(item)
    self.tail = (self.tail + 1) % self.capacity
    self.head = (self.head + 1) % self.capacity
    old
  } else {
    self.data[self.tail] = Some(item)
    self.tail = (self.tail + 1) % self.capacity
    self.count = self.count + 1
    None
  }
}

///|
pub fn[T] RingBuffer::push_front(self : RingBuffer[T], item : T) -> T? {
  self.fp_dirty = true
  if self.count == self.capacity {
    let old_pos = (self.tail - 1 + self.capacity) % self.capacity
    let old = self.data[old_pos]
    self.head = (self.head - 1 + self.capacity) % self.capacity
    self.data[self.head] = Some(item)
    self.tail = (self.tail - 1 + self.capacity) % self.capacity
    old
  } else {
    self.head = (self.head - 1 + self.capacity) % self.capacity
    self.data[self.head] = Some(item)
    self.count = self.count + 1
    None
  }
}

///|
pub fn[T] RingBuffer::pop_front(self : RingBuffer[T]) -> T? {
  if self.count == 0 {
    None
  } else {
    match self.data[self.head] {
      Some(item) => {
        self.data[self.head] = None
        self.head = (self.head + 1) % self.capacity
        self.count = self.count - 1
        self.fp_dirty = true
        Some(item)
      }
      None => None
    }
  }
}

///|
pub fn[T] RingBuffer::pop_back(self : RingBuffer[T]) -> T? {
  if self.count == 0 {
    None
  } else {
    let new_tail = (self.tail - 1 + self.capacity) % self.capacity
    match self.data[new_tail] {
      Some(item) => {
        self.data[new_tail] = None
        self.tail = new_tail
        self.count = self.count - 1
        self.fp_dirty = true
        Some(item)
      }
      None => None
    }
  }
}

///|
pub fn[T] RingBuffer::front(self : RingBuffer[T]) -> T? {
  if self.count == 0 {
    None
  } else {
    self.data[self.head]
  }
}

///|
pub fn[T] RingBuffer::back(self : RingBuffer[T]) -> T? {
  if self.count == 0 {
    None
  } else {
    self.data[(self.tail - 1 + self.capacity) % self.capacity]
  }
}

///|
pub fn[T] RingBuffer::get(self : RingBuffer[T], index : Int) -> T? {
  if index < 0 || index >= self.count {
    None
  } else {
    self.data[(self.head + index) % self.capacity]
  }
}

///|
pub fn[T] RingBuffer::set(self : RingBuffer[T], index : Int, value : T) -> Bool {
  if index < 0 || index >= self.count {
    false
  } else {
    self.data[(self.head + index) % self.capacity] = Some(value)
    self.fp_dirty = true
    true
  }
}

///|
pub fn[T] RingBuffer::each(self : RingBuffer[T], f : (T) -> Unit) -> Unit {
  let mut i = 0
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(item) => f(item)
      None => ()
    }
    i = i + 1
  }
}

///|
pub fn[T] RingBuffer::iter(self : RingBuffer[T]) -> Iter[T] {
  self.to_array().iter()
}

///|
pub fn[T] RingBuffer::to_array(self : RingBuffer[T]) -> Array[T] {
  let result : Array[T] = []
  let mut i = 0
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(item) => result.push(item)
      None => ()
    }
    i = i + 1
  }
  result
}

///|
pub fn[T] RingBuffer::from_array(items : Array[T]) -> RingBuffer[T] {
  let rb = RingBuffer::new(items.length())
  let mut i = 0
  while i < items.length() {
    ignore(RingBuffer::push_back(rb, items[i]))
    i = i + 1
  }
  rb
}

///|
pub fn[T : Eq] RingBuffer::contains(self : RingBuffer[T], item : T) -> Bool {
  let mut i = 0
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(v) => if v == item { return true }
      None => ()
    }
    i = i + 1
  }
  false
}

///|
pub fn[T] RingBuffer::rotate_left(self : RingBuffer[T], n : Int) -> Unit {
  if self.count <= 1 {
    return
  }
  let steps = (n % self.count + self.count) % self.count
  if steps == 0 {
    return
  }
  let arr = self.to_array()
  let mut i = 0
  while i < self.count {
    let src_idx = (steps + i) % self.count
    self.data[(self.head + i) % self.capacity] = Some(arr[src_idx])
    i = i + 1
  }
  self.fp_dirty = true
}

///|
pub fn[T] RingBuffer::rotate_right(self : RingBuffer[T], n : Int) -> Unit {
  if self.count <= 1 {
    return
  }
  let steps = (n % self.count + self.count) % self.count
  if steps == 0 {
    return
  }
  self.fp_dirty = true
  RingBuffer::rotate_left(self, self.count - steps)
}

///|
pub fn[T : Eq] RingBuffer::remove_first(self : RingBuffer[T], item : T) -> Bool {
  let mut found = -1
  let mut i = 0
  while i < self.count {
    let idx = (self.head + i) % self.capacity
    match self.data[idx] {
      Some(v) => if v == item { found = i }
      None => ()
    }
    if found >= 0 {
      break
    }
    i = i + 1
  }
  if found < 0 {
    return false
  }
  let mut j = found
  while j < self.count - 1 {
    let src = (self.head + j + 1) % self.capacity
    let dst = (self.head + j) % self.capacity
    self.data[dst] = self.data[src]
    j = j + 1
  }
  self.data[(self.head + self.count - 1) % self.capacity] = None
  self.tail = (self.tail - 1 + self.capacity) % self.capacity
  self.count = self.count - 1
  self.fp_dirty = true
  true
}

///|
pub fn[T : Eq] RingBuffer::count_item(self : RingBuffer[T], item : T) -> Int {
  let mut c = 0
  let mut i = 0
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(v) => if v == item { c = c + 1 }
      None => ()
    }
    i = i + 1
  }
  c
}

///|
pub impl[T] @traits.Collection for RingBuffer[T] with fn len(self) -> Int {
  self.count
}

///|
pub impl[T] @traits.Collection for RingBuffer[T] with fn is_empty(self) -> Bool {
  self.count == 0
}

///|
pub impl[T : Hash + Eq] @traits.Deterministic for RingBuffer[T] with fn fingerprint(
  self,
) -> UInt64 {
  if self.fp_dirty {
    let mut h = @fp.fnv_offset_basis
    h = @fp.fnv1a_hash_int(self.count, h)
    h = @fp.fnv1a_hash_int(self.capacity, h)
    let mut i = 0
    while i < self.count {
      h = @fp.fnv1a_hash_int(i, h)
      match self.data[(self.head + i) % self.capacity] {
        Some(v) => h = @fp.fnv1a_hash_int(v.hash(), h)
        None => h = @fp.fnv1a_hash_int(0, h)
      }
      i = i + 1
    }
    self.fp_cache = h
    self.fp_dirty = false
  }
  self.fp_cache
}

///|
pub impl[T : Hash + Eq] @traits.Deterministic for RingBuffer[T] with fn ordered_eq(
  self,
  other,
) -> Bool {
  if self.count != other.count {
    return false
  }
  if self.capacity != other.capacity {
    return false
  }
  let mut i = 0
  while i < self.count {
    if self.data[(self.head + i) % self.capacity] !=
      other.data[(other.head + i) % other.capacity] {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub impl[T : Eq] Eq for RingBuffer[T] with fn equal(
  self : RingBuffer[T],
  other : RingBuffer[T],
) -> Bool {
  if self.count != other.count {
    return false
  }
  let mut i = 0
  while i < self.count {
    if self.data[(self.head + i) % self.capacity] !=
      other.data[(other.head + i) % other.capacity] {
      return false
    }
    i = i + 1
  }
  true
}

///|
pub fn[T] RingBuffer::extend_(self : RingBuffer[T], items : Array[T]) -> Unit {
  self.fp_dirty = true
  let mut i = 0
  while i < items.length() {
    ignore(RingBuffer::push_back(self, items[i]))
    i = i + 1
  }
}

///|
pub fn[T] RingBuffer::drain(self : RingBuffer[T], n : Int) -> Array[T] {
  self.fp_dirty = true
  let result : Array[T] = []
  let mut i = 0
  while i < n && self.count > 0 {
    match RingBuffer::pop_front(self) {
      Some(item) => result.push(item)
      None => ()
    }
    i = i + 1
  }
  result
}

///|
pub fn[T] RingBuffer::resize(
  self : RingBuffer[T],
  new_cap : Int,
) -> RingBuffer[T] {
  let items = self.to_array()
  let rb = RingBuffer::new(new_cap)
  let mut i = 0
  while i < items.length() {
    ignore(RingBuffer::push_back(rb, items[i]))
    i = i + 1
  }
  rb
}

///|
pub fn[T : Eq] RingBuffer::index_of(self : RingBuffer[T], item : T) -> Int? {
  let mut i = 0
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(v) => if v == item { return Some(i) }
      None => ()
    }
    i = i + 1
  }
  None
}

///|
pub fn[T] RingBuffer::take(self : RingBuffer[T], n : Int) -> Array[T] {
  let result : Array[T] = []
  let limit = if n < self.count { n } else { self.count }
  let mut i = 0
  while i < limit {
    match self.data[(self.head + i) % self.capacity] {
      Some(item) => result.push(item)
      None => ()
    }
    i = i + 1
  }
  result
}

///|
pub fn[T] RingBuffer::skip(self : RingBuffer[T], n : Int) -> Array[T] {
  let result : Array[T] = []
  let start = if n < 0 { 0 } else { n }
  let mut i = start
  while i < self.count {
    match self.data[(self.head + i) % self.capacity] {
      Some(item) => result.push(item)
      None => ()
    }
    i = i + 1
  }
  result
}

///|
pub fn[T : Compare] RingBuffer::sort(self : RingBuffer[T]) -> Unit {
  let arr = self.to_array()
  arr.sort_by(fn(a : T, b : T) -> Int { a.compare(b) })
  let mut i = 0
  while i < arr.length() {
    self.data[(self.head + i) % self.capacity] = Some(arr[i])
    i = i + 1
  }
  self.fp_dirty = true
}

///|
pub fn[T : Eq] RingBuffer::find_last(self : RingBuffer[T], item : T) -> Int? {
  let mut found_idx : Int? = None
  let mut i = 0
  while i < self.count {
    let idx = (self.head + i) % self.capacity
    match self.data[idx] {
      Some(v) => if v == item { found_idx = Some(i) }
      None => ()
    }
    i = i + 1
  }
  found_idx
}

///|
pub fn[T] RingBuffer::reverse(self : RingBuffer[T]) -> Unit {
  let arr = self.to_array()
  let mut i = 0
  while i < self.count {
    let src_idx = self.count - 1 - i
    self.data[(self.head + i) % self.capacity] = match arr[src_idx] {
      v => Some(v)
    }
    i = i + 1
  }
  self.fp_dirty = true
}
