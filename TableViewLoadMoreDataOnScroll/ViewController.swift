//
//  ViewController.swift
//  TableViewLoadMoreDataOnScroll
//
//  Created by Sharma, Piyush on 9/10/16.
//  Copyright © 2016 Sharma, Piyush. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //DataSource array to populate table rows data
    var dataSourceArr = [AnyObject]()
    
    //Items to be fetched everytime (items limit)
    var fetchLimit = 20
    
    //Starting offset to fetch new items
    var offset = 0
    
    //Track if database has no more items to display
    var reachedEndOfItems = false
    
    var tableView: UITableView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
         if indexPath.row == dataSourceArr.count-1 {
            loadMore()
         }
        */
        return UITableViewCell()
    }
}


extension ViewController: UITableViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let maxOffset = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        
        if maxOffset <= 10 {
            loadMore()
        }
    }
    
    func loadMore() {
        
        //If not reached end of items then coninue displaying data else return
        guard !reachedEndOfItems else {
            return
        }
    
        //Start holds updated offset after user scrolls to the end of tableview
        let start = self.offset
        
        //End holds (start + new set of data to be fetched)
        let end = start + self.fetchLimit
        
        //System provided global (dipatch) background concurrent queue
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        //Run fetching new data operation on background queue
        backgroundQueue.async {
            
            //Fetch new data from server or database using start(offset) and end values (i.e start = 100, end = 100+50)
            let newItems = DataManager.getNewData(start: start, end: end)
            
            //After data is fetched update ui on main thread
            DispatchQueue.main.async {
                
                //Append new items to the data source for the tableView
                self.dataSourceArr.append(contentsOf: newItems)
                self.tableView?.reloadData()
                
                //If newly fetched data array has less items(0..<fetchLimit(20)) that means we are at end of the list
                if newItems.count < self.fetchLimit {
                    self.reachedEndOfItems = true
                }
                
                //Reset the offset for next data array of new items
                self.offset += self.fetchLimit
            }
        }
    }
}

struct DataManager {
    
    private var dataArray = [AnyObject]()
    
    static func getNewData(start: Int, end: Int) -> [AnyObject] {
        let newArr = Array(DataManager.dataArray[start..<end])
        guard  newArr.count > 0 else {
            return []
        }
        return newArr
    }
    static func saveData(newItems: [AnyObject]) {
        dataArray = newItems
    }
}

