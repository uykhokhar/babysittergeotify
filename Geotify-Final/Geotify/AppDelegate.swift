/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  let center = UNUserNotificationCenter.current()
  var babySitterNameFromRegion : String?
  var rateFromRegion : Double?
  
  
  enum Notifications : String {
    case buttonCategory = "buttonCategory"
    case alertIdentifier = "BabysitterNotification"
    case pickupAction = "Pickup"
    case dropoffAction = "Dropoff"
    case cancelAction = "Cancel"
  }
  
  
  let pickupAction = UNNotificationAction(identifier: Notifications.pickupAction.rawValue,
                                          title: Notifications.pickupAction.rawValue, options: [])
  let dropoffAction = UNNotificationAction(identifier: Notifications.dropoffAction.rawValue,
                                           title: Notifications.dropoffAction.rawValue, options: [])
  let cancelAction = UNNotificationAction(identifier: Notifications.cancelAction.rawValue,
                                          title: Notifications.dropoffAction.rawValue, options: [.destructive])
  
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
    center.delegate = self
    
    locationManager.delegate = self as CLLocationManagerDelegate
    locationManager.requestAlwaysAuthorization()
    
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
      // Enable or disable features based on authorization.
      if !granted {
        print("App requires notifications. Please enable them.")
      }
    }
    
    let pickupAction = UNNotificationAction(identifier: Notifications.pickupAction.rawValue,
                                            title: Notifications.pickupAction.rawValue, options: [])
    let dropoffAction = UNNotificationAction(identifier: Notifications.dropoffAction.rawValue,
                                            title: Notifications.dropoffAction.rawValue, options: [])
    let cancelAction = UNNotificationAction(identifier: Notifications.cancelAction.rawValue,
                                             title: Notifications.cancelAction.rawValue, options: [.destructive])
    let category = UNNotificationCategory(identifier: Notifications.buttonCategory.rawValue,
                                          actions: [pickupAction,dropoffAction, cancelAction],
                                          intentIdentifiers: [], options: [])
    center.setNotificationCategories([category])
    center.removeAllPendingNotificationRequests()
    
    return true
  }
  
  
  func handleEvent(forRegion region: CLRegion!) {
    // Show an alert if application is active
    guard let babysitterName = name(fromRegionIdentifier: region.identifier) else { return }
    guard let rate = rate(fromRegionIdentifier: region.identifier) else { return }
    
    babySitterNameFromRegion = babysitterName
    rateFromRegion = Double(rate)
    
    print("arrived at \(babysitterName)")
    
    
    let content = UNMutableNotificationContent()
    content.title = "Arrived at \(babysitterName)"
    content.body = "Are you picking up or dropping off"
    content.sound = UNNotificationSound.default()
    content.categoryIdentifier = Notifications.buttonCategory.rawValue
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,repeats: false)
    
    let identifier = Notifications.alertIdentifier.rawValue
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
    
    center.add(request, withCompletionHandler: { (error) in
      if error != nil {
        // Something went wrong
        print("notification request could not be added")
      }
    })
    
//    if UIApplication.shared.applicationState == .active {
//      guard let babySitterName = note(fromRegionIdentifier: region.identifier) else { return }
//      
//      let alertController = UIAlertController(title: "Arrived at \(babySitterName)", message: "Are you picking up or dropping off", preferredStyle: .actionSheet)
//      let dropOffAction = UIAlertAction(title: "Dropping off", style: UIAlertActionStyle.default) {
//        UIAlertAction in
//        NSLog("Dropping off")
//        
//        /// ***** TODO: make method for updating icloud
//      }
//      let pickupAction = UIAlertAction(title: "Picking up", style: UIAlertActionStyle.default) {
//        UIAlertAction in
//        NSLog("Picking up")
//      }
//      
//      let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
//        UIAlertAction in
//        NSLog("Picking up")
//      }
//      
//      alertController.addAction(dropOffAction)
//      alertController.addAction(pickupAction)
//      alertController.addAction(cancelAction)
//      self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    } 
    
    //else {
////      // Otherwise present a local notification
////      let notification = UNLocalNotification()
////      notification.alertBody = note(fromRegionIdentifier: region.identifier)
////      notification.soundName = "Default"
////      notification.alertAction = "notification action"
////      UIApplication.shared.presentLocalNotificationNow(notification)
////    }
  }
  
  func name(fromRegionIdentifier identifier: String) -> String? {
    let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
    let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
    let index = geotifications?.index { $0?.identifier == identifier }
    let name = index != nil ? geotifications?[index!]?.babySitterName : nil
    return name
  }
  
  func rate(fromRegionIdentifier identifier: String) -> Double? {
    let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
    let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
    let index = geotifications?.index { $0?.identifier == identifier }
    let rate = index != nil ? geotifications?[index!]?.rate : nil
    return rate
  }
  
  
}

extension AppDelegate: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region)
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Play sound and show alert to the user
    completionHandler([.alert,.sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    
    // Determine the user action
    switch response.actionIdentifier {
    case UNNotificationDismissActionIdentifier:
      print("Dismiss Action")
    case UNNotificationDefaultActionIdentifier:
      print("Default")
    case Notifications.dropoffAction.rawValue:
      print(Notifications.dropoffAction.rawValue)
      print(babySitterNameFromRegion ?? "no name obtained")
      print(rateFromRegion ?? "no rate obtained")
      let recordid = CloudKitManager.sharedInstance.addEntry(sitter: babySitterNameFromRegion!, inputTime: Date() as NSDate, pickupOrDropoff: Notifications.dropoffAction.rawValue, rate: rateFromRegion!)
      print(recordid ?? "no record id obtained")
    case Notifications.pickupAction.rawValue:
      print(Notifications.pickupAction.rawValue)
      print(babySitterNameFromRegion ?? "no name obtained")
      print(rateFromRegion ?? "no rate obtained")
      let recordid = CloudKitManager.sharedInstance.addEntry(sitter: babySitterNameFromRegion!, inputTime: Date() as NSDate, pickupOrDropoff: Notifications.pickupAction.rawValue, rate: rateFromRegion!)
      print(recordid ?? "no record id obtained")
    case Notifications.cancelAction.rawValue:
      print(Notifications.cancelAction.rawValue)
    default:
      print("Unknown action")
    }
    completionHandler()
  }
}



