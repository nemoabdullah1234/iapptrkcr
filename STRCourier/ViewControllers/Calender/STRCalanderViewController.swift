import UIKit
import JTAppleCalendar

class STRCalanderViewController: UIViewController{
  
    @IBOutlet  var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    var dateAlreadySelected: Date?
    var closure:((Date)->())?
    
    
    @IBOutlet weak var weekDayLabel: UILabel!
   @IBOutlet weak var weekDay1: UILabel!
    @IBOutlet weak var weekDay2: UILabel!
    @IBOutlet weak var weekDay3: UILabel!
    @IBOutlet weak var weekDay4: UILabel!
    @IBOutlet weak var weekDay5: UILabel!
    @IBOutlet weak var weekDay6: UILabel!
    
    @IBOutlet weak var todayButton: UIButton!
    
    
    
    var numberOfRows = 6
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var prePostVisibility: ((CellState, CellView?)->())?
    var hasStrictBoundaries = true
    let firstDayOfWeek: DaysOfWeek = .monday
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    let dateCellSize: CGFloat? = nil
    var monthSize: MonthSize? = nil
    var prepostHiddenValue = false
    
    let red = UIColor.red
    let white = UIColor.white
    let black = UIColor.black
    let gray = UIColor.gray
    let blue = UIColor.blue
    

    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        formatter.dateFormat = "yyyy MM dd"
        testCalendar.timeZone = TimeZone(abbreviation: "IST")!
        
        self.calendarView.register(UINib(nibName: "CellView", bundle: nil), forCellWithReuseIdentifier: "CellView")
      
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
       
       self.calendarView.scrollingMode = .stopAtEachCalendarFrameWidth

        
        
        
       
//        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
//            self.setupViewsOfCalendar(from: visibleDates)
//        }

 
       setUpFont()
    
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let firstDateInfo = calendarView.visibleDates().indates.first {
            calendarView.viewWillTransition(to: size, with: coordinator, focusDateIndexPathAfterRotate: firstDateInfo.indexPath)
        } else {
            let firstDateInfo = calendarView.visibleDates().monthDates.first!
            calendarView.viewWillTransition(to: size, with: coordinator, focusDateIndexPathAfterRotate: firstDateInfo.indexPath)
        }
        
        
        
    }
    
    var rangeSelectedDates: [Date] = []
    func didStartRangeSelecting(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        rangeSelectedDates = calendarView.selectedDates
        if let cellState = calendarView.cellStatus(at: point) {
            let date = cellState.date
            if !calendarView.selectedDates.contains(date) {
                let dateRange = calendarView.generateDateRange(from: calendarView.selectedDates.first ?? date, to: date)
                for aDate in dateRange {
                    if !rangeSelectedDates.contains(aDate) {
                        rangeSelectedDates.append(aDate)
                    }
                }
                calendarView.selectDates(from: rangeSelectedDates.first!, to: date, keepSelectionIfMultiSelectionAllowed: true)
            } else {
                let indexOfNewlySelectedDate = rangeSelectedDates.index(of: date)!
                let lastIndex = rangeSelectedDates.endIndex
                let followingDay = testCalendar.date(byAdding: .day, value: 1, to: date)!
                calendarView.selectDates(from: followingDay, to: rangeSelectedDates.last!, keepSelectionIfMultiSelectionAllowed: false)
                rangeSelectedDates.removeSubrange(indexOfNewlySelectedDate..<lastIndex)
            }
        }
        
        if gesture.state == .ended {
            rangeSelectedDates.removeAll()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         print(Date(), dateAlreadySelected!)
        
        calendarView.scrollToDate(dateAlreadySelected!)
    }
    
    
    
    @IBAction func todayBtnClicked(_ sender: AnyObject) {
        
        calendarView.scrollToDate(Date())
        
    }
    
    
    
    func setUpFont(){
        self.todayButton.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 20)!
        self.monthLabel.font =  UIFont(name: "SourceSansPro-Semibold", size: 20)!
     self.weekDayLabel.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay1.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay2.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay3.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay4.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay5.font = UIFont(name: "SourceSansPro-Semibold", size:15)!
         self.weekDay6.font = UIFont(name: "SourceSansPro-Semibold", size:15)!

        
        
    }
    
    
    
    
    @IBAction func printSelectedDates() {
        print("\nSelected dates --->")
        for date in calendarView.selectedDates {
            print(formatter.string(from: date))
            self.dateAlreadySelected = date
        }
        done()
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        self.calendarView.scrollToSegment(.next)
        

        
       
    }
    @IBAction func previous(_ sender: UIButton) {
       self.calendarView.scrollToSegment(.previous)
    }

    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = testCalendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        prePostVisibility?(cellState, cell as? CellView)
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = white
            } else {
                myCustomCell.dayLabel.textColor = gray
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell : CellView = view as? CellView else {return }
        //        switch cellState.selectedPosition() {
        //        case .full:
        //            myCustomCell.backgroundColor = .green
        //        case .left:
        //            myCustomCell.backgroundColor = .yellow
        //        case .right:
        //            myCustomCell.backgroundColor = .red
        //        case .middle:
        //            myCustomCell.backgroundColor = .blue
        //        case .none:
        //            myCustomCell.backgroundColor = nil
        //        }
        //
      
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  5
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setUpNaveBar(){
        let button: UIButton = UIButton.init()
        
        button.setImage(nil, for: UIControlState())
        button.setTitle("Done", for: UIControlState())
        button.addTarget(self, action: #selector(STRCalanderViewController.done), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    @IBAction func backFunc(){
       self.dismiss(animated: true, completion: nil)
    }
    
    
    func done(){
         print(Date(), dateAlreadySelected)
        self.dismiss(animated: true) {
            if((self.closure != nil)&&(self.dateAlreadySelected != nil))
            {
            self.closure!(self.dateAlreadySelected!)
            }
        }
    }

   }


extension STRCalanderViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate  {
    // Setting up manditory protocol method
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        
        let startDate = formatter.date(from: "2016 01 01")!
        let endDate = formatter.date(from: "2018 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: firstDayOfWeek,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        
        
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        
        myCustomCell.dayLabel.text = cellState.text
        if testCalendar.isDate(date, inSameDayAs: dateAlreadySelected!) {
            myCustomCell.backgroundColor = red
        }else if testCalendar.isDateInToday(date)
        {
            myCustomCell.backgroundColor = blue
        } else {
            myCustomCell.backgroundColor = black
        }
        
        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        printSelectedDates()
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func scrollDidEndDecelerating(for calendar: JTAppleCalendarView) {
        let visibleDates = calendarView.visibleDates()
        //        let dateWeShouldNotCross = formatter.date(from: "2017 08 07")!
        //        let dateToScrollBackTo = formatter.date(from: "2017 07 03")!
        //        if visibleDates.monthDates.contains (where: {$0.date >= dateWeShouldNotCross}) {
        //            calendarView.scrollToDate(dateToScrollBackTo)
        //            return
        //        }
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let date = range.start
        let month = testCalendar.component(.month, from: date)
        
        let header: JTAppleCollectionReusableView
        if month % 2 > 0 {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "WhiteSectionHeaderView", for: indexPath)
            (header as! WhiteSectionHeaderView).title.text = formatter.string(from: date)
        } else {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "PinkSectionHeaderView", for: indexPath)
            (header as! PinkSectionHeaderView).title.text = formatter.string(from: date)
        }
        return header
    }
    
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendarView.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendarView.frame.width - 10, height: calendarView.frame.height - 10)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
    
    
    



}


