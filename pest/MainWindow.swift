//
//  MainWindow.swift
//  pest
//
//  Created by Narek M on 21/02/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    var commands = Command.getSavedCommands()
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editedCommands:", name:"EditedCommands", object: nil)
    }
    
    @objc private func editedCommands(notification: NSNotification) {
        self.commands = notification.object as! [Command]
        tableView.reloadData()
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.commands.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        switch tableColumn!.identifier {
            case "name":
                return self.commands[row].name
            case "commandToExecute":
                return self.commands[row].commandToExecute
            case "character":
                return self.commands[row].character
            case "shift":
                return self.commands[row].shift
            case "control":
                return self.commands[row].control
            case "alt":
                return self.commands[row].alt
            case "command":
                return self.commands[row].command
            case "fn":
                return self.commands[row].fn
            default:
                return ""
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        let command = self.commands[row]
        
        switch tableColumn!.identifier {
        case "name":
            command.name = object as! String
        case "commandToExecute":
            command.commandToExecute = object as! String
        case "character":
            let string = (object as! String)
            //only save first character...
            let characterCount = string.characters.count
            if characterCount == 0 {
                command.character = ""
            } else {
                let char = string.substringToIndex(string.startIndex.advancedBy(1))
                command.character = char
            }
        case "shift":
            command.shift = object as! Bool
        case "control":
            command.control = object as! Bool
        case "alt":
            command.alt = object as! Bool
        case "command":
            command.command = object as! Bool
        case "fn":
            command.fn = object as! Bool
        default:
            break
        }
        
        command.save()
    }
    
    @IBAction func addCommand(sender: AnyObject) {
        Command(name: "New Command", commandToExecute: "echo Hello world", character: "H", shift: true, control: true, alt: true, command: true, fn: true).save()
    }
    
    @IBAction func removeCommand(sender: AnyObject) {
        if (tableView.selectedRow != -1) {
            self.commands[tableView.selectedRow].remove()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
