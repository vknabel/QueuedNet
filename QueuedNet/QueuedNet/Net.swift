//
//  Net.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

public class Net<T: NetNodeRawType> {
    
    public let nodes: [T:NetNode<T>] = [:]
    public let initials: [T]
    
    public init(builder: NetBuilder<T>) {
        self.nodes = builder.nodes
        self.initials = builder.initials
    }
    
    public func run() {
        self.initials.map { self.nodes[$0]! }.each { n in
            n.run()
        }
    }
    
}

public extension Net {
    public convenience init(initials: [T], buildClosure: NetBuilder<T>.BuildClosure) {
        let builder = NetBuilder<T>(initials: initials, buildClosure: buildClosure)
        self.init(builder: builder)
    }
}
