# QueuedNet
QueuedNet is a Swift framework to parallelize applications more declaratively. 

## Example
```swift
enum Test: String, Printable, NetNodeRawType {
    case A="A", B="B", C="C", D="D"
    
    var description: String { return self.rawValue }
}

let net = Net<Test>(initials: [.A]) { (builder: NetBuilder<Test>) -> () in
    builder.addTransition(from: [.A], to: [.B, .C], perform: { (n: NetTransition<Test>) -> () in
        println("t1")
      }, error: { (n: NetNode<Test>) -> () in
        println("e1")
    })
    builder.addTransition(from: [.B, .C], to: [.D], perform: { (n: NetTransition<Test>) -> () in
        println("t2,3")
      }, error: { (n: NetNode<Test>) -> () in
        println("e2")
    })
}
```

## Terms
Term                | Type	                  | Description
--------------------|-------------------------|--------------------
Net                 | `Net`                   | Contains all nodes.
Builder             | `NetBuilder`            | Used to build nets.
Node                | `NetNode`               | Usually build with an enum type, e.g. `.StoringImage`.
Transition          | `NetTransition`         | Connections between nodes. 
Node State          | `NetNodeState`          | One of `.Ready`, `.Running`, `.Finished`, `.Triggered`, `.Error` 
Transition Handler  | `NetTransition -> Void` | Will be run if its transition's input nodes' states are all set to `.Triggered`. Will be called in the transition's queue.
Error Handler       | `NetNode -> Void`       | Will be run if one of its transition's input node's state is set to `.Error`. Will be called in the transition's queue.
State Handler       | `NetNode -> Void`       | Will be called in a set queue if a node .
Queue               | `NSOperationQueue`      | Queues run in their own thread, hence parallel.
