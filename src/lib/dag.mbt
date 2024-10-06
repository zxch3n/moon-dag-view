pub struct Node {
  id : String
  deps : Array[String]
  lamport : Int
} derive(FromJson, ToJson, Show)

pub struct Thread {
  tid : Int
  mut deps : Array[String]
  mut dep_on_active : Bool
} derive(FromJson, ToJson)

/// When visualize the row, we need to 
/// 
/// - Connect each thread from input to cur_tids
/// - Connect each thread from cur_tids to output
/// - Highlight the active node in `cur_tids`
/// - Output the message after the row graph visualization
pub struct Row {
  /// The current active item. Each row contains and only contains 1 active item. 
  active : HistoryItem
  active_index : Int
  /// If a node in input has `dep_on_this`, we need to connect it to the active thread.
  /// 
  /// If it's not empty, it must contain the current active item's tid.
  input : Array[Thread]
  /// The current tids in the row. It must include the current active item's tid.
  cur_tids : Array[Int]
  /// If a node in output has `dep_on_this`, we need to connect it to the active thread.
  output : Array[Thread]
} derive(FromJson, ToJson)

pub struct DagView {
  rows : Array[Row]
} derive(FromJson, ToJson)

struct HistoryItem {
  node : Node
  tid : Int
} derive(FromJson, ToJson)

impl Compare for HistoryItem with compare(a : HistoryItem, b : HistoryItem) -> Int {
  let ans = a.node.lamport - b.node.lamport
  if ans == 0 {
    a.node.id.compare(b.node.id)
  } else {
    ans
  }
}

impl Eq for HistoryItem with op_equal(a : HistoryItem, b : HistoryItem) -> Bool {
  a.node.id == b.node.id
}

pub fn visualize(
  find : (String) -> Node?,
  frontiers : Array[String]
) -> DagView {
  let queue : @moonbitlang/core/priority_queue.T[HistoryItem] = @moonbitlang/core/priority_queue.T::new()
  let visited : @moonbitlang/core/hashmap.T[String, Int] = @moonbitlang/core/hashmap.T::new()
  let mut next_tid = 0
  for id in frontiers.iter() {
    let node = find(id).unwrap()
    queue.push({ node, tid: next_tid })
    let _ = visited.set(node.id, next_tid)
    next_tid += 1
  }
  let ans = { rows: [] }
  while not(queue.is_empty()) {
    let top = queue.pop().unwrap()
    let input = ans.rows
      .last()
      .map(
        fn(x) {
          x.output
          .iter()
          .map(
            fn(x) {
              let mut dep_on_this = false
              dep_on_this = false
              let deps = x.deps.copy()
              for i = 0; i < deps.length(); i = i + 1 {
                if deps[i] == top.node.id {
                  dep_on_this = true
                  deps[i] = deps[deps.length() - 1]
                  let _ = deps.pop()
                  break
                }
              }
              dep_on_this = dep_on_this || top.tid == x.tid
              { tid: x.tid, dep_on_active: dep_on_this, deps }
            },
          )
          .collect()
        },
      )
      .or([])
    let mut this_thread = None
    let output = input
      .map(
        fn(x) {
          return { tid: x.tid, dep_on_active: x.dep_on_active, deps: x.deps }
        },
      )
      .filter(
        fn(x) {
          if x.tid == top.tid {
            this_thread = Some(x)
            return not(top.node.deps.is_empty())
          }
          not(x.deps.is_empty())
        },
      )
    let cur_tids = output.map(fn(x) { x.tid })
    if not(cur_tids.iter().any(fn(x) { x == top.tid })) {
      cur_tids.push(top.tid)
    }
    let cur_index = cur_tids.search_by(fn(x) { x == top.tid }).unwrap()
    if top.node.deps.length() > 0 {
      let node = find(top.node.deps[0]).unwrap()
      if not(visited.contains(node.id)) {
        queue.push({ node, tid: top.tid })
        visited.set(node.id, top.tid)
        match this_thread {
          Some(this_thread) => this_thread.deps = [node.id]
          None =>
            output.push({ tid: top.tid, deps: [node.id], dep_on_active: true })
        }
      } else {
        match this_thread {
          Some(this_thread) => this_thread.deps = [node.id]
          None => ()
        }
      }
    }
    for i = 1; i < top.node.deps.length(); i = i + 1 {
      let node = find(top.node.deps[i]).unwrap()
      if not(visited.contains(node.id)) {
        queue.push({ node, tid: next_tid })
        visited.set(node.id, next_tid)
        output.push({ tid: next_tid, deps: [node.id], dep_on_active: true })
        next_tid += 1
      } else {
        let target_tid = visited.get(node.id).unwrap()
        match output.search_by(fn(x) { x.tid == target_tid }) {
          Some(target_index) => output[target_index].dep_on_active = true
          None => ()
        }
      }
    }
    ans.rows.push(
      {
        active: { tid: top.tid, node: top.node },
        active_index: cur_index,
        input,
        output,
        cur_tids,
      },
    )
  }
  ans
}

