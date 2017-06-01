//
//  DaySummaryTableViewController.swift
//  Geotify
//
//  Created by MouseHouseApp on 5/30/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit
import CloudKit

class DaySummaryTableViewController: UITableViewController {

  var daySummaries = [CKRecord]()
  
  // MARK: - CloudKit
  let container: CKContainer = CKContainer.default()
  let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
  let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    loadAllDaySummaries()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return daySummaries.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DaySummaryCell", for: indexPath) as? DaySummaryTableViewCell else {
      fatalError("The dequeued cell is not an instance of DaySummaryCell.")
    }
    
    let daySummary = daySummaries[indexPath.row]
    
    cell.babySitterNameTextField.text = (daySummary["babySitterName"] as! String)
    
    let startTime = daySummary["startTime"] as! NSDate
    let stringStartTime = startTime.toString(dateFormat: "MM-dd HH:mm")
    let endTime = daySummary["endTime"] as! NSDate
    let stringEndTime = endTime.toString(dateFormat: "HH:mm")
    let totalTime = String(describing: daySummary["totalTime"]!)
    cell.startEndTextField.text = stringStartTime + "-" + stringEndTime + ", " + totalTime
    
    cell.rateTextField.text = "Rate: " + String(describing: daySummary["rate"]!)
    cell.costTextField.text = "Total Cost: $" + String(describing: daySummary["cost"]!)
    
    return cell
  }
  
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  
  //MARK: Private Methods
  
  private func loadAllDaySummaries() {
    
    let predicate = NSPredicate(format: "TRUEPREDICATE")
    
    let query = CKQuery(recordType: "Cost", predicate: predicate)
    
    getDaySummariesWithOperation(query: query, cursor: nil)
    
  }
  
  
  func getDaySummariesWithOperation(query: CKQuery?, cursor: CKQueryCursor?) {
    var queryOperation: CKQueryOperation!
    //var entries = [CKRecord]()
    
    if query != nil {
      queryOperation = CKQueryOperation(query: query!)
    } else if let cursor = cursor {
      print("== Cursor ======================================================")
      queryOperation = CKQueryOperation(cursor: cursor)
    }
    
    // Query parameters
    //queryOperation.desiredKeys = ["", "", ""]
    queryOperation.queuePriority = .veryHigh
    queryOperation.resultsLimit = 2
    queryOperation.qualityOfService = .userInteractive
    
    // This gets called each time per record
    queryOperation.recordFetchedBlock = {
      (record: CKRecord!) -> Void in
      if record != nil {
        self.daySummaries.append(record)
        print("operation: \(record["babySitterName"] as! String)")
      }
    }
    
    // This is called after all records are retrieved and iterated
    // on
    queryOperation.queryCompletionBlock = { cursor, error in
      if (error != nil) {
        print("Error:\(String(describing: error))")
        return
      }
      
      if let cursor = cursor {
        print("There is more data to fetch")
        self.getDaySummariesWithOperation(query: nil, cursor: cursor)
        
        print("Done with operation...")
        //OperationQueue.main.addOperation() {
        // Do anything else with the record after downloaded that
        // needs to be on the main thread
        //}
      }
      
      DispatchQueue.main.async(execute: { () -> Void in
        //self.entries += entries
        self.tableView.reloadData()
      })
      
    }
    self.publicDB.add(queryOperation)
    
    
  }

}
