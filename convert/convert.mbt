///|
pub fn[K : Compare, V] to_sorted_map(
  im : @indexmap.IndexMap[K, V],
) -> @sortedmap.SortedMap[K, V] {
  let arr = im.to_array()
  arr.sort_by(fn(a : (K, V), b : (K, V)) -> Int { a.0.compare(b.0) })
  @sortedmap.SortedMap::from_sorted_entries(arr)
}

///|
pub fn[K : Hash + Eq, V] to_index_map(
  sm : @sortedmap.SortedMap[K, V],
) -> @indexmap.IndexMap[K, V] {
  let im = @indexmap.IndexMap::new()
  sm.each(fn(k : K, v : V) -> Unit { ignore(im.insert(k, v)) })
  im
}
