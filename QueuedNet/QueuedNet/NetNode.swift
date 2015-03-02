//
//  NetNode.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

public protocol NetNodeRawType: Printable, Hashable { }

public enum NetNodeState: String, Printable {
    case Ready = "Ready"
    case Running = "Running"
    case Finished = "Finished"
    case Triggered = "Triggered"
    case Error = "Error"
    
    public var description: String {
        return self.rawValue
    }
}

public class NetNode<T: NetNodeRawType>: RawRepresentable, Printable {
    public typealias RawValue = T
    public typealias StateHandler = (NetNode<T>) -> ()
    
    public var operationQueue: NSOperationQueue = NSOperationQueue()
    
    private var _state: NetNodeState = .Ready {
        willSet {
            assert(_queueCounter == 0, "\(self) can't set state to \(newValue).")
        }
        didSet {
            stateDidChange()
        }
    }
    private var _rawValue: T
    private var _handlers: [NetNodeState:[(StateHandler, NSOperationQueue)]] = [.Ready:[], .Running:[], .Finished:[], .Error:[], .Triggered: []]
    
    private var _queueCounter: Int = 0 {
        didSet {
            self.operationQueue.addOperationWithBlock {
                if self._queueCounter == 0 {
                    self.operationQueue.addOperationWithBlock {
                        switch self.state {
                        case .Running:
                            self._state = .Finished
                        case .Triggered:
                            self.outgoingTransition?.run()
                        case .Error:
                            self.outgoingTransition?.handleError(self)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    internal var _incomingTransition: NetTransition<T>?
    internal var _outgoingTransition: NetTransition<T>?
    
    public var state: NetNodeState {
        return _state
    }
    public var rawValue: T {
        return _rawValue
    }
    public var incomingTransition: NetTransition<T>? {
        return _incomingTransition
    }
    public var outgoingTransition: NetTransition<T>? {
        return _outgoingTransition
    }
    
    public var description: String {
        return "NetNode<\(self.state), \(self.rawValue.description)>"
    }
    
    public required init?(rawValue: T) {
        self._rawValue = rawValue
    }
    
    public func on(state s: NetNodeState, perform h: StateHandler, queue: NSOperationQueue) {
        if _handlers[s] == nil {
            self._handlers[s] = [(h, queue)]
        }
        else {
            self._handlers[s]?.append((h, queue))
        }
    }
    
    private func stateDidChange() {
        self.operationQueue.addOperationWithBlock { () -> Void in
            let allops = (self._handlers[self.state]) ?? []
            for op in allops {
                self._queueCounter++
                op.1.addOperationWithBlock {
                    op.0(self)
                    self._queueCounter--
                }
            }
            if allops.count == 0 {
                self._queueCounter = 0
            }
        }
    }
    
    public func reset() {
        if self.state == .Triggered {
            self._state = .Ready
        }
        else {
            assertionFailure("\(self.description) can't reset. Should be NetNode<\(NetNodeState.Finished), \(self.rawValue.description)>.")
        }
    }
    
    public func run() {
        if self.state == .Ready {
            self._state = .Running
        }
        else {
            assertionFailure("\(self.description) can't run. Should be NetNode<\(NetNodeState.Finished), \(self.rawValue.description)>.")
        }
    }
    
    public func triggerTransition() {
        if self.state == .Finished {
            self._state = .Triggered
        }
        else {
            assertionFailure("\(self.description) can't trigger. Should be NetNode<\(NetNodeState.Finished), \(self.rawValue.description)>.")
        }
    }
}