pub fn render_dag_as_text(view : DagView) -> String {
  let buffer = Buffer::new()
  for row in view.rows.iter() {
    render_row_as_text(row, buffer)
  }
  buffer.to_string()
}

struct ConnectStatus {
  mut up : Bool
  mut down : Bool
  mut right : Bool
  mut left : Bool
} derive(Show)

fn set_connections(
  connections : Array[ConnectStatus],
  index : Int,
  target : Int?
) -> Unit {
  match target {
    Some(target) => {
      if target == index {
        connections[index].up = true
        connections[target].down = true
      } else if target > index {
        connections[index].right = true
        for i = index + 1; i < target; i = i + 1 {
          connections[i].left = true
          connections[i].right = true
        }
        connections[target].left = true
      } else if target < index {
        connections[index].left = true
        for i = target + 1; i < index; i = i + 1 {
          connections[i].left = true
          connections[i].right = true
        }
        connections[target].right = true
      }
      ()
    }
    None => ()
  }
}

fn max(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

fn render_row_as_text(row : Row, buffer : Buffer) -> Unit {
  {
    let input_conn = Array::make(
      max(row.input.length(), row.cur_tids.length()),
      0,
    ).map(
      fn(_x) { return { up: false, down: false, left: false, right: false } },
    )
    for i, input_thread in row.input.iter2() {
      let connection_a = row.cur_tids.search(input_thread.tid)
      let connection_b = if input_thread.dep_on_active {
        Some(row.active_index)
      } else {
        None
      }
      input_conn[i].up = true
      set_connections(input_conn, i, connection_a)
      set_connections(input_conn, i, connection_b)
    }
    for i = 0; i < row.cur_tids.length(); i = i + 1 {
      input_conn[i].down = true
    }
    render_connections(input_conn, buffer)
  }
  {
    buffer.write_string("\n")
    for cur_tid in row.cur_tids.iter() {
      if cur_tid == row.active.tid {
        buffer.write_string(" ⊙ ")
      } else {
        buffer.write_string(" │ ")
      }
    }
    buffer.write_string(" \{row.active.node.id}")
    buffer.write_string("\n")
  }
  let output_conn = Array::make(
    max(row.output.length(), row.cur_tids.length()),
    0,
  ).map(fn(_x) { return { up: false, down: false, left: false, right: false } })
  for cur_index, output_thread in row.output.iter2() {
    let a = row.cur_tids.search(output_thread.tid)
    let b = if output_thread.dep_on_active {
      Some(row.active_index)
    } else {
      None
    }
    output_conn[cur_index].down = true
    set_connections(output_conn, cur_index, a)
    set_connections(output_conn, cur_index, b)
  }
  for i = 0; i < row.cur_tids.length(); i = i + 1 {
    output_conn[i].up = true
  }
  render_connections(output_conn, buffer)
  buffer.write_string("\n")
}

fn render_connections(
  connections : Array[ConnectStatus],
  buffer : Buffer
) -> Unit {
  for c in connections.iter() {
    render_connection(c, buffer)
  }
}

fn render_connection(c : ConnectStatus, buffer : Buffer) -> Unit {
  if c.up && c.down && c.left && c.right {
    buffer.write_string("─┼─")
  } else if c.down && c.left && c.right {
    buffer.write_string("─┬─")
  } else if c.up && c.left && c.right {
    buffer.write_string("─┴─")
  } else if c.up && c.down && c.left {
    buffer.write_string("─┤ ")
  } else if c.up && c.down && c.right {
    buffer.write_string(" ├─")
  } else if c.up && c.left {
    buffer.write_string("─╯ ")
  } else if c.up && c.right {
    buffer.write_string(" ╰─")
  } else if c.down && c.left {
    buffer.write_string("─╮ ")
  } else if c.down && c.right {
    buffer.write_string(" ╭─")
  } else if c.up && c.down {
    buffer.write_string(" │ ")
  } else if c.left && c.right {
    buffer.write_string("───")
  } else {
    buffer.write_string("   ")
  }
}
