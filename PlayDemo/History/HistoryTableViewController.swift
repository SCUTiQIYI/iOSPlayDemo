//
//  HistoryTableViewController.swift
//  PlayDemo
//
//  Created by 李呱呱 on 2017/7/4.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController,UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.tableView.register(ZPChannelPageViewCell.classForCoder(), forCellReuseIdentifier: "historyCell");
        let insect = UIEdgeInsetsMake(20, 0, 0, 0);
        self.tableView.contentInset = insect;
        self.tableView.rowHeight = kCellMargin + kCellImageHeight + kCellMargin;
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .plain, target: self, action: #selector(back))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "清除", style: .plain, target: self, action: #selector(clean))
        
        self.navigationItem.title = "历史记录"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func back(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func clean(){
        HistoryManager.sharedInstance.removeAllHistory()
        self.tableView.reloadData()
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
        return HistoryManager.sharedInstance.getHistoryList().count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! ZPChannelPageViewCell
        let historyID = HistoryManager.sharedInstance.getHistoryList()[indexPath.row];
        if let history = HistoryManager.sharedInstance.getHistory(id: historyID){
            cell.videoInfo = history;
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoList = HistoryManager.sharedInstance.getHistoryList()
        let videoId = videoList[indexPath.row]
        if let videoInfo = HistoryManager.sharedInstance.getHistory(id: videoId){
            let playerVC = ZPPlayerViewController.init()
            playerVC.videoInfo = videoInfo
            playerVC.transitioningDelegate = self
            self.navigationController?.present(playerVC, animated: true, completion: nil)
        }
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PlayViewTransitionAnimator()
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = PlayViewTransitionAnimator()
        return animator
    }
    
/*
    
    - (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
    {
    PlayViewTransitionAnimator *animator = [[PlayViewTransitionAnimator alloc] init];
    
    return animator;
    }
    
*/

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

}
