# QueuedNet
QueuedNet is a Swift framework to parallelize applications more declaratively. 

## Example
```swift
enum Test: String, Printable, NetNodeRawType {
    case a, b, c, d
    
    var description: String { return self.rawValue }
}

let net = Net<Test>(initials: [.a]) { builder in
    builder.addTransition(from: [.a], to: [.b, .c], perform: { _ in
        println("t1")
      }, error: { _ in
        print("e1")
    })
    builder.addTransition(from: [.b, .c], to: [.d], perform: { _ in
        println("t2,3")
      }, error: { _ in
        print("e2")
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
