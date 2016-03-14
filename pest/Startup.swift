//
//  Startup.swift
//  pest
//
//  Created by Narek M on 14/03/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Foundation

var appName : String {
    get {
        return NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath).lastPathComponent!.stringByReplacingOccurrencesOfString(".app", withString: "")
    }
}

var appPath : String {
    get {
        return NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath).path!
    }
}

// This is a pretty hackish way of doing this
// a bundled startup-helper is the 'correct' way buuut that includes too much effort.
// http://blog.timschroeder.net/2012/07/03/the-launch-at-login-sandbox-project/
func applicationIsInStartUpItems() -> Bool {
    let script = NSAppleScript(source: "tell application \"System Events\" to get every login item whose name is \"" + appName + "\"")
    
    if let output: NSAppleEventDescriptor = script?.executeAndReturnError(nil) where output.numberOfItems == 1 {
        return true
    }
    
    return false
}

func toggleLaunchAtStartup() {
    if (applicationIsInStartUpItems()) {
        NSAppleScript(source: "tell application \"System Events\" to delete every login item whose name is \"" + appName + "\"")?.executeAndReturnError(nil)
    } else {
        NSAppleScript(source: "tell application \"System Events\" to make login item at end with properties {path: \"" + appPath + "\", hidden:false, name:\"" + appName + "\"}")?.executeAndReturnError(nil)
    }
}