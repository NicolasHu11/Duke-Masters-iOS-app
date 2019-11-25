//
//  CalendarDisp.swift
//  Duke Masters Program
//
//  Created by 周笑晨 on 11/13/19.
//  Copyright © 2019 Duke University. All rights reserved.
//

import UIKit
import MSGraphMSALAuthProvider
import MSGraphClientSDK
import MSGraphClientModels

// General settings
class CalendarDisp: UIViewController {
//class CalendarDisp: UITableViewController {
    @IBOutlet weak var dispMonth: UILabel!
    @IBOutlet weak var dispYear: UILabel!
    @IBOutlet weak var dispCollectionView: UICollectionView!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    // initialization flag
    var loadedFlag = false
    
    // date related properties
    var today = Date()              //today's date
    var todayInfo = [2019,12,31]    //today's info
    var currentMonth = 12           //current page's month
    var currentYear = 2019          //current page's year
    var currentDay = 31              //selected date
    
    // calendar layout related properties
    // for calendar layout
    var startWeekDay = 0            //start weekday of current month
    var calenCellNum = 35           //cell number needed for current month
    var todayCell = 0               //the cell NO of today
    // for calendar data
    var calendarID = [String:Any]() //directory of calendars
    var calendarName = [String]()   //array of calendars' name
    // for sakai assignments
    var sakaiDict = [String:[(title: String, siteId: String, due: String, instructions: String)]]()
    var sortedEvent : [(calendar: String, index: Int)] = []
    
    // event related properties
    var selectedDate = ""           //selected date, in String's format
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In viewDidLoad")
        // MARK: 在作死的边缘疯狂试探还他妈转了个圈
        // Initialize MSAL and graph
            do{
                    try outlookCommunication.instance.initMSAL(parentViewController: self)
                } catch let error{
                    print("Unable to create Application context \(error)")
                    print("initMSAL error")
                }
                print("In viewDidLoad: initializaing graph")
                outlookCommunication.instance.graphInit()
                // 加个calendar试试？好了不要加了加个鬼哦加
                //outlookCommunication.instance.createCalendar(name: "Sakai Assignments")
                calendarID = outlookCommunication.instance.getUserCalendars()
                sleep(1)
            //        while(outlookCommunication.instance.calendarRequestCompleted == true){
            //            sleep(1)
            //        }
                    //print("outside the while loop")
                if(outlookCommunication.instance.calendarRequestCompleted == true){
                    print("Got calendar data!")
                    outlookCommunication.instance.calendarRequestCompleted = false
                    calendarID = outlookCommunication.instance.calendarDict
                    print(calendarID.count)
                    for name in calendarID.keys{
                        calendarName.append(name)
                    }
                }else{
                    sleep(10)
                    calendarID = outlookCommunication.instance.calendarDict
                    print(calendarID.count)
                }
        
        // MARK: 作死完了走走正常流程
        self.InitDate()
        self.configCalendarLayout()
        self.configCalendarBackground(colorSet: calendarBack)
        self.dispCollectionView.delegate = self
        self.dispCollectionView.dataSource = self
        self.eventCollectionView.delegate = self
        self.eventCollectionView.dataSource = self
        // initialize the layout of collection view
        self.initCollection()
        self.addWeekdayLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("In viewDidAppear")
        guard let currentAccount = outlookCommunication.instance.currentAccount() else {
            // check to see whether there's a current logged in account.
            // If none, acquire token interactively.
            outlookCommunication.instance.acquireTokenInteractively()
            outlookCommunication.instance.graphInit()
            //outlookCommunication.instance.graphEvent()
            return
        }
        outlookCommunication.instance.acquireTokenSilently(currentAccount)
        outlookCommunication.instance.graphInit()
        
    }
    
    @IBAction func formerDate(_ sender: Any) {
        self.dereaseDate()
        let (start, end) = startEndLiteral(year: self.currentYear, month: currentMonth)
        if outlookCommunication.instance.loadedMonth.contains(String(start.prefix(7))) == false{
            outlookCommunication.instance.getEvents(inCalendar: "Calendar", startFrom: start, to: end)
            outlookCommunication.instance.getEvents(inCalendar: "Sakai Assignments", startFrom: start, to: end)
        }
        self.configCalendarLayout()
        self.dispCollectionView.reloadData()
        self.selectedDate = ""
        self.sortEventData()
        self.eventCollectionView.reloadData()
    }
    @IBAction func laterDate(_ sender: Any) {
        self.increaseDate()
        let (start, end) = startEndLiteral(year: self.currentYear, month: currentMonth)
        if outlookCommunication.instance.loadedMonth.contains(String(start.prefix(7))) == false{
            outlookCommunication.instance.getEvents(inCalendar: "Calendar", startFrom: start, to: end)
            outlookCommunication.instance.getEvents(inCalendar: "Sakai Assignments", startFrom: start, to: end)
        }
        self.configCalendarLayout()
        self.dispCollectionView.reloadData()
        self.selectedDate = ""
        self.sortEventData()
        self.eventCollectionView.reloadData()
    }
}

