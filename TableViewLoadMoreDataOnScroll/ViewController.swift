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
    var itemsPerRequest = 20
    
    //Where to fetch items from server or database
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
        
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maxOffset-currentOffset <= 10 {
            loadMore()
        }
    }
    
    func loadMore() {
        
        //If not reached end of items then coninue displaying data else return
        guard !reachedEndOfItems else {
            return
        }
        
        //System provided global dipatch background concurrent queue
        let backgroundQueue = DispatchQueue.global(qos: .background)
       
        let start = self.offset
        let end = start + self.itemsPerRequest
        
        //Run fetching new data operatoin on background queue
        backgroundQueue.async {
            
            //Fetch new data from server or database using start(offset) and end values (i.e start = 100, end = 100+50)
            let thisRequestItems = DataManager.getData(start: start, end: end)
            
            //After data is fetched update ui
            DispatchQueue.main.async {
                
                //Append the new items to the data source for the table view
                self.dataSourceArr.append(contentsOf: thisRequestItems)
                self.tableView?.reloadData()
                
                //If newly fetched data array has less items(0..<fetchLimit) that means we are at end of the list
                if thisRequestItems.count < self.itemsPerRequest {
                    self.reachedEndOfItems = true
                }
                self.offset += self.itemsPerRequest
            }
        }
    }
}

struct DataManager {
    
    private static var dataArray = [AnyObject]()
    
    static func getData(start: Int, end: Int) -> [AnyObject] {
        let newArr = Array(DataManager.dataArray[start..<end])
        guard  newArr.count > 0 else {
            return []
        }
        return newArr
    }
}

