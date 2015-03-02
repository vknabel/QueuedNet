// Playground - noun: a place where people can play

import XCPlayground
import QueuedNet

var str = "Hello, playground"

enum Test: String, Printable, NetNodeRawType {
    case A="A", B="B", C="C", D="D"
    
    var description: String {
        return self.rawValue
    }
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
net.run()
let a = net.nodes[.A]!
println(a)
a.triggerTransition()
println(a)
sleep(1)
net.nodes[.B]!.description
sleep(1)
net.nodes[.B]!.triggerTransition()
net.nodes[.C]!.triggerTransition()

XCPSetExecutionShouldContinueIndefinitely()