// PART1: date pick, display and related functions
extension CalendarDisp{
    // When first loaded, display current month by default
    // By calling this, initialize current year and current month
    // !!!!! current day seems to be verbose????
    func InitDate(){
        //  In initialization of date!
        self.today = Date().addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let temp = NSString(string: dateformatter.string(from: self.today))
        let tempArray = temp.components(separatedBy: "-")
        self.todayInfo[0] = Int(tempArray[0]) ?? 2019
        self.currentYear = self.todayInfo[0]
        self.todayInfo[1] = Int(tempArray[1]) ?? 12
        self.currentMonth = self.todayInfo[1]
        self.todayInfo[2] = Int(tempArray[2]) ?? 31
        self.currentDay = self.todayInfo[2]
        self.dispYear.text = "\(self.currentYear)"
        self.dispMonth.text = monthLiteral[self.currentMonth]
        self.startWeekDay = configWeekDay(year: self.currentYear, month: self.currentMonth, day: 1)
        self.selectedDate = String(temp)
        // Get data in current month
        let (start, end) = startEndLiteral(year: self.currentYear, month: currentMonth)
        if outlookCommunication.instance.loadedMonth.contains(String(start.prefix(7))) == false{
            outlookCommunication.instance.getEvents(inCalendar: "Calendar", startFrom: start, to: end)
            outlookCommunication.instance.getEvents(inCalendar: "Sakai Assignments", startFrom: start, to: end)
            sleep(2)
        }
//        outlookCommunication.instance.getEvents(inCalendar: "Calendar", startFrom: start, to: end)
//        outlookCommunication.instance.getEvents(inCalendar: "Sakai Assignments", startFrom: start, to: end)
        self.sakaiPrep()
        // Just wait a minute...
        //sleep(2)
        self.sortEventData()
    }
    // Increase by one month
    func increaseDate(){
        self.currentMonth += 1
        if self.currentMonth == 13{
            self.currentMonth = 1
            self.currentYear += 1
        }
        self.dispYear.text = "\(self.currentYear)"
        self.dispMonth.text = monthLiteral[self.currentMonth]
    }
    // Decrease by one month
    func dereaseDate(){
        self.currentMonth -= 1
        if self.currentMonth == 0{
            self.currentMonth = 12
            self.currentYear -= 1
        }
        self.dispYear.text = "\(self.currentYear)"
        self.dispMonth.text = monthLiteral[self.currentMonth]
    }
    
    // Given current year and current month, configure the layout of calendar
    func configCalendarLayout(){
        // Weekday for current month's first day
        self.startWeekDay = configWeekDay(year: self.currentYear, month: self.currentMonth, day: 1)
        // How many cells are needed for current month
        let startCellNO = self.startWeekDay
        let endCellNO = startCellNO + monthDays(year: self.currentYear, month: self.currentMonth) - 1
        self.calenCellNum = (endCellNO > 34) ? 42 : 35
        print("in configCalendarLayout!")
        print("\(self.currentYear) \(self.currentMonth) :")
        print("there are \(monthDays(year: self.currentYear, month: self.currentMonth)) days in this month")
        print("\(self.calenCellNum) cells are needed!" )
        
        // Save the information of todayCell, for exactly today only
        if(self.currentYear == self.todayInfo[0] && self.currentMonth == self.todayInfo[1]){
            self.todayCell = startCellNO + self.currentDay - 1
            print("Today cell index: \(self.todayCell)")
        }
    }
    
    // Set the background of calendar
    func configCalendarBackground(colorSet: [UIColor]){
        //set the gradient layer
        let background = CAGradientLayer()
        background.bounds = self.view.bounds
        background.frame = self.view.bounds
        background.colors = []
        for color in colorSet{
            let temp = color.cgColor
            background.colors?.append(temp)
        }
        background.locations = [0.0, 1.0]
        background.startPoint = CGPoint(x: 0, y: 0)
        background.endPoint = CGPoint(x: 1, y: 1)
        //insert the gradient layer to the backgroundView
        self.view.layer.insertSublayer(background, at: 0)
    }
    
