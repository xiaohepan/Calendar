//
//  CalendarDataSource.swift
//  seasonview
//
//  Created by panxiaohe on 16/4/11.
//  Copyright © 2016年 panxiaohe. All rights reserved.
//

import Foundation

open class CalenadrDataSource
{
    
    fileprivate static let defaultFirstDate = Date(timeIntervalSince1970: -28800)
    fileprivate static let defaultLastDate = Date(timeIntervalSince1970:2145801599)
    
    /**
     *日历开始的日期
     */
    fileprivate var firstDate:Date!
    /**
     *日历结束的日期
     */
    fileprivate var lastDate:Date!
    /**
     *firstDate的当月开始的日期
     */
    fileprivate var firstDateMonthBegainDate:Date!
    /**
     *lastDate的当月结束的日期
     */
    fileprivate var lastDateMonthEndDate:Date!
    
    fileprivate var monthInfoCache:MonthInfoCache?
    
    fileprivate lazy var calendar:Calendar = {
        return Calendar.current
    }()
    /**
     *如果在firstDate和lastDate之间，则计算它的位置
     */
    fileprivate var todayIndex:IndexPath?
    /**
     *选中的位置
     */
    fileprivate var selectedIndexPaths = [IndexPath]()
    /**
     *设置日期编码
     */
    open var formatter:DateFormatter
    /**
     *选择模式切换
     */
    open var selectionType:SelectionType = .None{
        didSet{
            selectedIndexPaths.removeAll()
        }
    }
    
    /**
     *设置日历开始的日期
     */
    open var startDate:Date{
        set{
            if firstDate != nil && (newValue == firstDate){
                return
            }
            if lastDate != nil{
                let result = newValue.compare(lastDate)
                if result == .orderedDescending {
                    fatalError("startDate must smaller than endDate")
                }
            }
            
            firstDate =  clampDate(newValue, toComponents: [.year,.month,.day])
            firstDateMonthBegainDate =  clampDate(newValue, toComponents: [.month,.year])
            if lastDate != nil{
                let today = Date()
                let result1 = today.compare(newValue)
                let result2 = today.compare(lastDate)
                if result1 != .orderedAscending && result2 != .orderedDescending{
                    todayIndex = indexPathForRowAtDate(today)
                }else{
                    todayIndex = nil
                }
            }
        }
        get{
            return firstDate
        }
    }
    /**
     *设置日历结束的日期
     */
    open var endDate:Date{
        set{
            if lastDate != nil && (newValue == lastDate){
                return
            }
            if firstDate != nil{
                let result = firstDate.compare(newValue)
                if result == .orderedDescending {
                    fatalError("startDate must smaller than endDate")
                }
            }
            var components =  (self.calendar as NSCalendar).components([.year,.month,.day],from:newValue)
            components.hour = 23
            components.minute = 59
            components.second = 59
            lastDate = self.calendar.date(from: components)
            let firstOfMonth = self.clampDate(newValue, toComponents: [.month,.year])
            var offsetComponents = DateComponents()
            offsetComponents.month = 1
            let temp = (self.calendar as NSCalendar).date(byAdding: offsetComponents, to: firstOfMonth, options: .wrapComponents)!
            lastDateMonthEndDate = Date(timeIntervalSince1970: temp.timeIntervalSince1970 - 1)
            if firstDate != nil{
                let today = Date()
                let result1 = today.compare(firstDate)
                let result2 = today.compare(newValue)
                if result1 != .orderedAscending && result2 != .orderedDescending{
                    todayIndex = indexPathForRowAtDate(today)
//                    (todayIndex as NSIndexPath?)?.section
//                    (todayIndex as NSIndexPath?)?.row
                }else{
                    todayIndex = nil
                }
            }
        }
        get{
            return lastDate
        }
    }
    
    open var selectedDates:[Date]?{
        
        set{
            selectedIndexPaths.removeAll()
            if newValue != nil{
                for selectedDate in newValue!{
                    selectedIndexPaths.append(indexPathForRowAtDate(selectedDate))
                }
            }
        }
        
        get{
            var dates = [Date]()
            for selectedIndexPath in selectedIndexPaths{
                dates.append(dateOfIndexPath(selectedIndexPath))
            }
            return dates.count == 0 ? nil : dates
        }
    }
    
    
    
