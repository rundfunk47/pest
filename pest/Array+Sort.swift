//
//  Array+Sort.swift
//  pest
//
//  Created by Narek M on 14/03/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Foundation

extension Array {
    // generously stolen from:
    // http://stackoverflow.com/questions/26678362/how-do-i-insert-an-element-at-the-correct-position-into-a-sorted-array-in-swift
    private func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
    
    mutating func insertSorted(elem: Element, isOrderedBefore: (Element, Element) -> Bool) {
        let index = self.insertionIndexOf(elem, isOrderedBefore: isOrderedBefore)
        self.insert(elem, atIndex: index)
    }
}