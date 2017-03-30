//
//  ViewController.swift
//  Calendar
//
//  Created by panxiaohe on 2017/3/29.
//  Copyright © 2017年 panxiaohe. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ViewController: UICollectionViewController
{
//    @IBAction func tipper(_ sender: UIBarButtonItem) {
//         let tipAlert = UIAlertController(title: "提示", message: "长按，可禁用某一日期", preferredStyle: .alert)
//         let action5 = UIAlertAction(title:"取消",style:.cancel,handler:nil)
//        tipAlert.addAction(action5)
//        self.present(tipAlert, animated: true, completion: nil)
//    }
    
    var params:(key:String,title:String,natureQueryLanguage:[String])?
    
    @IBOutlet weak var modeSelector: UIBarButtonItem!
    
    @IBAction func selectedMode(_ sender: UIBarButtonItem) {
        let modeSelector = UIAlertController(title: "选择模式", message: "选择模式", preferredStyle: .actionSheet)
       
        let action1 = UIAlertAction(title:"单选",style:.default){ (action) in
            self.dataSourceManager.selectionType = .Single
            self.modeSelector.title = action.title
            self.collectionView?.reloadData()
        }

        let action2 = UIAlertAction(title:"多选",style:.default){ (action) in
            self.dataSourceManager.selectionType = .Mutable
            self.modeSelector.title = action.title
            self.collectionView?.reloadData()
        }

        let action3 = UIAlertAction(title:"节选",style:.default){ (action) in
            self.dataSourceManager.selectionType = .Section
            self.modeSelector.title = action.title
            self.collectionView?.reloadData()
        }

        let action4 = UIAlertAction(title:"不可选",style:.default){ (action) in
            self.dataSourceManager.selectionType = .None
            self.modeSelector.title = action.title
            self.collectionView?.reloadData()
        }

        let action5 = UIAlertAction(title:"取消",style:.cancel,handler:nil)
        
        modeSelector.addAction(action1)
        modeSelector.addAction(action2)
        modeSelector.addAction(action3)
        modeSelector.addAction(action4)
        modeSelector.addAction(action5)
        self.present(modeSelector, animated: true, completion: nil)
    }
    var value:DateInput?
    
    var tag:IndexPath?
    
    lazy var  dataSourceManager = CalenadrDataSource()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = true
//        let recognizar = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress))
//        recognizar.minimumPressDuration = 1.0;
//        recognizar.delaysTouchesBegan = true;
//        self.collectionView?.addGestureRecognizer(recognizar)
    }
    
//    func longPress(sender:UILongPressGestureRecognizer){
//        if(sender.state != .ended){
//            return
//        }
//        
//        let point = sender.location(in: self.collectionView)
//        let indexPath = self.collectionView?.indexPathForItem(at: point)
//        if (indexPath == nil){
//            NSLog("couldn't find index path");
//        } else {
//             NSLog("section = %d,row = %d",indexPath!.section,indexPath!.row);
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //    func initSelectionType(){
    //        switch selectionType {
    //        case .None:
    //            dataSourceManager.selectionType = .None
    //        case .Single:
    //            dataSourceManager.selectionType = .Single
    //        case .Mutable:
    //            dataSourceManager.selectionType = .Mutable
    //        case .Section:
    //            dataSourceManager.selectionType = .Section
    //        }
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSourceManager.monthCount
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataSourceManager.daysInMonth(section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
        
        let (date,dayState) = dataSourceManager.dayState(indexPath)
        
        if let button = cell.viewWithTag(1) as? RoundBackgroundLabel
        {
            button.backRoundColor = UIColor.lightGray
            
            button.isHidden = dayState.contains(.NotThisMonth)
            
            guard !button.isHidden else{
                return cell
            }
            
            button.text = dataSourceManager.StringDayFromDate(date)
            
            guard !dayState.contains(.UnSelectable) else{
                button.textColor = UIColor.lightGray
                button.roundType = .none
                return cell
            }
            
            button.roundType = dayState.roundType
            
            if dayState.contains(.Selected){
                if dayState.contains(.Today){
                    button.textColor = UIColor.red
                }else{
                    button.textColor = UIColor.white
                }
            }else{
                if dayState.contains(.Today){
                    button.textColor = UIColor.red
                }else{
                    button.textColor = UIColor.black
                }
            }
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionCell", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel
        {
            label.text = dataSourceManager.dateStringFromDate(dataSourceManager.monthState((indexPath as NSIndexPath).section))
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue,sender: sender)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */
    
    
    //Uncomment this method to specify if the specified item should be selected
    //    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        let (_,dayState) = dataSourceManager.dayState(indexPath)
    //        if dayState.contains(.NotThisMonth) || dayState.contains(.UnSelectable){
    //            return false
    //        }
    //        return true
    //    }
    //
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didCellClick(indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didCellClick(indexPath)
    }
    
    func didCellClick(_ indexPath: IndexPath){
        let (_,dayState) = dataSourceManager.dayState(indexPath)
        if dayState.contains(.NotThisMonth) || dayState.contains(.UnSelectable){
            return
        }
        if dataSourceManager.didSelectItemAtIndexPath(indexPath){
            self.collectionView?.reloadData()
        }
    }
   
    
}

struct DateInput{
    
    var startAt:Date?
    
    var endAt:Date?
    
    var exceptDates:[Date]?
    
    func toString() ->String?{
        let  dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        if let start = startAt{
            if let end  = endAt{
                if compareDate(start,date2: end){
                    return dateFormatter.string(from: start)
                }else{
                    return dateFormatter.string(from: start) + "至" + dateFormatter.string(from: end)
                }
            }else{
                return "开始于"+dateFormatter.string(from: start)
            }
        }else{
            if let end  = endAt{
                return "截止于"+dateFormatter.string(from: end)
            }else{
                return nil
            }
        }
    }
    
    func compareDate(_ date1:Date,date2:Date)->Bool{
        let timezoneFix = Double(NSTimeZone.local.secondsFromGMT())
        let dayTime = 24.0*3600.0
        return (Int((date1.timeIntervalSince1970 + timezoneFix) / dayTime) - Int((date2.timeIntervalSince1970 + timezoneFix) / dayTime))==0
    }
    
}
