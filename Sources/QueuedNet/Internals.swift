//
//  Internals.swift
//  QueuedNet
//
//  Created by Valentin Knabel on 02.03.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

import Foundation

internal extension Array {
    internal func each(action: (Array.Element) -> ()) {
        for e in self {
            action(e)
        }
    }
}