    open func dateOfIndexPath(_ indexPath:IndexPath) -> Date{
        let firstOfMonth =  self.firstOfMonthForSection((indexPath as NSIndexPath).section)
        //需要填补的天数
        let ordinalityOfFirstDay =  (self.calendar as NSCalendar).component(.weekday, from: firstOfMonth) - 1
        
        var offset = DateComponents()
        offset.day = (indexPath as NSIndexPath).row-ordinalityOfFirstDay
        
        let date = (self.calendar as NSCalendar).date(byAdding: offset, to: firstOfMonth, options: NSCalendar.Options(rawValue: 0))!
        return date
    }

    //使用默认的开始和结束时间
    public convenience init(){
        self.init(startDate:CalenadrDataSource.defaultFirstDate,endDate:CalenadrDataSource.defaultLastDate)
    }
    //使用自定义的开始和结束时间
    public init(startDate:Date,endDate:Date){
        let result = startDate.compare(endDate)
        if result == .orderedDescending {
            fatalError("startDate must smaller than endDate")
        }
        self.formatter = DateFormatter()
        self.startDate = startDate
        self.endDate = endDate
        formatter.dateFormat = "yyyy年MM月"
    }
    
    //多少年
    open func yearCount() -> Int
    {
        let startYear = (calendar as NSCalendar).components(.year,from: CalenadrDataSource.defaultFirstDate, to: firstDateMonthBegainDate,options: .wrapComponents).year
        
        let endYear = (calendar as NSCalendar).components(.year,from: CalenadrDataSource.defaultFirstDate, to: lastDateMonthEndDate,options: .wrapComponents).year
        
        return endYear! - startYear! + 1
    }
    
    
    
    //一星期多少天
    open func daysInWeek() -> Int{
        return (calendar as NSCalendar).maximumRange(of: .weekday).length
    }
    
    
    
    //多少月
    open var monthCount:Int{
        get{
            return (calendar as NSCalendar).components(.month, from: firstDateMonthBegainDate, to: lastDateMonthEndDate, options: .wrapComponents).month! + 1
        }
    }
    
    //一个月多少天
    open func daysInMonth(_ monthIndex:Int) -> Int{
        return weeksInMonth(monthIndex) * daysInWeek()
    }
    

    open func StringDayFromDate(_ date:Date) -> String{
        return String((self.calendar as NSCalendar).component(.day, from: date))
    }
    open func dateStringFromDate(_ date:Date) -> String{
        return formatter.string(from: date)
    }
    
   
    
    //一个月多少星期
    open func weeksInMonth(_ monthIndex:Int) -> Int{
        let firstOfMonth = self.firstOfMonthForSection(monthIndex)
        let rangeOfWeeks = (self.calendar as NSCalendar).range(of: .weekOfMonth,in: .month,for: firstOfMonth).length
        return rangeOfWeeks
    }
    
    
    
    fileprivate func clampDate(_ date:Date, toComponents unitFlags:NSCalendar.Unit) -> Date{
        let components = (self.calendar as NSCalendar).components(unitFlags,from:date)
        return self.calendar.date(from: components)!
    }
    //一个月开始的时间
    fileprivate func firstOfMonthForSection(_ monthIndex:Int) -> Date
    {
        var offset = DateComponents()
        offset.month = monthIndex
        return (self.calendar as NSCalendar).date(byAdding: offset, to: firstDateMonthBegainDate, options: NSCalendar.Options(rawValue: 0))!
    }
    
    
    open func monthState(_ monthIndex:Int) -> Date
    {
        var offset = DateComponents()
        offset.month = monthIndex
        return (self.calendar as NSCalendar).date(byAdding: offset, to: firstDateMonthBegainDate, options: NSCalendar.Options(rawValue: 0))!
    }
    
    
    func sectionForDate(_ date:Date) -> Int
    {
        return (self.calendar as NSCalendar).components(.month,from:self.firstDateMonthBegainDate,to:date,options:.wrapComponents).month!
    }
    
