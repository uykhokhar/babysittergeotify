//
//  EventsTableViewController.swift
//  Geotify
//
//  Created by MouseHouseApp on 5/30/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit
import CloudKit

class EventsTableViewController: UITableViewController {

  var entries = [CKRecord]()
  
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
      
      loadAllEntries()
      
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
        return entries.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventsTableViewCell else {
        fatalError("The dequeued cell is not an instance of EventCell.")
      }
      
      let entry = entries[indexPath.row]
      
      cell.babySitterNameTextField.text = (entry["babySitterName"] as! String)
      
      
      let inputTime = entry["inputTime"] as! NSDate
      let stringTime = inputTime.toString(dateFormat: "MM-dd HH:mm")
      cell.eventInputTimeTextField.text = (entry["pickupOrDropoff"] as! String) + " at " + (stringTime )
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
  
  private func loadAllEntries() {
    
    // ATTRIBUTION: https://stackoverflow.com/questions/40312105/core-data-predicate-filter-by-todays-date
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local
    
    // Get today's beginning & end
    let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
    components.day! += 1
    let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
    // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
    
    // Set predicate as date being today's date
    let predicate = NSPredicate(format: "(%@ <= inputTime) AND (inputTime < %@)", argumentArray: [dateFrom, dateTo])
    let query = CKQuery(recordType: "Entry", predicate: predicate)
    
    getEntriesWithOperation(query: query, cursor: nil)
    
  }
  
  
  func getEntriesWithOperation(query: CKQuery?, cursor: CKQueryCursor?) {
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
        self.entries.append(record)
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
        self.getEntriesWithOperation(query: nil, cursor: cursor)
        
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
