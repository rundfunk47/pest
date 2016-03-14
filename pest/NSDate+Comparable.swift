//
//  NSDate+Comparable.swift
//  pest
//
//  Created by Narek M on 13/03/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Foundation

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate : Comparable { }