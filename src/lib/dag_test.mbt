struct TestDag {
  nodes : Map[String, @lib.Node]
}

fn gen_find(dag : TestDag) -> (String) -> @lib.Node? {
  fn find(id : String) -> @lib.Node? {
    let ans = dag.nodes.get(id)
    ans
  }

  find
}

test "basic visualization" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2": @lib.Node::{ id: "2", lamport: 2, deps: ["1"] },
    },
  }
  inspect!(
    @lib.visualize(gen_find(dag), ["2"]).to_json().stringify(indent=2),
    content=
      #|{
      #|  "rows": [
      #|    {
      #|      "active": {
      #|        "node": {
      #|          "id": "2",
      #|          "deps": [
      #|            "1"
      #|          ],
      #|          "lamport": 2
      #|        },
      #|        "tid": 0
      #|      },
      #|      "active_index": 0,
      #|      "input": [],
      #|      "cur_tids": [
      #|        0
      #|      ],
      #|      "output": [
      #|        {
      #|          "tid": 0,
      #|          "deps": [
      #|            "1"
      #|          ],
      #|          "dep_on_active": true
      #|        }
      #|      ]
      #|    },
      #|    {
      #|      "active": {
      #|        "node": {
      #|          "id": "1",
      #|          "deps": [],
      #|          "lamport": 1
      #|        },
      #|        "tid": 0
      #|      },
      #|      "active_index": 0,
      #|      "input": [
      #|        {
      #|          "tid": 0,
      #|          "deps": [],
      #|          "dep_on_active": true
      #|        }
      #|      ],
      #|      "cur_tids": [
      #|        0
      #|      ],
      #|      "output": [
      #|        {
      #|          "tid": 0,
      #|          "deps": [],
      #|          "dep_on_active": true
      #|        }
      #|      ]
      #|    }
      #|  ]
      #|}
    ,
  )
}

test "concurrent changes visualization" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2.1": @lib.Node::{ id: "2.1", lamport: 2, deps: ["1"] },
      "2.2": @lib.Node::{ id: "2.2", lamport: 2, deps: ["1"] },
      "2.3": @lib.Node::{ id: "2.3", lamport: 2, deps: ["1"] },
      "3": @lib.Node::{ id: "3", lamport: 3, deps: ["2.1", "2.2", "2.3"] },
    },
  }
  inspect!(
    @lib.visualize(gen_find(dag), ["3"]).to_json().stringify(indent=4),
    content=
      #|{
      #|    "rows": [
      #|        {
      #|            "active": {
      #|                "node": {
      #|                    "id": "3",
      #|                    "deps": [
      #|                        "2.1",
      #|                        "2.2",
      #|                        "2.3"
      #|                    ],
      #|                    "lamport": 3
      #|                },
      #|                "tid": 0
      #|            },
      #|            "active_index": 0,
      #|            "input": [],
      #|            "cur_tids": [
      #|                0
      #|            ],
      #|            "output": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "2.1"
      #|                    ],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "2.2"
      #|                    ],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "2.3"
      #|                    ],
      #|                    "dep_on_active": true
      #|                }
      #|            ]
      #|        },
      #|        {
      #|            "active": {
      #|                "node": {
      #|                    "id": "2.3",
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "lamport": 2
      #|                },
      #|                "tid": 2
      #|            },
      #|            "active_index": 2,
      #|            "input": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "2.1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "2.2"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                }
      #|            ],
      #|            "cur_tids": [
      #|                0,
      #|                1,
      #|                2
      #|            ],
      #|            "output": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "2.1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "2.2"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": true
      #|                }
      #|            ]
      #|        },
      #|        {
      #|            "active": {
      #|                "node": {
      #|                    "id": "2.2",
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "lamport": 2
      #|                },
      #|                "tid": 1
      #|            },
      #|            "active_index": 1,
      #|            "input": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "2.1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                }
      #|            ],
      #|            "cur_tids": [
      #|                0,
      #|                1,
      #|                2
      #|            ],
      #|            "output": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "2.1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                }
      #|            ]
      #|        },
      #|        {
      #|            "active": {
      #|                "node": {
      #|                    "id": "2.1",
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "lamport": 2
      #|                },
      #|                "tid": 0
      #|            },
      #|            "active_index": 0,
      #|            "input": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                }
      #|            ],
      #|            "cur_tids": [
      #|                0,
      #|                1,
      #|                2
      #|            ],
      #|            "output": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [
      #|                        "1"
      #|                    ],
      #|                    "dep_on_active": false
      #|                }
      #|            ]
      #|        },
      #|        {
      #|            "active": {
      #|                "node": {
      #|                    "id": "1",
      #|                    "deps": [],
      #|                    "lamport": 1
      #|                },
      #|                "tid": 2
      #|            },
      #|            "active_index": 0,
      #|            "input": [
      #|                {
      #|                    "tid": 0,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 1,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                },
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                }
      #|            ],
      #|            "cur_tids": [
      #|                2
      #|            ],
      #|            "output": [
      #|                {
      #|                    "tid": 2,
      #|                    "deps": [],
      #|                    "dep_on_active": true
      #|                }
      #|            ]
      #|        }
      #|    ]
      #|}
    ,
  )
}

