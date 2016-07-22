//
//  Notification.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/31/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
class Notification {
    static var realm = try! Realm()
    static func scheduleNotifications() {
        let result = realm.objects(RLMNotification)
        do {
            try realm.write {
                var totalObjects = 0
                var lastSavedDate = NSDate()
                for (index,note) in result.enumerate() {
                    if index == result.count - 1 {
                        lastSavedDate = note.fireDate
                    }
                    if note.fireDate.earlierDate(NSDate()).isEqualToDate(note.fireDate) {
                        print("deleting past notification:",note.fireDate)
                        realm.delete(note)
                    } else {
                        totalObjects += 1
                    }
                }
                let flags: NSCalendarUnit = [NSCalendarUnit.Second, NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year]
                var components = NSCalendar.currentCalendar().components(flags, fromDate: lastSavedDate)
                var uuid: String
                for _ in totalObjects..<64 {
                    components = incrementCalendarComponents(components)
                    let date = NSCalendar.currentCalendar().dateFromComponents(components)
                    if [9,13,21].contains(components.hour) {
                        print("creating meal notification, date:",date!)
                        uuid = scheduleMealNotification(date!)
                        realm.add(realm.create(RLMNotification.self, value: RLMNotification(value:["id":uuid, "fireDate":date!,"type":"Meal"]), update: false))
                    } else {
                        uuid = scheduleEnergyLevelNotification(date!)
                        realm.add(realm.create(RLMNotification.self, value: RLMNotification(value:["id":uuid, "fireDate":date!,"type":"EnergyLevel"]), update: false))
                    }
                }
            }
        } catch let error as NSError {
            print("error in saving realm notifications:",error)
        }
    }
    static func incrementCalendarComponents(components:NSDateComponents)->NSDateComponents {
        //set notifications for 9, 13, 21 for meals
        //and 10, 12, 14, 16, 18, 20, 22, 24
        var newHour = components.hour
        let newDay = NSDateComponents()
        newDay.day = 0
        switch components.hour {
        case 0..<9:
            newHour = 9
        case 9..<10:
            newHour = 10
        case 10..<12:
            newHour = 12
        case 12..<13:
            newHour = 13
        case 13..<14:
            newHour = 14
        case 14..<16:
            newHour = 16
        case 16..<18:
            newHour = 18
        case 18..<20:
            newHour = 20
        case 20..<21:
            newHour = 21
        case 21..<22:
            newHour = 22
        case 22..<24:
            newHour = 24
        default:
            newHour = 9
            newDay.day = 1
        }
        components.hour = newHour
        components.minute = 0
        components.second = 0
        let currentDate = NSCalendar.currentCalendar().dateFromComponents(components)
        let newDate = NSCalendar.currentCalendar().dateByAddingComponents(newDay, toDate: currentDate!,options:NSCalendarOptions(rawValue: 0))
        
        let flags: NSCalendarUnit = [NSCalendarUnit.Second, NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: newDate!)
        return components
    }
    static func scheduleEnergyLevelNotification(fireDate:NSDate) -> String {
        let uuid = Utils.newUUID()
        scheduleNotification("Time to set your energy level", fireDate: fireDate, userInfo: uuid, category: "EnergyLevel")
        return uuid
    }
    static func scheduleMealNotification(fireDate:NSDate) -> String {
        let uuid = Utils.newUUID()
        scheduleNotification("Reminder: record what you're eating!", fireDate: fireDate, userInfo: uuid, category: "Meal")
        return uuid
    }
    static func scheduleNotification(body:String,fireDate:NSDate,userInfo:String,category:String) {
        let notification = UILocalNotification()
        notification.alertBody = body // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = fireDate // todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["UUID": userInfo, ] // assign a unique identifier to the notification so that we can retrieve it later
        notification.category = category
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}