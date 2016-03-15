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
    let stdout = NSPipe()
    let stderr = NSPipe()
    task.standardOutput = stdout
    task.standardError = stderr
    task.launch()
    task.waitUntilExit()
    if (task.terminationStatus != 0) {
        let data = stderr.fileHandleForReading.readDataToEndOfFile()
        var output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if (output.characters.count > 0) {
            output.removeAtIndex(output.endIndex.predecessor()) //remove last character (newline)
        }

        throw NSError(domain: "PestErrorDomain", code: Int(task.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Command exited with non zero exit code", NSLocalizedFailureReasonErrorKey: output])
    } else {
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        var output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if (output.characters.count > 0) {
            output.removeAtIndex(output.endIndex.predecessor()) //remove last character (newline)
        }
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