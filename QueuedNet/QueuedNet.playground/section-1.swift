// Playground - noun: a place where people can play

import XCPlayground
import QueuedNet

var str = "Hello, playground"

enum Test: String, Printable, NetNodeRawType {
    case a, b, c, d
    
    var description: String {
        return self.rawValue
    }
}

let net = Net<Test>(initials: [.a]) { (builder: NetBuilder<Test>) -> () in
    builder.addTransition(from: [.a], to: [.b, .c], perform: { (n: NetTransition<Test>) -> () in
        println("t1")
        
        }, error: { (n: NetNode<Test>) -> () in
        println("e1")
    })
    builder.addTransition(from: [.b, .c], to: [.d], perform: { (n: NetTransition<Test>) -> () in
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