    func indexPathForRowAtDate(_ date:Date) -> IndexPath
    {
        let section = self.sectionForDate(date)
        let firstOfMonth = self.firstOfMonthForSection(section)
        
        let ordinalityOfFirstDay =  1 - (self.calendar as NSCalendar).component(.weekday, from: firstOfMonth)
        
        var  dateComponents = DateComponents()
        dateComponents.day = ordinalityOfFirstDay
        let startDateInSection = (self.calendar as NSCalendar).date(byAdding: dateComponents, to: firstOfMonth, options: NSCalendar.Options(rawValue: 0))!
        
        let row = (self.calendar as NSCalendar).components(.day, from: startDateInSection, to: date, options: NSCalendar.Options(rawValue: 0)).day
        return IndexPath(row:row!,section:section)
    }
    
    func didSelectItemAtIndexPath(_ indexPath:IndexPath) -> Bool{
        switch selectionType {
        case .None:
            return false
        case .Single:
            if selectedIndexPaths.count == 0{
                selectedIndexPaths.append(indexPath)
            }else if selectedIndexPaths[0] != indexPath{
                selectedIndexPaths[0] = indexPath
            }else{
               selectedIndexPaths.removeAll()
            }
        case .Mutable:
            if let index = selectedIndexPaths.index(of: indexPath){
                selectedIndexPaths.remove(at: index)
            }else{
                selectedIndexPaths.append(indexPath)
            }
        case .Section:
            if selectedIndexPaths.count == 0{
                selectedIndexPaths.append(indexPath)
            }else if selectedIndexPaths.count == 1{
                if selectedIndexPaths[0] == indexPath{
                    selectedIndexPaths.removeAll()
                }else{
                    let result = (selectedIndexPaths[0] as NSIndexPath).compare(indexPath)
                    switch result {
                    case .orderedSame:
                        return false
                    case .orderedAscending:
                        selectedIndexPaths.append(indexPath)
                    case .orderedDescending:
                        selectedIndexPaths.insert(indexPath, at: 0)
                    }
                }
            }else{
//                if let index = selectedDates.indexOf(indexPath){
//                    selectedDates.removeAtIndex(index)
//                }else{
                    selectedIndexPaths.removeAll()
                    selectedIndexPaths.append(indexPath)
//                }
            }
            NSLog("------------------------------------")
            for date in selectedIndexPaths{
                NSLog("selectedDates = \(date)")
            }

        }
        monthInfoCache = nil
        return true
    }
    
    fileprivate func getMonthInfo(_ section:Int) -> MonthInfoCache{
        if  monthInfoCache?.section != section{
            //每月1号那天
            let firstOfMonth =  self.firstOfMonthForSection(section)
            
            //需要填补的天数
            let ordinalityOfFirstDay =  (self.calendar as NSCalendar).component(.weekday, from: firstOfMonth) - 1
            
            var offset = DateComponents()
            offset.day = -ordinalityOfFirstDay
            
            let placeHolderFirstOfMonth = (self.calendar as NSCalendar).date(byAdding: offset, to: firstOfMonth, options: NSCalendar.Options(rawValue: 0))!
            
            //这个月天数
            let ordinalityOfLastDay =  (calendar as NSCalendar).range(of: .day, in: .month, for: firstOfMonth).length
            
            var todayIndexInMonth = -1
            
            if section == (todayIndex as NSIndexPath?)?.section{
                todayIndexInMonth = (todayIndex! as NSIndexPath).row
            }
            monthInfoCache = MonthInfoCache(calendar: self.calendar,section: section, monthStartDate: placeHolderFirstOfMonth, thisMonthDayStart: ordinalityOfFirstDay, thisMonthDayEnd: ordinalityOfFirstDay + ordinalityOfLastDay - 1, todayIndex: todayIndexInMonth)
            
            setSelectedInfo(section)
            if section == 0
            {
                let unselectedEnd = (self.calendar as NSCalendar).components(.day, from: placeHolderFirstOfMonth, to: firstDate, options: NSCalendar.Options(rawValue: 0)).day! - 1
                
                let unselectedStart = ordinalityOfFirstDay
                monthInfoCache!.unselectedableStartIndex = unselectedStart
                monthInfoCache!.unselectedableEndIndex = unselectedEnd
            }
            
            if section == monthCount - 1
            {
                 let unselectedStart = (self.calendar as NSCalendar).components(.day, from: placeHolderFirstOfMonth, to: lastDate, options: NSCalendar.Options(rawValue: 0)).day! + 1
                
                 let unselectedEnd = ordinalityOfFirstDay + ordinalityOfLastDay - 1
                 monthInfoCache!.unselectedableStartIndex = unselectedStart
                 monthInfoCache!.unselectedableEndIndex = unselectedEnd
            }
        }
        return monthInfoCache!
    }
    
