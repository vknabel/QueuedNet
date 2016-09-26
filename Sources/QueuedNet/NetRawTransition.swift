//
//  NetRawTransition.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 03.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

internal struct NetRawTransition<T: NetNodeRawType> {
    internal typealias TransitionHandler = (NetTransition<T>) -> ()
    internal typealias ErrorHandler = (NetNode<T>) -> ()
    
    internal let inputNodes: [T]
    internal let outputNodes: [T]
    internal let transitionHandler: TransitionHandler?
    internal let errorHandler: ErrorHandler?
    
    internal init(inputNodes: [T], outputNodes: [T], transitionHandler: TransitionHandler? = nil, errorHandler: ErrorHandler? = nil) {
        assert(inputNodes.count > 0, "Transitions must always have at least one input node.")
        self.inputNodes = inputNodes
        assert(outputNodes.count > 0, "Transitions must always have at least one ouptut node.")
        self.outputNodes = outputNodes
        self.transitionHandler = transitionHandler
        self.errorHandler = errorHandler
    }
    
    func transtition(nodes: [T: NetNode<T>]) -> NetTransition<T> {
        func getNodes(raws: [T]) -> [NetNode<T>] {
            let ns = raws.map { (r: T) -> NetNode<T> in
                assert(nodes[r] != nil, "Raw value \(r) for Node not provided.")
                return nodes[r]!
            }
            return ns
        }
        return NetTransition<T>(inputNodes: getNodes(raws: inputNodes),
            outputNodes: getNodes(raws: outputNodes),
            transitionHandler: transitionHandler,
            errorHandler: errorHandler)
    }
}
