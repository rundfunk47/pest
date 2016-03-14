//
//  UsefulMethods.swift
//  pest
//
//  Created by Narek M on 21/02/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Cocoa

func shell(args: String...) throws -> String {
    let task = NSTask()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c"] + args
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    if (task.terminationStatus != 0) {
        throw NSError(domain: "PestErrorDomain", code: Int(task.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Command exited with non zero exit code"])
    } else {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        output.removeAtIndex(output.endIndex.predecessor()) //remove last character (newline)
        return output
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}