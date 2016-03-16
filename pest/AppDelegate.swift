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
    var statusView: NSView?
    var icon: NSImage?
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editedCommands:", name:"EditedCommands", object: nil)
        
        updateToggleStartupState()
        
        if (commands.count == 0) {
            Command(name: "Date and Name", commandToExecute: "echo `date \"+%Y-%m-%d\"` `whoami`", character: "v", shift: true, control: false, alt: false, command: true, fn: false).save()
            Command(name: "What is my IP", commandToExecute: "ifconfig en1 | awk '{ print $2}' | grep -E -o '([0-9]{1,3}[\\.]){3}[0-9]{1,3}'", character: "i", shift: false, control: false, alt: true, command: true, fn: false).save()
            Command(name: "CBSG", commandToExecute: "curl -s http://cbsg.sourceforge.net/cgi-bin/live | grep -Eo '^<li>.*</li>' | sed -e 's/<li>\\(.*\\)<\\/li>/\\1/' | head -n 1", character: "s", shift: false, control: false, alt: true, command: true, fn: false).save()
            Command(name: "External IP", commandToExecute: "dig +short myip.opendns.com @resolver1.opendns.com", character: "e", shift: false, control: false, alt: true, command: true, fn: false).save()
        }
        
        func setStatusbarIcon() {
            if (self.icon == nil) {
                icon = NSImage(named: "icon")
                icon?.template = true
            }
            self.statusItem?.view = nil
            self.statusItem?.image = icon
            self.statusItem?.menu = statusMenu
        }
        
        func setSpinner() {
            if (self.statusView == nil) {
                self.statusView = NSView(frame: NSMakeRect(0, 2, 18, 18))
                let progressIndicator = NSProgressIndicator(frame: NSMakeRect(0, 2, 18, 18))
                progressIndicator.style = NSProgressIndicatorStyle.SpinningStyle
                progressIndicator.hidden = false
                progressIndicator.usesThreadedAnimation = true
                progressIndicator.indeterminate = true
                progressIndicator.startAnimation(true)
                self.statusView?.addSubview(progressIndicator)
            }
            
            self.statusItem?.view = self.statusView
        }
        
        if (!AXIsProcessTrusted()) {
            let alert = NSAlert()
            alert.addButtonWithTitle("OK")
            alert.messageText = "In order to get pest to work, you need to allow it in System Preferences / Security & Privacy / Privacy / Accessibility."
            alert.runModal()
            NSApplication.sharedApplication().terminate(self)
            return
        }
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        setStatusbarIcon()
        
        NSEvent.addGlobalMonitorForEventsMatchingMask([NSEventMask.KeyDownMask, NSEventMask.FlagsChangedMask]) {
            [weak self](event: NSEvent) -> Void in
            if event.type == NSEventType.KeyDown {
                for command in self!.commands {
                    if ((event.modifierFlags.rawValue & NSEventModifierFlags.DeviceIndependentModifierFlagsMask.rawValue) == command.mask) {
                        if (!(event.charactersIgnoringModifiers == nil || event.charactersIgnoringModifiers!.lowercaseString != command.character.lowercaseString)) {
                            // copy
                            let pasteboard = NSPasteboard.generalPasteboard()
                            let oldContent = pasteboard.save()
                            
                            // new value in pasteboard
                            do {
                                setSpinner()
                                let output = try shell(command.commandToExecute)
                                setStatusbarIcon()
                                let icon = NSImage(named: "icon")
                                icon?.template = true
                                self?.statusItem?.image = icon
                                self?.statusItem?.menu = self?.statusMenu
                                
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
                                alert.messageText = error.localizedDescription + ": " + error.localizedFailureReason!
                                setStatusbarIcon()
                                alert.runModal()
                            }
                        }
                    }
                }
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
