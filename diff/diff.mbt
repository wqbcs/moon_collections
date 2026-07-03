///|
pub struct Diff[T] {
  added : Array[T]
  removed : Array[T]
  modified : Array[(T, T)]
} derive(Debug, Eq)

///|
pub fn[T] Diff::new() -> Diff[T] {
  { added: [], removed: [], modified: [] }
}

///|
pub fn diff_arrays(old : Array[Int], new : Array[Int]) -> Diff[Int] {
  let result = Diff::new()
  let mut i = 0
  while i < new.length() {
    let mut found = false
    let mut j = 0
    while j < old.length() {
      if old[j] == new[i] {
        found = true
      }
      j = j + 1
    }
    if !found {
      ignore(result.added.push(new[i]))
    }
    i = i + 1
  }
  let mut k = 0
  while k < old.length() {
    let mut found = false
    let mut l = 0
    while l < new.length() {
      if new[l] == old[k] {
        found = true
      }
      l = l + 1
    }
    if !found {
      ignore(result.removed.push(old[k]))
    }
    k = k + 1
  }
  result
}

///|
pub fn[T] Diff::is_empty(self : Diff[T]) -> Bool {
  self.added.length() == 0 &&
  self.removed.length() == 0 &&
  self.modified.length() == 0
}

///|
pub fn[T] Diff::total_changes(self : Diff[T]) -> Int {
  self.added.length() + self.removed.length() + self.modified.length()
}

///|
pub enum EditOp {
  Keep
  Insert
  Delete
} derive(Debug, Eq)

///|
pub struct SequenceDiff {
  ops : Array[EditOp]
  distance : Int
} derive(Debug, Eq)

///|
pub fn lcs_length(old : Array[Int], new : Array[Int]) -> Int {
  let m = old.length()
  let n = new.length()
  let dp = Array::make((m + 1) * (n + 1), 0)
  let mut i = 1
  while i <= m {
    let mut j = 1
    while j <= n {
      if old[i - 1] == new[j - 1] {
        dp[i * (n + 1) + j] = dp[(i - 1) * (n + 1) + (j - 1)] + 1
      } else {
        let a = dp[(i - 1) * (n + 1) + j]
        let b = dp[i * (n + 1) + (j - 1)]
        dp[i * (n + 1) + j] = if a > b { a } else { b }
      }
      j = j + 1
    }
    i = i + 1
  }
  dp[m * (n + 1) + n]
}

///|
pub fn edit_distance(old : Array[Int], new : Array[Int]) -> Int {
  let m = old.length()
  let n = new.length()
  let dp = Array::make((m + 1) * (n + 1), 0)
  let mut i = 0
  while i <= m {
    dp[i * (n + 1)] = i
    i = i + 1
  }
  let mut j = 0
  while j <= n {
    dp[j] = j
    j = j + 1
  }
  let mut ii = 1
  while ii <= m {
    let mut jj = 1
    while jj <= n {
      if old[ii - 1] == new[jj - 1] {
        dp[ii * (n + 1) + jj] = dp[(ii - 1) * (n + 1) + (jj - 1)]
      } else {
        let a = dp[(ii - 1) * (n + 1) + jj] + 1
        let b = dp[ii * (n + 1) + (jj - 1)] + 1
        let c = dp[(ii - 1) * (n + 1) + (jj - 1)] + 1
        let min_ab = if a < b { a } else { b }
        dp[ii * (n + 1) + jj] = if min_ab < c { min_ab } else { c }
      }
      jj = jj + 1
    }
    ii = ii + 1
  }
  dp[m * (n + 1) + n]
}

///|
pub fn diff_sequences(old : Array[Int], new : Array[Int]) -> SequenceDiff {
  let m = old.length()
  let n = new.length()
  let dp = Array::make((m + 1) * (n + 1), 0)
  let mut i = 0
  while i <= m {
    dp[i * (n + 1)] = i
    i = i + 1
  }
  let mut j = 0
  while j <= n {
    dp[j] = j
    j = j + 1
  }
  let mut ii = 1
  while ii <= m {
    let mut jj = 1
    while jj <= n {
      if old[ii - 1] == new[jj - 1] {
        dp[ii * (n + 1) + jj] = dp[(ii - 1) * (n + 1) + (jj - 1)]
      } else {
        let a = dp[(ii - 1) * (n + 1) + jj] + 1
        let b = dp[ii * (n + 1) + (jj - 1)] + 1
        let c = dp[(ii - 1) * (n + 1) + (jj - 1)] + 1
        let min_ab = if a < b { a } else { b }
        dp[ii * (n + 1) + jj] = if min_ab < c { min_ab } else { c }
      }
      jj = jj + 1
    }
    ii = ii + 1
  }
  let ops : Array[EditOp] = []
  let mut ci = m
  let mut cj = n
  while ci > 0 || cj > 0 {
    if ci > 0 && cj > 0 && old[ci - 1] == new[cj - 1] {
      ops.push(Keep)
      ci = ci - 1
      cj = cj - 1
    } else if ci > 0 &&
      cj > 0 &&
      dp[ci * (n + 1) + cj] == dp[(ci - 1) * (n + 1) + (cj - 1)] + 1 {
      ops.push(Delete)
      ci = ci - 1
      cj = cj - 1
    } else if cj > 0 && dp[ci * (n + 1) + cj] == dp[ci * (n + 1) + (cj - 1)] + 1 {
      ops.push(Insert)
      cj = cj - 1
    } else if ci > 0 {
      ops.push(Delete)
      ci = ci - 1
    } else {
      ops.push(Insert)
      cj = cj - 1
    }
  }
  let reversed : Array[EditOp] = []
  let mut k = ops.length() - 1
  while k >= 0 {
    reversed.push(ops[k])
    k = k - 1
  }
  { ops: reversed, distance: dp[m * (n + 1) + n] }
}
