//
//  CloudKitManager.swift
//  Geotify
//
//  Created by MouseHouseApp on 5/29/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

open class CloudKitManager {
  
  open static let sharedInstance = CloudKitManager()
  
  // MARK: - CloudKit
  let container: CKContainer = CKContainer.default()
  let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
  let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
  
  /// Current user
  var userRecordID: CKRecordID?
  
  // Keep it safe
  private init() {}
  
  
  //
  // MARK: - User Records
  //
  
  
  /// Get the users `RecordId`
  /// - parameters complete: A completion block passing two parameters
  open func getUserRecordId(complete: @escaping (CKRecordID?, NSError?) -> ()) {
    
    let container = CKContainer.default()
    container.fetchUserRecordID() {
      recordID, error in
      
      if error != nil {
        print(error!.localizedDescription)
        complete(nil, error as NSError?)
      } else {
        // We have access to the user's record
        print("fetched ID \(recordID?.recordName ?? "")")
        complete(recordID, nil)
      }
    }
  }
  
  /// Get the users `RecordId`
  /// - parameters complete: A completion block passing two parameters
  open func getUserIdentity(complete: @escaping (String?, NSError?) -> ()) {
    
    container.requestApplicationPermission(.userDiscoverability) { (status, error) in
      self.container.fetchUserRecordID { (record, error) in
        
        if error != nil {
          print(error!.localizedDescription)
          complete(nil, error as NSError?)
          
        } else {
          //print("fetched ID \(record?.recordName ?? "")")
          self.container.discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
            let userName = (userID?.nameComponents?.givenName)! + " " + (userID?.nameComponents?.familyName)!
            print("CK User Name: " + userName)
            complete(userName,nil)
          })
        }
      }
    }
  }
  
  
  func addEntry(sitter: String, inputTime: NSDate, pickupOrDropoff: String, rate: Double) -> CKRecord?{
    let record = CKRecord(recordType: "Entry")
    record.setValue(sitter, forKey: "babySitterName")
    record["pickupOrDropoff"] = pickupOrDropoff as CKRecordValue
    record["rate"] = rate as CKRecordValue
    record["inputTime"] = Date() as CKRecordValue
    
    publicDB.save(record) { (record, error) in
      if let error = error {
        print("Error: \(error.localizedDescription)")
        return
      }
      print("Saved record: \(record.debugDescription)")
      print("RECORD ID: \(String(describing: record?.recordID))")
    }
    
    return record
    
  }
  
  
  
  
}
