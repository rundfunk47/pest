//
//  AppDelegate.swift
//  pest
//
//  Created by Narek M on 21/02/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var statusItem: NSStatusItem?
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBAction func settingsClicked(sender: AnyObject) {
        window.orderFront(self)
    }
    
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func updateToggleStartupState() {
        if (applicationIsInStartUpItems()) {
            toggleStartup.state = NSOnState
        } else {
            toggleStartup.state = NSOffState
        }
    }
    
    @IBAction func toggleStartupClicked(sender: AnyObject) {
        toggleLaunchAtStartup()
        updateToggleStartupState()
    }

    @IBOutlet weak var toggleStartup: NSMenuItem!
    
    var commands = Command.getSavedCommands()
    
    @objc private func editedCommands(notification: NSNotification){
        self.commands = notification.object as! [Command]
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        updateToggleStartupState()
        
        if (commands.count == 0) {
            Command(name: "Date and Name", commandToExecute: "echo `date \"+%Y-%m-%d\"` `whoami`", character: "v", shift: true, control: false, alt: false, command: true, fn: false).save()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editedCommands:", name:"EditedCommands", object: nil)
        
        if (AXIsProcessTrusted()) {
            self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
            let icon = NSImage(named: "icon")
            icon?.template = true
            self.statusItem?.image = icon
            self.statusItem?.menu = statusMenu
            
            NSEvent.addGlobalMonitorForEventsMatchingMask([NSEventMask.KeyDownMask, NSEventMask.FlagsChangedMask]) {
                [weak self](event: NSEvent) -> Void in
                if event.type == NSEventType.KeyDown {
                    for command in self!.commands {
                        if ((event.modifierFlags.rawValue & NSEventModifierFlags.DeviceIndependentModifierFlagsMask.rawValue) == command.mask) {
                            if (event.charactersIgnoringModifiers == nil || event.charactersIgnoringModifiers!.lowercaseString != command.character.lowercaseString) {
                                return
                            }
                            
                            // copy
                            let pasteboard = NSPasteboard.generalPasteboard()
                            let oldContent = pasteboard.save()
                            
                            // new value in pasteboard
                            do {
                                let output = try shell(command.commandToExecute)
                                pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
                                pasteboard.setString(output, forType: NSPasteboardTypeString)
                                
                                // paste
                                let key = CGKeyCode(9) //v
                                let source = CGEventSourceCreate(.CombinedSessionState)
                                let keyDown = CGEventCreateKeyboardEvent(source, key, true)
                                CGEventSetFlags(keyDown, .MaskCommand)
                                let keyUp = CGEventCreateKeyboardEvent(source, key, false)
                                
                                CGEventPost(CGEventTapLocation.CGHIDEventTap, keyDown)
                                CGEventPost(CGEventTapLocation.CGHIDEventTap, keyUp)
                                
                                delay(0.1, closure: { () -> () in
                                    pasteboard.restore(oldContent)
                                })
                            } catch let error as NSError {
                                let alert = NSAlert()
                                alert.addButtonWithTitle("OK")
                                alert.messageText = error.localizedDescription + error.localizedFailureReason!
                                alert.runModal()
                            }
                        }
                    }
                }
            }
        } else {
            let alert = NSAlert()
            alert.addButtonWithTitle("OK")
            alert.messageText = "In order to get pest to work, you need to allow it in System Preferences / Security & Privacy / Privacy / Accessibility."
            let response = alert.runModal()
            
            if (response == 1000) {
                NSApplication.sharedApplication().terminate(self)
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
