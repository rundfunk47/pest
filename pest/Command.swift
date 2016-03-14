//
//  Command.swift
//  pest
//
//  Created by Narek M on 21/02/16.
//  Copyright © 2016 Narek M. All rights reserved.
//

import Cocoa

class Command : NSObject, NSCoding {
    var date : NSDate
    
    var name : String
    var commandToExecute : String
    
    var character : String
    var shift : Bool
    var control : Bool
    var alt : Bool
    var command : Bool
    var fn : Bool
    
    var flags : [NSEventModifierFlags] {
        var flags = [NSEventModifierFlags]()
        
        if (shift == true) {
            flags.append(.ShiftKeyMask)
        }
        if (control == true) {
            flags.append(.ControlKeyMask)
        }
        if (alt == true) {
            flags.append(.AlternateKeyMask)
        }
        if (command == true) {
            flags.append(.CommandKeyMask)
        }
        if (fn == true) {
            flags.append(.FunctionKeyMask)
        }
        
        return flags
    }
    
    var mask : UInt {
        var mask = UInt()
        for flag in flags {
            mask += flag.rawValue
        }
        return mask
    }

    // Functions:
    
    class func getSavedCommands()->[Command] {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedData = defaults.objectForKey("savedArray") as? NSData {
            let commands = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? [Command]
            if (commands != nil) {
                return commands!.sort({
                    (lhs: Command, rhs: Command) -> Bool in
                    return lhs.date < rhs.date
                })
            }
        }
        return [Command]()
    }
    
    //pokes at defaults!
    func remove() {
        var savedCommands = Command.getSavedCommands()
        var indexToRemove : Int?
        
        for i in 0..<(savedCommands.count) {
            if (savedCommands[i].date == self.date) {
                indexToRemove = i
            }
        }
        
        savedCommands.removeAtIndex(indexToRemove!)
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(savedCommands)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "savedArray")
        defaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName("EditedCommands", object: savedCommands)
    }
    
    //pokes at defaults!
    func save() {
        var savedCommands = Command.getSavedCommands()
        var indexToRemove : Int?
        
        //remove and readd command...
        for i in 0..<(savedCommands.count) {
            if (savedCommands[i].date == self.date) {
                indexToRemove = i
            }
        }
        
        if (indexToRemove != nil) {
            savedCommands.removeAtIndex(indexToRemove!)
        }
        
        savedCommands.append(self)
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(savedCommands)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "savedArray")
        defaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName("EditedCommands", object: savedCommands)
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(commandToExecute, forKey: "commandToExecute")
        aCoder.encodeObject(character, forKey: "character")
        aCoder.encodeObject(shift, forKey: "shift")
        aCoder.encodeObject(control, forKey: "control")
        aCoder.encodeObject(alt, forKey: "alt")
        aCoder.encodeObject(command, forKey: "command")
        aCoder.encodeObject(fn, forKey: "fn")
        aCoder.encodeObject(date, forKey: "date")
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        commandToExecute = aDecoder.decodeObjectForKey("commandToExecute") as! String
        character = aDecoder.decodeObjectForKey("character") as! String
        shift = aDecoder.decodeObjectForKey("shift") as! Bool
        control = aDecoder.decodeObjectForKey("control") as! Bool
        alt = aDecoder.decodeObjectForKey("alt") as! Bool
        command = aDecoder.decodeObjectForKey("command") as! Bool
        fn = aDecoder.decodeObjectForKey("fn") as! Bool
        date = aDecoder.decodeObjectForKey("date") as! NSDate
    }
    
    @objc init(name: String, commandToExecute: String, character: String, shift: Bool, control: Bool, alt: Bool, command: Bool, fn: Bool) {
        self.name = name
        self.commandToExecute = commandToExecute
        self.character = character
        self.shift = shift
        self.control = control
        self.alt = alt
        self.command = command
        self.fn = fn
        self.date = NSDate()
    }
}