test "two concurrent nodes visualization" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2": @lib.Node::{ id: "2", lamport: 1, deps: [] },
    },
  }
  inspect!(
    @lib.visualize(gen_find(dag), ["1", "2"]).to_json().stringify(indent=2),
    content=
      #|{
      #|  "rows": [
      #|    {
      #|      "active": {
      #|        "node": {
      #|          "id": "2",
      #|          "deps": [],
      #|          "lamport": 1
      #|        },
      #|        "tid": 1
      #|      },
      #|      "active_index": 0,
      #|      "input": [],
      #|      "cur_tids": [
      #|        1
      #|      ],
      #|      "output": []
      #|    },
      #|    {
      #|      "active": {
      #|        "node": {
      #|          "id": "1",
      #|          "deps": [],
      #|          "lamport": 1
      #|        },
      #|        "tid": 0
      #|      },
      #|      "active_index": 0,
      #|      "input": [],
      #|      "cur_tids": [
      #|        0
      #|      ],
      #|      "output": []
      #|    }
      #|  ]
      #|}
    ,
  )
}

test "linear changes visualization to text" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2": @lib.Node::{ id: "2", lamport: 2, deps: ["1"] },
    },
  }
  let view = @lib.visualize(gen_find(dag), ["2"])
  inspect!(
    @lib.render_dag_as_text(view),
    content=
      #| │ 
      #| ⊙  2
      #| │ 
      #| │ 
      #| ⊙  1
      #| │ 
      #|
    ,
  )
}

test "concurrent changes visualization to text" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2.1": @lib.Node::{ id: "2.1", lamport: 2, deps: ["1"] },
      "2.2": @lib.Node::{ id: "2.2", lamport: 2, deps: ["1"] },
      "2.3": @lib.Node::{ id: "2.3", lamport: 2, deps: ["1"] },
      "3": @lib.Node::{ id: "3", lamport: 3, deps: ["2.1", "2.2", "2.3"] },
    },
  }
  let view = @lib.visualize(gen_find(dag), ["3"])
  inspect!(
    @lib.render_dag_as_text(view),
    content=
      #| │ 
      #| ⊙  3
      #| ├──╮ ─╮ 
      #| │  │  │ 
      #| │  │  ⊙  2.3
      #| │  │  │ 
      #| │  │  │ 
      #| │  ⊙  │  2.2
      #| │  │  │ 
      #| │  │  │ 
      #| ⊙  │  │  2.1
      #| │  │  │ 
      #| ├──╯ ─╯ 
      #| ⊙  1
      #| │ 
      #|
    ,
  )
}