    func setSelectedInfo(_ section:Int){
        let daysInmonth:Int = self.daysInMonth(section)
        var startIndex  = -1
        var endIndex = -1
        let count = selectedIndexPaths.count
        switch count{
        case 0:
            break
        case 2:
            if selectionType == .Section{
                if (selectedIndexPaths[0] as NSIndexPath).section < section{
                    if section < (selectedIndexPaths[1] as NSIndexPath).section{
                        startIndex = 0
                        endIndex = daysInmonth - 1
                    }else if section == (selectedIndexPaths[1] as NSIndexPath).section{
                        startIndex = 0
                        endIndex = (selectedIndexPaths[1] as NSIndexPath).row
                    }
                    
                    
                } else if (selectedIndexPaths[0] as NSIndexPath).section == section{
                    if section < (selectedIndexPaths[1] as NSIndexPath).section{
                        startIndex = (selectedIndexPaths[0] as NSIndexPath).row
                        endIndex = daysInmonth - 1
                    }else if section == (selectedIndexPaths[1] as NSIndexPath).section{
                        startIndex = (selectedIndexPaths[0] as NSIndexPath).row
                        endIndex = (selectedIndexPaths[1] as NSIndexPath).row
                    }
                }
                
                monthInfoCache?.selectedStartIndex = startIndex
                monthInfoCache?.selectedendIndex = endIndex
    
            }else{
                fallthrough
            }
        default:
            for indexPath in selectedIndexPaths
            {
                if (indexPath as NSIndexPath).section  == section{
                    monthInfoCache?.selectedIndex.insert((indexPath as NSIndexPath).row)
                }
            }
        }
    }
    
    //每天的信息
    open func dayState(_ indexPath:IndexPath) -> (Date,DayStateOptions){
        let monthInfo =  getMonthInfo((indexPath as NSIndexPath).section)
        return monthInfo.getDayInfo((indexPath as NSIndexPath).row,selectedType: self.selectionType)
        
    }
}

private class MonthInfoCache
{
    let section:Int
    var monthStartDate:Date
    var thisMonthDayStart:Int
    var thisMonthDayEnd:Int
    var todayIndex:Int
    
    var selectedIndex = Set<Int>()
    var selectedStartIndex = -1
    var selectedendIndex = -1
    
    var unSelectableIndex:Set<Int>?
    var unselectedableStartIndex = -1
    var unselectedableEndIndex = -1
    var calendar:Calendar?
    var dateComponents = DateComponents()
    
    init(calendar:Calendar?,section:Int,monthStartDate:Date,thisMonthDayStart:Int,thisMonthDayEnd:Int,todayIndex:Int){
        self.calendar = calendar
        self.section = section
        self.monthStartDate = monthStartDate
        self.thisMonthDayStart = thisMonthDayStart
        self.thisMonthDayEnd = thisMonthDayEnd
        self.todayIndex = todayIndex
    }
    
    convenience init(section:Int){
        self.init(calendar:nil,section:-1,monthStartDate:Date(),thisMonthDayStart:-1,thisMonthDayEnd:-1,todayIndex:-1)
    }
    
    func getDayInfo(_ index:Int,selectedType:SelectionType) -> (Date,DayStateOptions){
        dateComponents.day = index
        let date = (self.calendar! as NSCalendar).date(byAdding: dateComponents, to: monthStartDate, options: NSCalendar.Options(rawValue: 0))!
        var options =  DayStateOptions(rawValue:0)
        
        if index == todayIndex {
            options = [options,.Today]
        }
        
        if index < thisMonthDayStart || index > thisMonthDayEnd{
            options = [options,.NotThisMonth]
        }
        
        if index >= unselectedableStartIndex && index <= unselectedableEndIndex{
            options = [options,.UnSelectable]
        }else{
            if selectedType != .Section{
                if selectedIndex.contains(index){
                    options = [options,.Selected,.SelectedLeftNone,.SelectedRightNone]
                }
            }else{
                let weekday = (self.calendar as NSCalendar?)?.component(.weekday, from: date)
                if selectedStartIndex != -1{
                    if selectedStartIndex <= index && index <= selectedendIndex{
                        options = [options,.Selected]
                        if weekday == 1||selectedStartIndex == index || index == thisMonthDayStart{
                            options = [options,.SelectedLeftNone]
                        }
                        if weekday == 7 || index == selectedendIndex ||  index == thisMonthDayEnd{
                            options = [options,.SelectedRightNone]
                        }
                    }
                }else{
                    if selectedIndex.contains(index){
                        options = [options,.Selected,.SelectedLeftNone,.SelectedRightNone]
                    }

                }
            }
        }
        return (date,options)
    }
}


