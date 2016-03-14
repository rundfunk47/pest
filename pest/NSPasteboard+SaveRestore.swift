//
//  NSPasteboard+SaveRestore.swift
//  pest
//
//  Created by Narek M on 21/02/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Cocoa

extension NSPasteboard {
    func save()->Array<NSPasteboardItem> {
        var archive = Array<NSPasteboardItem>()
        for item in self.pasteboardItems! {
            let archivedItem = NSPasteboardItem()
            for type in item.types {
                let data = item.dataForType(type)?.mutableCopy() as? NSData
                if (data != nil) {
                    archivedItem.setData(data, forType: type)
                }
            }
            archive.append(archivedItem)
        }
        return archive
    }
    
    func restore(archive: Array<NSPasteboardItem>) {
        self.clearContents()
        self.writeObjects(archive)
    }
}