test "concurrent changes visualization to text" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2.1": @lib.Node::{ id: "2.1", lamport: 2, deps: ["1"] },
      "2.2": @lib.Node::{ id: "2.2", lamport: 2, deps: ["1"] },
      "2.3": @lib.Node::{ id: "2.3", lamport: 2, deps: ["1"] },
      "2.0": @lib.Node::{ id: "2.0", lamport: 3, deps: ["2.1"] },
      "3": @lib.Node::{
        id: "3",
        lamport: 4,
        deps: ["2.1", "2.2", "2.3", "2.0"],
      },
    },
  }
  let view = @lib.visualize(gen_find(dag), ["3"])
  inspect!(
    @lib.render_dag_as_text(view),
    content=
      #| │ 
      #| ⊙  3
      #| ├──╮ ─╮ ─╮ 
      #| │  │  │  │ 
      #| │  │  │  ⊙  2.0
      #| │  │  │  │ 
      #| │  │  │  │ 
      #| │  │  ⊙  │  2.3
      #| │  │  │  │ 
      #| │  │  │  │ 
      #| │  ⊙  │  │  2.2
      #| │  │  │  │ 
      #| ├──┼──┼──╯ 
      #| ⊙  │  │  2.1
      #| │  │  │ 
      #| ├──╯ ─╯ 
      #| ⊙  1
      #| │ 
      #|
    ,
  )
}

test "complex changes visualization to text" {
  let dag = {
    nodes: {
      "1": @lib.Node::{ id: "1", lamport: 1, deps: [] },
      "2.1": @lib.Node::{ id: "2.1", lamport: 2, deps: ["1"] },
      "2.2": @lib.Node::{ id: "2.2", lamport: 2, deps: ["1"] },
      "2.3": @lib.Node::{ id: "2.3", lamport: 2, deps: ["1"] },
      "3.1": @lib.Node::{ id: "3.1", lamport: 3, deps: ["2.1", "2.2"] },
      "3.2": @lib.Node::{ id: "3.2", lamport: 3, deps: ["2.2", "2.3"] },
      "4.1": @lib.Node::{ id: "4.1", lamport: 4, deps: ["3.1"] },
      "4.2": @lib.Node::{ id: "4.2", lamport: 4, deps: ["3.2"] },
      "5": @lib.Node::{ id: "5", lamport: 5, deps: ["4.1", "4.2"] },
      "6.1": @lib.Node::{ id: "6.1", lamport: 6, deps: ["5"] },
      "6.2": @lib.Node::{ id: "6.2", lamport: 6, deps: ["5"] },
      "7": @lib.Node::{ id: "7", lamport: 7, deps: ["6.1", "6.2"] },
    },
  }
  let view = @lib.visualize(gen_find(dag), ["7"])
  inspect!(
    @lib.render_dag_as_text(view),
    content=
      #| │ 
      #| ⊙  7
      #| ├──╮ 
      #| │  │ 
      #| │  ⊙  6.2
      #| │  │ 
      #| │  │ 
      #| ⊙  │  6.1
      #| │  │ 
      #| ├──╯ 
      #| ⊙  5
      #| ├──╮ 
      #| │  │ 
      #| │  ⊙  4.2
      #| │  │ 
      #| │  │ 
      #| ⊙  │  4.1
      #| │  │ 
      #| │  │ 
      #| │  ⊙  3.2
      #| │  ├──╮ 
      #| │  │  │ 
      #| ⊙  │  │  3.1
      #| ├──┤  │ 
      #| │  │  │ 
      #| │  │  ⊙  2.3
      #| │  │  │ 
      #| │  │  │ 
      #| │  ⊙  │  2.2
      #| │  │  │ 
      #| │  │  │ 
      #| ⊙  │  │  2.1
      #| │  │  │ 
      #| ├──╯ ─╯ 
      #| ⊙  1
      #| │ 
      #|
    ,
  )
}