public struct DateInterval {
    var startDate:Date
    var endDate:Date
    init(startDate:Date,endDate:Date){
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct RowInterval{
    var startRow:Int
    var endRow:Int
    init(startRow:Int,endRow:Int){
        self.startRow = startRow
        self.endRow = endRow
    }
}


//class IndexPathBrain {
//    
//    private var startIndex:NSIndexPath?
//    
//    private var endIndex:NSIndexPath?
//    
//    private var selectIndex:[NSIndexPath]?
//    
//    var selectType:SelectionType = .None{
//        didSet{
//            startIndex = nil
//            endIndex = nil
//            selectIndex = nil
//        }
//    }
//    
//    private func addIndexPath(indexPath:NSIndexPath){
//        if selectIndex == nil{
//            selectIndex = [NSIndexPath]()
//        }
//        selectIndex?.append(indexPath)
//    }
//    
//    func didSelectedIndex(indexPath:NSIndexPath){
//        switch selectType {
//        case .Single:
//            startIndex = indexPath
//            endIndex = indexPath
//        case .Section:
//            if startIndex == nil{
//                startIndex = indexPath
//            }else if(endIndex == nil){
//                switch indexPath.compare(startIndex!){
//                case .OrderedAscending:
//                    endIndex = startIndex
//                    startIndex = indexPath
//                case .OrderedDescending:
//                    endIndex = indexPath
//                case .OrderedSame:
//                    break
//                }
//            }else{
//                endIndex = indexPath
//            }
//        
//        case .Mutable:
//            if startIndex == nil{
//                startIndex = indexPath
//            }else if(endIndex == nil){
//                switch indexPath.compare(startIndex!){
//                case .OrderedAscending:
//                    endIndex = startIndex
//                    startIndex = indexPath
//                case .OrderedDescending:
//                    endIndex = indexPath
//                case .OrderedSame:
//                    break
//                }
//            }else{
//                let result1 = indexPath.compare(startIndex!)
//                let result2 = indexPath.compare(endIndex!)
//                
//                if result1 == .OrderedSame || result2 == .OrderedSame{
//                    return
//                }
//                
//                if result1 == .OrderedAscending{
//                    addIndexPath(startIndex!)
//                    startIndex = indexPath
//                }else if result2 == .OrderedDescending{
//                    addIndexPath(endIndex!)
//                    endIndex = indexPath
//                }else{
//                }
//                
//            }
//        
//        
//        case .None:
//            break
//        }
//    }
//}


public struct DayStateOptions:OptionSet{
    
    public var rawValue:UInt
    
    public init(rawValue: UInt){
        self.rawValue = rawValue
    }
    //不在本月
    public static var NotThisMonth:DayStateOptions{
        return DayStateOptions(rawValue: 1<<0)
    }
    //是今天
    public static var Today:DayStateOptions{
        return DayStateOptions(rawValue: 1<<1)
    }
    //不可选择
    public static var UnSelectable:DayStateOptions{
        return DayStateOptions(rawValue: 1<<2)
    }
    //被选中
    public static var Selected:DayStateOptions{
        return DayStateOptions(rawValue: 1<<3)
    }
    //左边没选择
    public static var SelectedLeftNone:DayStateOptions{
        return DayStateOptions(rawValue: 1<<4)
    }
    //右边没选择
    public static var SelectedRightNone:DayStateOptions{
        return DayStateOptions(rawValue: 1<<5)
    }
    var roundType:RoundType{
        get{
            if self.contains(.Selected){
                if self.contains(.SelectedRightNone){
                    if self.contains(.SelectedLeftNone){
                        return .single
                    }else{
                        return .end
                    }
                }else {
                    if self.contains(.SelectedLeftNone){
                        return .start
                    }else{
                        return .middle
                    }
                }
            }else{
                return .none
            }
        }
    }
}





public enum SelectionType:String{
    case None,Single,Mutable,Section
}