    // Organize sakai data
    func sakaiPrep(){
        //for debugging
        print("---------------- In SAKAI PREP! -------------------")
        
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        var start: String
//        let eventStartDate = dateFormatter.date(from: String(self.sakaiDict[selectedDate]![i].due.prefix(19)))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        print("ℹ️ debug: all assignments done")
//        print(assignments)
        for index in 0..<assignments.count{
            print(assignments[index].title)
            print(assignments[index].due)
            print(assignments[index].siteId)
            //Modify the time string
            var tempDate = dateFormatter.date(from: String(assignments[index].due.prefix(19)))
            tempDate = tempDate?.addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
            assignments[index].due = dateFormatter.string(from: tempDate!)
            print(assignments[index].due)
            let date = String(assignments[index].due.prefix(10))
            if self.sakaiDict.keys.contains(date){
                self.sakaiDict[date]?.insert(assignments[index], at: 0)
            }
            else{
                self.sakaiDict[date] = [assignments[index]]
            }
        }
        
        
        
        
    }
}

// PART2: collectionView related
extension CalendarDisp: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func initCollection(){
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        // allow selection
        self.dispCollectionView.allowsSelection = true
        self.dispCollectionView.backgroundColor = .clear
        // ---------- FOR EVENT COLLECTION VIEW ----------
        // disallow selection
        self.eventCollectionView.allowsSelection = false
        // set the scroll direction to be horizontal
        let layout = self.eventCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        // set shadow for eventCollectionView
        eventCollectionView.layer.shadowOffset = CGSize(width: 0,height: 0)
        eventCollectionView.layer.shadowOpacity = 0.75
        eventCollectionView.layer.shadowRadius = 4.0
        eventCollectionView.layer.masksToBounds = false
        self.eventCollectionView.backgroundColor = .clear
    }
    
    // set gradient background for selected UICollectionView
    func gradientBackground(_ collectionView: UICollectionView, colorSet: [UIColor]){
        // set the backgroundView (subclassed from UIView)
        let backgroundView = UIView(frame: collectionView.bounds)
        //set the gradient layer
        let background = CAGradientLayer()
        background.bounds = backgroundView.bounds
        background.frame = collectionView.bounds
        background.colors = []
        for color in colorSet{
            let temp = color.cgColor
            background.colors?.append(temp)
        }
        background.locations = [0.0, 1.0]
        background.startPoint = CGPoint(x: 0, y: 0)
        background.endPoint = CGPoint(x: 1, y: 1)
        //add the gradient layer to the backgroundView
        backgroundView.layer.addSublayer(background)
        //set backgroundView (which is nil by default)
        collectionView.backgroundView = backgroundView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        if collectionView.tag == 0{
            let calenCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionCell", for: indexPath) as! CalendarCollectionViewCell
            let start = self.startWeekDay
            let end = start + monthDays(year: self.currentYear, month: self.currentMonth) - 1
            let ItemNO = indexPath.row
            if ItemNO < start{
                let tempMonth = (self.currentMonth - 1) > 0 ? (self.currentMonth - 1) : 12
                let tempYear = (tempMonth == 0) ? self.currentYear-1 : self.currentYear
                let dateNO = monthDays(year: tempYear, month: tempMonth) - (start-ItemNO) + 1
                calenCollectionCell.setDate(date: "\(dateNO)", isCurrent: false)
            }
            else if (ItemNO > end){
                calenCollectionCell.setDate(date: "\(ItemNO - end)", isCurrent: false)
            }
            else{
                calenCollectionCell.setDate(date: "\(ItemNO - start + 1)", isCurrent: true)
            }
            let totalWidth = self.dispCollectionView.bounds.width
            let totalHeight = self.dispCollectionView.bounds.height
            // set size of each item
            let itemWidth = totalWidth/7.0 - 0.02
            let itemHeight = ((self.calenCellNum == 35) ? totalHeight/5.0 : totalHeight/6.0) - 0.02
            calenCollectionCell.setShape(width: itemWidth, height: itemHeight)
            // If is today
            if self.currentYear == self.todayInfo[0] && self.currentMonth == self.todayInfo[1] && indexPath.row == self.todayCell{
                calenCollectionCell.backgroundColor = calendarCellSelected
            }
            return calenCollectionCell
        }
        // ---------- FOR EVENT COLLECTION VIEW ----------
        else{
            print("In Creating Events")
            //print(self.sakaiDict[self.selectedDate])
            let eveCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
            let indicator = self.sortedEvent[indexPath.row]
            if indicator.calendar == "Calendar"{
                let index = indicator.index
                let temp = outlookCommunication.instance.eventDict[selectedDate]![index]
                // set text
                eveCollectionViewCell.configCell(from: temp.start?.dateTime ?? "", to: temp.end?.dateTime ?? "", subject: temp.subject ?? "",body: temp.body?.content ?? "", location:"")// temp.location?.description ?? "")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC+00:00")
                let eventStartDate = dateFormatter.date(from: String(temp.start!.dateTime.prefix(19)))
                let eventEndDate = dateFormatter.date(from: String(temp.end!.dateTime.prefix(19)))
                let currentDate = Date().addingTimeInterval(TimeInterval(NSTimeZone.system.secondsFromGMT()))
                print("start: \(String(describing: eventStartDate))")
                print("end: \(String(describing: eventEndDate))")
                print("current: \(String(describing: currentDate)))")
                if currentDate.timeIntervalSince(eventStartDate!) < 0{
                    print("current比start早, 还没开始")
                    eveCollectionViewCell.setTextColor(upcomingTextColor)
                }
                else{
                    print("current比start晚, 不确定")
                    if currentDate.timeIntervalSince(eventEndDate!) < 0{
                        print("current比end早，还没结束 ")
                        eveCollectionViewCell.setTextColor(redDarker[0])
                    }else{
                        print("current比end晚，过去了")
                        eveCollectionViewCell.setTextColor(passedTextColor)
                    }
                }
            }
            else{
                let index = indicator.index
                let temp = self.sakaiDict[self.selectedDate]?[index]
                eveCollectionViewCell.setTextColor(upcomingTextColor)
                eveCollectionViewCell.startTime.text = "DUE"
                eveCollectionViewCell.startTime.textColor = assignmentTextColor
                eveCollectionViewCell.endTime.text = extractTime(dateTime: temp!.due)
                eveCollectionViewCell.body.text =  temp?.title
                eveCollectionViewCell.location.text = ""
                eveCollectionViewCell.subject.text = ""
            }
            //eveCollectionViewCell.setTextColor(upcomingTextColor)
            // set size
            let totalWidth = self.eventCollectionView.bounds.width
            let totalHeight = self.eventCollectionView.bounds.height
            let itemWidth = totalWidth/3.0 - 5
            eveCollectionViewCell.setShape(width: itemWidth, height: totalHeight - 5)
            eveCollectionViewCell.backgroundColor = brighterBlue[indexPath.row]
            return eveCollectionViewCell
        }
        
    }
    // MARK: Layout related
    // Specify how many cells will be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        if collectionView.tag == 0{
            return self.calenCellNum
        }
        // ---------- FOR EVENT COLLECTION VIEW ----------
        else{
            //return outlookCommunication.instance.eventDict[selectedDate]?.count ?? 0
            return self.sortedEvent.count
        }
    }
    
    // Set the size of each item (UICollectionViewDelegateFlowLayout)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        if collectionView.tag == 0{
            let totalWidth = self.dispCollectionView.bounds.width
            let totalHeight = self.dispCollectionView.bounds.height
            // set size of each item
            let itemWidth = totalWidth/7.0 - 0.02
            let itemHeight = ((self.calenCellNum == 35) ? totalHeight/5.0 : totalHeight/6.0) - 0.02
            return CGSize(width: itemWidth, height: itemHeight)
        }
        // ---------- FOR EVENT COLLECTION VIEW ----------
        else{
            let totalWidth = self.eventCollectionView.bounds.width
            let totalHeight = self.eventCollectionView.bounds.height
            // set size of each item
            let itemWidth = totalWidth/3.0 - 5
            //let itemHeight = totalHeight
            return CGSize(width: itemWidth, height: totalHeight - 5)
        }
        
    }
    // Set the minimum space between items in same section (horizontal)
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        if collectionView.tag == 0{
            return CGFloat(0.01)
        }
        // ---------- FOR EVENT COLLECTION VIEW ----------
        else{
            return CGFloat(5.00)
        }
    }
    // Set the minimum space between items in same section(vertical)
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        // ---------- FOR CALENDAR COLLECTION VIEW ----------
        if collectionView.tag == 0{
            return CGFloat(0.01)
        }
        // ---------- FOR EVENT COLLECTION VIEW ----------
        else{
            return CGFloat(5)
        }
    }
    // How many sections for a collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: Interaction Related
    // Determine which cells can be selected in current month
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool{
        // ---------- FOR CALENDAR COLLECTION VIEW ONLY----------
        if collectionView.tag == 0{
            if indexPath.row >= self.startWeekDay && indexPath.row <= self.startWeekDay + monthDays(year: self.currentYear, month: self.currentMonth) - 1{
                return true
            }
            return false
        }
        return false
    }
    // When a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // ---------- FOR CALENDAR COLLECTION VIEW ONLY----------
        if collectionView.tag == 0{
            // Calculate the date selected
            var selectedDate = "\(self.currentYear)"
            let selectedDay = indexPath.row - self.startWeekDay + 1
            selectedDate = selectedDate + ((self.currentMonth < 10) ? "-0\(self.currentMonth)" : "-\(self.currentMonth)")
            selectedDate = selectedDate + ((selectedDay < 10) ? "-0\(selectedDay)" : "-\(selectedDay)")
            print(selectedDate)
            self.selectedDate = selectedDate
            self.sortEventData()
            self.eventCollectionView.reloadData()
            if self.currentYear == self.todayInfo[0] && self.currentMonth == self.todayInfo[1]{
                let temp = IndexPath(row: self.todayCell, section: 0)
                self.dispCollectionView.cellForItem(at: temp)?.backgroundColor = calendarCellToday
            }
            self.dispCollectionView.cellForItem(at: indexPath)?.backgroundColor = calendarCellSelected
        }
    }
    // When a cell is de-selected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // just for testing now
        print(indexPath.row)
        // ---------- FOR CALENDAR COLLECTION VIEW ONLY----------
        if collectionView.tag == 0{
            self.dispCollectionView.cellForItem(at: indexPath)?.backgroundColor = calendarCellColor
            // If today's cell
            if self.currentYear == self.todayInfo[0] && self.currentMonth == self.todayInfo[1] && indexPath.row == self.todayCell{
                self.dispCollectionView.cellForItem(at: indexPath)?.backgroundColor = calendarCellToday
            }

        }
    }
    
    func sortEventData(){
        self.sortedEvent = []
        if self.selectedDate == ""{
            return
        }
        print("date: \(self.selectedDate)")
        //print(self.sakaiDict)
        var num1: Int
        if outlookCommunication.instance.eventDict.keys.contains(self.selectedDate){
            num1 = (outlookCommunication.instance.eventDict[self.selectedDate]?.count)!
        }else{
            num1 = 0
        }
        print("num1: \(num1)")
        var num2: Int
        if sakaiDict.keys.contains(self.selectedDate){
            num2 = (sakaiDict[selectedDate]?.count)!
        }
        else{
            num2 = 0
        }
        print("num2: \(num2)")
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        for i in 0..<num1{
            //self.sortedEvent.append(["Calendar": i])
            self.sortedEvent.append(("Calendar", i))
        }
        for i in 0..<num2{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            var start: String
            let eventStartDate = dateFormatter.date(from: String(self.sakaiDict[selectedDate]![i].due.prefix(19)))
            if num1 == 0{
                self.sortedEvent.append(("Sakai", i))
            }
            else{
            for index in 0..<self.sortedEvent.count {
                let current = self.sortedEvent[index]
                // date in array in string format
                if current.calendar == "Calendar"{
                    start = outlookCommunication.instance.eventDict[selectedDate]![current.index].start!.dateTime
                }
                else{
                    start = self.sakaiDict[selectedDate]![current.index].due
                }
                // date in array in date formate
                let startDa = dateFormatter.date(from: String(start.prefix(19)))
                if startDa?.compare(eventStartDate!) == .orderedDescending{
                    self.sortedEvent.insert(("Sakai", i), at: index)
                    break
                }
                if index == self.sortedEvent.count - 1{
                    self.sortedEvent.append(("Sakai", i))
                }
            }
            }
        }
        print("sortedEvent:\(self.sortedEvent)")
    }
    
    func addWeekdayLabel(){
        let totalWidth = self.dispCollectionView.bounds.width
        let itemWidth = totalWidth/7.0
        let bottomBorder = self.dispCollectionView.frame.origin.y
        let upperBorder = bottomBorder - 15
        for i in 0..<7{
            let x = Float(itemWidth) * Float(i)
            let weekdayLabel = UILabel(frame: CGRect(x: CGFloat(x), y: upperBorder, width: itemWidth, height: 20))
            weekdayLabel.text = weekdayLiteral[i+1]
            weekdayLabel.font = .systemFont(ofSize: 12)
            weekdayLabel.textAlignment = .center
            weekdayLabel.textColor = darkerBlue[7]
            self.view.addSubview(weekdayLabel)
        }
    }
}
