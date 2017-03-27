//
//  GIntakeViewController.swift
//  DiabetesApp
//
//  Created by User on 1/7/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SVProgressHUD


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}


class GIntakeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FSCalendarDataSource, FSCalendarDelegate {
    
    
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var intakeContainerView: UIView!
    @IBOutlet weak var enterGlucoseLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var conditionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var mealPickerView: UIPickerView!
    @IBOutlet weak var enterGlucoseTextFieldView: UIView!
    @IBOutlet weak var enterGlucoseTextField: UITextField!
    
    
    @IBOutlet weak var dateInputView: UIView!
    @IBOutlet weak var dateInputContainerView: UIView!
    @IBOutlet weak var dateInputTitleLabel: UILabel!
    @IBOutlet weak var dateInputPicker: UIDatePicker!
    @IBOutlet weak var dateInputCancelButton: UIButton!
    @IBOutlet weak var dateInputOKButton: UIButton!
    
    
    @IBOutlet weak var inputConfirmationGlucoseRangeLabel: UILabel!
    @IBOutlet weak var inputConfirmationCancelButton: UIButton!
    @IBOutlet weak var inputConfirmationView: UIView!
    @IBOutlet weak var inputConfirmationContainerView: UIView!
    @IBOutlet weak var inputConfirmationTitleLabel: UILabel!
    
    @IBOutlet weak var inputConfirmationConfirmButton: UIButton!
    
    @IBOutlet weak var inputConfirmationGlucoseLabel: UILabel!
    @IBOutlet weak var inputConfirmationDescriptionLabel: UILabel!
    
    @IBOutlet weak var inputConfirmationYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputConfirmationDateLabel: UILabel!
    
    @IBOutlet weak var inputConfirmationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputConfirmationConditionLabel: UILabel!
    
    @IBOutlet weak var inputConfirmationCommentTextView: UITextView!
    @IBOutlet weak var inputConfirmationWarningLabel: UILabel!
    
    @IBOutlet weak var lblDateMonth: UILabel!
    
     @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    private var mealArray = ["Fasting".localized, "Breakfast".localized, "Lunch".localized, "Dinner".localized, "Bedtime".localized]
    private var mealArrayEng = ["Fasting", "Breakfast", "Lunch", "Dinner", "Bedtime"]
    private var selectedMeal: String?
    private var selectedDate = Date()
    private var glucoseEntry: String?
    
    private var fastingIndex: Int?
    private var bedtimeIndex: Int?
    private var breakfastIndex: Int?
    
    private let inputConfirmationHeightSmall: CGFloat = 245.0
    private let inputConfirmationHeightBig: CGFloat = 330.0
    private let inputConfirmationBottomConstraintDefault: CGFloat = 154.0
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var selectedConditionIndex : Int = 0
    var lastSelectedDate = Date()
    var topBackView:UIView = UIView()
    var currentLocale : String = ""
    var fromDoneButton : Bool = false
    
    var dictReadingList : [String] = []
    var dictReadingName:[String] = []

    
    
    var KeyboardTapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    private enum DHReadingState {
        case low, normal, high
    }
    
    private var confirmationViewShown = false
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        configureAppearance()
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(GIntakeViewController.dismissKeyboard(_:)))
        
        backgroundImage.alpha = 0.7
        NotificationCenter.default.addObserver(self, selector: #selector(GIntakeViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GIntakeViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        mealPickerView.dataSource = self
        mealPickerView.delegate = self
        enterGlucoseTextField.delegate = self
        
        setupNavigationBar(title: "ADD_GLUCOSE_LEVEL".localized)
        self.addDoneButtonOnKeyboard()
        let sideMenuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "SideMenuIcon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(GIntakeViewController.openSideMenu(_:)))
        navigationItem.setLeftBarButton(sideMenuButton, animated: false)
        
        if mealArray.count > 0 {
            let index = self.mealArray.count == 1 ? 0 : self.mealArray.count % 2 + 1
            selectedConditionIndex = index
            self.mealPickerView.selectRow(index, inComponent: 0, animated: true)
            selectedMeal = self.mealArray[index]
        }
        
        inputConfirmationConfirmButton.setTitle("CONFIRM".localized, for: .normal)
        inputConfirmationCancelButton.setTitle("CANCEL".localized, for: .normal)
        dateInputTitleLabel.text = "Change date and time".localized
        dateInputCancelButton.setTitle("Cancel".localized, for: .normal)
        dateInputOKButton.setTitle("DONE".localized, for: .normal)
        
    
        dateInputPicker.locale = NSLocale.init(localeIdentifier: "en") as Locale
        
        mealPickerView.isUserInteractionEnabled = false
        mealPickerView.alpha = 0.25
        
        conditionSegmentedControl.isEnabled = false
        conditionSegmentedControl.alpha = 0.25
        
        conditionSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
        conditionSegmentedControl.addTarget(self,  action: #selector(segmentedControlValueChanged), for:.touchUpInside)
        
        doneButton.isEnabled = false
        doneButton.alpha = 0.25
        
        currentLocale = NSLocale.current.languageCode!
        
        if currentLocale == "ar"{
            enterGlucoseLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
            enterGlucoseTextField.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
           // conditionSegmentedControl.titleForSegment(at: 0) = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
            conditionSegmentedControl.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold) ], for: .normal)
            conditionSegmentedControl.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold) ], for: .selected)
            
        }
        
        /*------------- Calander configuration ------------ */
        self.calendar.select(Date())
        self.calendar.scope = .week
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        var calAppearance = FSCalendarAppearance()
        calAppearance = self.calendar.appearance
        self.calendar.appearance.weekdayFont = UIFont(name: "SFUIText-Regular", size: 12)
        self.calendar.appearance.titleFont = UIFont(name: "SFUIDisplay-Bold", size: 16)
        self.calendar.formatter.dateFormat = calAppearance.headerDateFormat
        lblDateMonth.text = self.calendar.formatter.string(from: calendar.currentPage)
        selectedDate = self.calendar.selectedDate!
        print("\(self.calendar.formatter.string(from: calendar.currentPage))")
      
        
        self.perform(#selector(reloadCal), with: nil, afterDelay: 0.1)
        self.perform(#selector(reloadCal1), with: nil, afterDelay: 0.3)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func reloadCal()
    {
        let curDate = self.calendar.currentPage
        let myCalendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier(rawValue: NSGregorianCalendar))!
        
        let PrevWeek = myCalendar.date(byAdding: NSCalendar.Unit.weekOfMonth, value: -1 , to: curDate, options: NSCalendar.Options(rawValue: 0))
        self.calendar.setCurrentPage(PrevWeek!, animated: false)
    }
    func reloadCal1()
    {
        let curDate = self.calendar.currentPage
        let myCalendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier(rawValue: NSGregorianCalendar))!
        
        let PrevWeek = myCalendar.date(byAdding: NSCalendar.Unit.weekOfMonth, value: 1 , to: curDate, options: NSCalendar.Options(rawValue: 0))
        self.calendar.setCurrentPage(PrevWeek!, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kGIntakeScreenName)
        //--------Google Analytics Finish-----
        
      
        
        mealPickerView.isUserInteractionEnabled = false
        mealPickerView.alpha = 0.25
        
        conditionSegmentedControl.isEnabled = false
        conditionSegmentedControl.alpha = 0.25
        conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        
        doneButton.isEnabled = false
        doneButton.alpha = 0.25
        
        
    }
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        doneButton.isEnabled = true
        doneButton.alpha = 1.0
    }
    
    func addDoneButtonOnKeyboard()
    {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "DONE".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneButtonAction))]
        toolBar.sizeToFit()
        
        self.enterGlucoseTextField.inputAccessoryView = toolBar
        
    }
    
    
    func doneButtonAction()
    {
        self.view.endEditing(true)
        guard let textFieldTextTemp = enterGlucoseTextField.text else { return; }
        glucoseEntry = ""
        let numberStr: String = textFieldTextTemp
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
        view.removeGestureRecognizer(KeyboardTapGesture)
        if let final = formatter.number(from: numberStr) { glucoseEntry = String(describing: final)
            print(final) }
        
        enterGlucoseTextField.text = glucoseEntry
       // view.removeGestureRecognizer(enterGlucoseTextField)
        guard let textFieldText = enterGlucoseTextField.text else { return; }

       // fromDoneButton = true
        if(textFieldText.length == 0 || textFieldText == "0")
        {
            
            /*enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
            enterGlucoseTextField.textColor = Colors.PrimaryColor
            enterGlucoseTextField.text = "EG".localized + " 120 mg/dl"*/
            enterGlucoseTextField.resignFirstResponder()
           
           /* mealPickerView.isUserInteractionEnabled = false
            mealPickerView.alpha = 0.25
            
            conditionSegmentedControl.isEnabled = false
            conditionSegmentedControl.alpha = 0.25
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment*/
            
            invalidReadingEntered()
            
            
           // view.removeGestureRecognizer(sender)
            //showAlert(title: "Data missing", message: "Please input a valid number".localized)
            
            //return;
        }
        else if let number = Int(textFieldText)
        {
            if number > 600
            {
               /* enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
                enterGlucoseTextField.textColor = Colors.PrimaryColor
                enterGlucoseTextField.text = "EG".localized + " 120 mg/dl"*/
                enterGlucoseTextField.resignFirstResponder()
               /* mealPickerView.isUserInteractionEnabled = false
                mealPickerView.alpha = 0.25
                
                conditionSegmentedControl.isEnabled = false
                conditionSegmentedControl.alpha = 0.25
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                */
                invalidReadingEntered()
                
                
                showAlert(title: "Invalid Reading".localized, message: "Your reading has to be less than 600mg/dl".localized)
                
            }
            else
            {
                
                enterGlucoseTextField.textColor = UIColor.white
                enterGlucoseTextFieldView.backgroundColor = Colors.DHTabBarGreen
                enterGlucoseTextField.text = textFieldText + " mg/dl"
                
                mealPickerView.isUserInteractionEnabled = true
                mealPickerView.alpha = 1.0
                conditionSegmentedControl.isUserInteractionEnabled = true
                conditionSegmentedControl.alpha = 1.0

                
                enterGlucoseTextField.resignFirstResponder()
                //view.removeGestureRecognizer(sender)
                
                mealPickerView.isUserInteractionEnabled = true
                mealPickerView.alpha = 1.0
                
                conditionSegmentedControl.isEnabled = true
                conditionSegmentedControl.isUserInteractionEnabled = true
                conditionSegmentedControl.alpha = 1.0
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment

               // view.removeGestureRecognizer(sender)
            }
        }
       conditionSegmentEnable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateInputPicker.date = Date()
        lastSelectedDate = Date()
        configureAppearance()
        getReadingsList()
        
       //Get indexes for fasting and bedtime
        fastingIndex = mealArrayEng.index(of: "Fasting")
        bedtimeIndex = mealArrayEng.index(of: "Bedtime")
        breakfastIndex = mealArrayEng.index(of: "Breakfast")
        
    }
    //MARK: - Calandar configuration 
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        selectedDate = date
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        var calAppearance = FSCalendarAppearance()
        calAppearance = self.calendar.appearance
        self.calendar.formatter.dateFormat = calAppearance.headerDateFormat
        lblDateMonth.text = self.calendar.formatter.string(from: calendar.currentPage)
        print("\(self.calendar.formatter.string(from: calendar.currentPage))")
    }
    //MARK: - Configure appearance
    private func configureAppearance() {
        intakeContainerView.layer.cornerRadius = kButtonRadius
        intakeContainerView.layer.masksToBounds = true
        enterGlucoseTextFieldView.layer.cornerRadius = kButtonRadius
        enterGlucoseTextFieldView.layer.masksToBounds = true
        
        self.title = "G-Intake".localized
        self.tabBarController?.title = "G-Intake".localized
        self.tabBarController?.navigationItem.title = "ADD_GLUCOSE_LEVEL".localized
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        // createCustomTopView()
        enterGlucoseLabel.textColor = Colors.PrimaryColor
        
        enterGlucoseTextFieldView.backgroundColor = UIColor(red: 0.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 0.1)
        enterGlucoseTextFieldView.layer.borderColor = Colors.PrimaryColor.cgColor
        enterGlucoseTextFieldView.layer.borderWidth = 1.0
        enterGlucoseTextFieldView.layer.cornerRadius = kButtonRadius
        
        conditionSegmentedControl.layer.cornerRadius = kButtonRadius
        conditionSegmentedControl.layer.masksToBounds = true
        conditionSegmentedControl.layer.borderColor = Colors.PrimaryColor.cgColor
        conditionSegmentedControl.layer.borderWidth = 1.0
        
        enterGlucoseLabel.text  = "ENTER_YOUR_GLUCOSE".localized
        //conditionLabel.text     = "CHOOSE_TIMING".localized
        enterGlucoseTextField.text = "EG".localized + " 120mg/dl"
        enterGlucoseTextField.textColor = Colors.PrimaryColorAlpha
        //enterGlucoseTextField.attributedPlaceholder = NSAttributedString(string: enterGlucoseTextField.text!,
                                                            //       attributes: [NSForegroundColorAttributeName: Colors.PrimaryColorAlpha] )
        // enterGlucoseTextField.layer.borderWidth = 1.5
        
        updateSelectedDate(Date())
        
        if mealArray.count > 0 {
            let index = self.mealArray.count == 1 ? 0 : self.mealArray.count % 2 + 1
            selectedConditionIndex = index
            self.mealPickerView.selectRow(index, inComponent: 0, animated: true)
            selectedMeal = self.mealArray[index]
        }
        
        dateInputView.isHidden = true
        dateInputContainerView.layer.cornerRadius = kButtonRadius
        dateInputContainerView.layer.masksToBounds = true
        
        dateInputOKButton.layer.borderColor = Colors.DHLightGray.cgColor
        dateInputOKButton.layer.borderWidth = 0.5
        dateInputCancelButton.layer.borderColor = Colors.DHLightGray.cgColor
        dateInputCancelButton.layer.borderWidth = 0.5
        
        inputConfirmationCommentTextView.layer.borderColor = Colors.DHLightGray.cgColor
        inputConfirmationCommentTextView.layer.borderWidth = 1
        inputConfirmationCommentTextView.layer.cornerRadius =  kButtonRadius
        
        inputConfirmationView.isHidden = true
        inputConfirmationContainerView.layer.cornerRadius = 5
        inputConfirmationContainerView.layer.masksToBounds = true
        
        inputConfirmationConfirmButton.layer.borderColor = Colors.DHLightGray.cgColor
        inputConfirmationConfirmButton.layer.borderWidth = 0.5
        inputConfirmationCancelButton.layer.borderColor = Colors.DHLightGray.cgColor
        inputConfirmationCancelButton.layer.borderWidth = 0.5
        
        conditionSegmentedControl.setTitle("PRE".localized, forSegmentAt: 0)
        conditionSegmentedControl.setTitle("POST".localized, forSegmentAt: 1)
        
        doneButton.setTitle("DONE".localized, for: .normal)
        // doneButton.layer.cornerRadius = doneButton.bounds.size.height / 2
        doneButton.layer.cornerRadius = kButtonRadius
        doneButton.layer.masksToBounds = true
        
        dateInputPicker.maximumDate = Date()
        
        
        //Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = doneButton.bounds
        
        let color1 = Colors.DHBackgroundGreen.cgColor
        let color2 = Colors.DHBackgroundBlue.cgColor
        
        gradientLayer.colors = [color1, color2]
        
        //doneButton.layer.insertSublayer(gradientLayer, at: 0)
        
        //Add blur to overlay views
        let blurEffect = UIBlurEffect(style: .dark)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = dateInputView.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dateInputView.insertSubview(blurEffectView, belowSubview: dateInputContainerView)
        
        let confirmationBlurEffectView = UIVisualEffectView(effect: blurEffect)
        confirmationBlurEffectView.frame = inputConfirmationView.bounds
        
        confirmationBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        inputConfirmationView.insertSubview(confirmationBlurEffectView, belowSubview: inputConfirmationContainerView)
    }
    
    private func getReadingsList(){
    
        let selectedPatientID : String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid": selectedPatientID,
        ]

        Alamofire.request("http://54.244.176.114:3000/getPatReadings", method: .post,  parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                    case .success:
                        
                        if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                            print (JSON)
                            
                            if let readingsList: NSArray = JSON.value(forKey:"readingsTime") as? NSArray {
                                //                    self.array = NSMutableArray()
                                self.dictReadingName.removeAll()
                                self.dictReadingList.removeAll()
                                for data in readingsList {
                                    let dict: NSDictionary = data as! NSDictionary
                                    var tempCondition : String = dict.value(forKey: "time") as! String
                                    var condition : String = ""
                                    var tempString : [String] = tempCondition.components(separatedBy: " ")
                                    if(tempString[0] == "Before")
                                    {
                                        condition = "Pre "+tempString[1]
                                    }
                                    else if(tempString[0] == "After")
                                    {
                                        condition = "Post "+tempString[1]

                                    }
                                    else{
                                        condition = tempCondition
                                    }
                                    
                                    self.dictReadingName.append(condition)
                                    self.dictReadingList.append(dict.value(forKey: "goal") as! String)
                                    //let obj = medicationObj()
                                    //obj.medicineName = dict.value(forKey: "medicineName") as! String
                                    //obj.medicineImage = dict.value(forKey: "medicineImage") as! String
                                    //obj.type = dict.value(forKey: "type") as! String
                                    //dictMedicationList.add(obj)
                                    //dictMedicationName.append(dict.value(forKey: "medicineName") as! String)
                                }
                            }
                        }
                        
                    break
                    case .failure:
                    break
                }
            }
    }
    
    func invalidReadingEntered(){
        
        enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
        enterGlucoseTextField.textColor = Colors.PrimaryColorAlpha
        enterGlucoseTextField.text = "EG".localized + " 120 mg/dl"
        
        mealPickerView.isUserInteractionEnabled = false
        mealPickerView.alpha = 0.25
        
        conditionSegmentedControl.isEnabled = false
        conditionSegmentedControl.alpha = 0.25
        conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func conditionSegmentEnable(){
        
        if conditionSegmentedControl.isEnabled{
            //let pickerRow : Int = selecteedConditionIndex
            
            if let fastingIndex = fastingIndex, fastingIndex == selectedConditionIndex {
                conditionSegmentedControl.isEnabled = false
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                doneButton.isEnabled = true
                doneButton.alpha = 1.0
            }
            else if let bedtimeIndex = bedtimeIndex, bedtimeIndex == selectedConditionIndex {
                conditionSegmentedControl.isEnabled = false
                
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                doneButton.isEnabled = true
                doneButton.alpha = 1.0
            }
            else if let breakfastIndex = breakfastIndex, breakfastIndex == selectedConditionIndex {
                
                conditionSegmentedControl.isEnabled = true
                conditionSegmentedControl.alpha = 1.0
                conditionSegmentedControl.setEnabled(true, forSegmentAt: 1)
                conditionSegmentedControl.setEnabled(false, forSegmentAt: 0)
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                doneButton.isEnabled = false
                doneButton.alpha = 0.25
            }
            else {
                conditionSegmentedControl.isEnabled = true
                conditionSegmentedControl.alpha = 1.0
                conditionSegmentedControl.setEnabled(true, forSegmentAt: 1)
                conditionSegmentedControl.setEnabled(true, forSegmentAt: 0)
                doneButton.isEnabled = false
                doneButton.alpha = 0.25
            }

            
        }
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        var rowHeight : CGFloat = 23.0
        if currentLocale == "ar"{
            rowHeight = 30.0
        }
        return rowHeight
    }
    
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = (row == pickerView.selectedRow(inComponent: component)) ? Colors.PrimaryColor : Colors.PrimaryColorAlpha
        return NSAttributedString(string: mealArray[row], attributes: [NSFontAttributeName: Fonts.SFTextMediumFont , NSForegroundColorAttributeName: color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(0)
        selectedMeal = mealArray[row]
        selectedConditionIndex = row
        
        // doneButton.isEnabled = true
        //  doneButton.alpha = 1.0
        //If selected value is Fasting or Bedtime the segmented control should be disabled
        if let fastingIndex = fastingIndex, fastingIndex == row {
            conditionSegmentedControl.isEnabled = false
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            doneButton.isEnabled = true
            doneButton.alpha = 1.0
        }
        else if let bedtimeIndex = bedtimeIndex, bedtimeIndex == row {
            conditionSegmentedControl.isEnabled = false
            
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            doneButton.isEnabled = true
            doneButton.alpha = 1.0
        }
        else if let breakfastIndex = breakfastIndex, breakfastIndex == row {
            
            conditionSegmentedControl.isEnabled = true
            conditionSegmentedControl.alpha = 1.0
            conditionSegmentedControl.setEnabled(true, forSegmentAt: 1)
            conditionSegmentedControl.setEnabled(false, forSegmentAt: 0)
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            doneButton.isEnabled = false
            doneButton.alpha = 0.25
        }
        else {
            conditionSegmentedControl.isEnabled = true
            conditionSegmentedControl.alpha = 1.0
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            conditionSegmentedControl.setEnabled(true, forSegmentAt: 1)
            conditionSegmentedControl.setEnabled(true, forSegmentAt: 0)
            doneButton.isEnabled = false
            doneButton.alpha = 0.25
        }
        
        
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
        enterGlucoseTextField.text = ""
        glucoseEntry = ""
        enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
        enterGlucoseTextField.textColor = Colors.PrimaryColor
        view.addGestureRecognizer(KeyboardTapGesture)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        
        let numberStr: String = textFieldText
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
        
        if let final = formatter.number(from: numberStr) { glucoseEntry = String(describing: final)
            print(final) }
        
        //textField.text = textFieldText + " mg/dl"
        
        
       // mealPickerView.isUserInteractionEnabled = true
       // mealPickerView.alpha = 1.0
        //conditionSegmentedControl.isUserInteractionEnabled = true
        //conditionSegmentedControl.alpha = 1.0
    }
    
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        
        guard let textFieldTextTemp = enterGlucoseTextField.text else { return; }
        
        let numberStr: String = textFieldTextTemp
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "EN") as Locale!
        glucoseEntry = ""
        if let final = formatter.number(from: numberStr) { glucoseEntry = String(describing: final)
            print(final) }
        enterGlucoseTextField.text = glucoseEntry
       
        
        guard let textFieldText = enterGlucoseTextField.text else { return; }

        if(textFieldText.length == 0 || textFieldText == "0")
        {
            /*enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
            enterGlucoseTextField.textColor = Colors.PrimaryColor
            enterGlucoseTextField.text = "EG".localized + " 120 mg/dl"*/
            enterGlucoseTextField.resignFirstResponder()
            view.removeGestureRecognizer(sender)
            
          /*  mealPickerView.isUserInteractionEnabled = false
            mealPickerView.alpha = 0.25
            
            conditionSegmentedControl.isEnabled = false
            conditionSegmentedControl.alpha = 0.25
            conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment*/
            
            invalidReadingEntered()
           // mealPickerEnable()
            //showAlert(title: "Data missing", message: "Please input a valid number".localized)
            
            //return;
        }
        else if let number = Int(textFieldText)
        {
            if number > 600
             {
               /* enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
                enterGlucoseTextField.textColor = Colors.PrimaryColor
                enterGlucoseTextField.text = "EG".localized + " 120 mg/dl"
                */
                enterGlucoseTextField.resignFirstResponder()
                view.removeGestureRecognizer(sender)

                
                /*mealPickerView.isUserInteractionEnabled = false
                mealPickerView.alpha = 0.25
                
                conditionSegmentedControl.isEnabled = false
                conditionSegmentedControl.alpha = 0.25
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment*/
                invalidReadingEntered()
               // mealPickerEnable()
                
                showAlert(title: "Invalid Reading".localized, message: "Your reading has to be less than 600mg/dl".localized)



             }
             else
             {
          
                enterGlucoseTextField.textColor = UIColor.white
                enterGlucoseTextFieldView.backgroundColor = Colors.DHTabBarGreen
                
                enterGlucoseTextField.text = textFieldText + " mg/dl"
            
                enterGlucoseTextField.resignFirstResponder()
                view.removeGestureRecognizer(sender)
                
                mealPickerView.isUserInteractionEnabled = true
                mealPickerView.alpha = 1.0
                
                conditionSegmentedControl.isUserInteractionEnabled = true
                conditionSegmentedControl.isEnabled = true
                conditionSegmentedControl.alpha = 1.0
                conditionSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                
            }
        }
        
       // else{
         //   showAlert(title: "Valid Data", message: "Please input a valid number".localized)
        //}
       conditionSegmentEnable()
    }
    
    private func showOverlay(overlayView: UIView) {
        overlayView.alpha = 0.0
        overlayView.isHidden = false
        
        UIView.animate(withDuration: 0.15) {
            overlayView.alpha = 1.0
        }
    }
    
    private func hideOverlay(overlayView: UIView) {
        UIView.animate(withDuration: 0.15, animations: {
            overlayView.alpha = 0.0
        }) { _ in
            overlayView.isHidden = true
        }
    }
    
    private func updateSelectedDate(_ date: Date) {
        print("Called now")
        selectedDate = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d'\(NSDate.daySuffix(from: date as NSDate))' MMMM hh:mm a"
        dateFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
       
       
        
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "\(dateFormatter.string(from: date))", attributes: [NSForegroundColorAttributeName: Colors.PrimaryColor, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]))
        string.append(NSAttributedString(string: " >", attributes: [NSForegroundColorAttributeName: Colors.DHDarkGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]))
        
      //  dateButton.setAttributedTitle(string, for: .normal)
        inputConfirmationDateLabel.text = String(describing: string)
    }
    
    private func uploadGlucoseData() {
        SVProgressHUD.show(withStatus: "Saving data...".localized)
        
        let patientID = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM YYYY hh:mm a"
        dateFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
        
        let dateTaken = dateFormatter.string(from: selectedDate)
        
        if glucoseEntry?.length == 0{
            showAlert(title: "Data missing".localized, message: "Please input a valid number".localized)
            return
        }
        
        //if let glucoseEntryNum = Int(glucoseEntry!){
            
            let comment = inputConfirmationCommentTextView.text
            let condition = getConditionValue()
            
            let parameters = ["id": patientID, "reading": glucoseEntry, "condition": condition, "comment": comment, "dateTaken": dateTaken]
            
            let started = NSDate()
            Alamofire.request("\(baseUrl)\(ApiMethods.saveGlucose)", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseString {(response) in
                
                SVProgressHUD.dismiss()
                let interval = NSDate().timeIntervalSince(started as Date)
                
                switch response.result
                {
                case .success:
                    print("Interval")
                    print(interval)
                    
                    let navController = self.tabBarController?.viewControllers![1] as! UINavigationController
                    let vc = navController.topViewController as! HistoryMainViewController
                    vc.resetSegment = true
                    self.tabBarController!.selectedIndex = 1
                    //        segmentControl.selectedSegmentIndex = 0
                    //        readingTypeSegmentControls.selectedSegmentIndex = 0
                    break
                    
                case .failure:
                    break
                }
                
                //            }
            }
            //showAlert(title: "Data invalid", message: "Please input a valid number".localized)
            //return
       /* }
        else{
            showAlert(title: "Data invalid", message: "Please input a valid number".localized)
            return

        }*/
        
       
    }
    
    private func getConditionValue() -> String? {
        
        if var  selectedMeal = selectedMeal {
            selectedMeal = mealArrayEng[selectedConditionIndex]
            var condition = ""
            if conditionSegmentedControl.isEnabled, conditionSegmentedControl.selectedSegmentIndex >= 0, var selectedCondition = conditionSegmentedControl.titleForSegment(at: conditionSegmentedControl.selectedSegmentIndex) {
                
                if(conditionSegmentedControl.selectedSegmentIndex == 0)
                {
                    selectedCondition = "Before"
                }
                else if(conditionSegmentedControl.selectedSegmentIndex == 1)
                {
                    selectedCondition = "After"
                }
                
                condition = selectedCondition
            }
            
            if(selectedMeal == "Breakfast" || selectedMeal == "Lunch" || selectedMeal == "Dinner")
            {
                if(condition == "" || condition.isEmpty){
                    
                    return nil
                }
            }
            
            if(!conditionSegmentedControl.isEnabled){
                return selectedMeal
            }
            
            if(condition == "Before")
            {
                condition = "Pre"
            }
            else{
                condition = "Post"
            }
            return condition + " " + selectedMeal
        }
        else {
            return nil
        }
    }
    
    private func checkIfOutOfRange(entryValue: Int, condition: String) -> DHReadingState {
        
        var minLimit : Int = 0
        var maxLimit : Int = 0
        
        let trimmedCondition = condition.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let readingLimitIndex = dictReadingName.index(of: trimmedCondition){
        
            if readingLimitIndex < dictReadingList.count{
                var limitString : String = dictReadingList[readingLimitIndex]
            
                limitString = limitString.removingWhitespaces()
                let limitsArray : [String] = limitString.components(separatedBy: "-")
            
                if let minDummy = Int(limitsArray[0]){
                    minLimit = Int(limitsArray[0])! as Int
                }
            
                if let maxDummy = Int(limitsArray[1]){
                    maxLimit = Int(limitsArray[1])! as Int
                }
            
                if entryValue < minLimit{
                    return .low
                }
                else if entryValue > maxLimit{
                    return .high
                }
                else
                {
                    return .normal
                }
            }
        }
        
        
        switch trimmedCondition {
        case "Pre Meal", "Snacks", "Pre Breakfast", "Pre Lunch", "Pre Dinner", "Fasting":
            if entryValue < 80 {
                return .low
            }
            else if entryValue > 130 {
                return .high
            }
            else {
                return .normal
            }
        case "Post Meal", "Post Breakfast", "Post Lunch", "Post Dinner", "Bedtime":
            if entryValue > 180 {
                return .high
            }
            else if entryValue < 70 {
                return .low
            }
            else {
                return .normal
            }
        case "Pre Exercise", "Post Exercise", "Exercise":
            if entryValue < 130 {
                return .low
            }
            else if entryValue > 180 {
                return .high
            }
            else {
                return .normal
            }
        default:
            return .normal
        }
    }
    
    private func getNormalRange(condition: String) -> String {
        
        if let readingLimitIndex = dictReadingName.index(of: condition){
            
            if readingLimitIndex < dictReadingList.count{
                var limitString : String = dictReadingList[readingLimitIndex]
                
                limitString = limitString.removingWhitespaces()
                let limitsArray : [String] = limitString.components(separatedBy: "-")
                
                return "Normal Range ".localized + limitsArray[0] + " to ".localized + limitsArray[1]
               
            }
        }
        
        switch condition {
        case "Pre Meal", "Snacks", "Pre Breakfast", "Pre Lunch", "Pre Dinner":
            return "Normal Range: 70 to 130".localized
        case "Post Meal", "Post Breakfast", "Post Lunch", "Post Dinner", "Bedtime":
            return "Normal Range: Under 180".localized
        case "Pre Exercise", "Post Exercise", "Exercise":
            return "Normal Range: 130 to 180".localized
        case "Fasting":
            return "Normal Range: 80 to 130".localized
        default:
            return ""
        }
    }
    
    @IBAction func dateButtonTap(_ sender: Any) {
        showOverlay(overlayView: dateInputView)
    }
    
    @IBAction func doneButtonTap(_ sender: Any) {
        if let glucoseEntry = glucoseEntry, let glucoseEntryInt = Int(glucoseEntry), var condition = getConditionValue() {
            
            if(condition == nil)
            {
                showAlert(title: "Data missing".localized, message: "Please select condition".localized)
                return;
            }
            
            let readingState = checkIfOutOfRange(entryValue: glucoseEntryInt, condition: condition)
            
            inputConfirmationCommentTextView.text = ""
            
            if readingState == .low {
                inputConfirmationWarningLabel.text = getNormalRange(condition: condition)
                inputConfirmationWarningLabel.textColor = Colors.DHPinkRed
                inputConfirmationHeightConstraint.constant = inputConfirmationHeightBig
                inputConfirmationTitleLabel.text = "Out of Range".localized
                inputConfirmationGlucoseLabel.textColor = Colors.DHPinkRed
                inputConfirmationGlucoseRangeLabel.textColor = Colors.DHPinkRed
                inputConfirmationGlucoseRangeLabel.text = "(low)".localized
                inputConfirmationDescriptionLabel.text = "Comments?".localized
                // inputConfirmationDescriptionLabel.text = "The value you have entered is out of the normal (lower) range for \(condition) condition. Please specify a reason:"
            }
            else if readingState == .high {
                inputConfirmationWarningLabel.text = getNormalRange(condition: condition)
                inputConfirmationWarningLabel.textColor = Colors.DHPinkRed
                inputConfirmationHeightConstraint.constant = inputConfirmationHeightBig
                inputConfirmationTitleLabel.text = "Out of Range".localized
                inputConfirmationGlucoseLabel.textColor = Colors.DHPinkRed
                inputConfirmationGlucoseRangeLabel.textColor = Colors.DHPinkRed
                inputConfirmationGlucoseRangeLabel.text = "(high)".localized

                inputConfirmationDescriptionLabel.text = "Comments?".localized
                // inputConfirmationDescriptionLabel.text = "The value you have entered is out of the normal (higher) range for \(condition) condition. Please specify a reason:"
            }
            else  {
                inputConfirmationWarningLabel.text = ""
                inputConfirmationGlucoseLabel.textColor = Colors.DHIntakeGreen //57C5B8
                inputConfirmationHeightConstraint.constant = inputConfirmationHeightSmall
                inputConfirmationTitleLabel.text = "Confirmation".localized
                inputConfirmationGlucoseRangeLabel.text = ""

                inputConfirmationDescriptionLabel.text = nil
            }
            
            inputConfirmationGlucoseLabel.text = glucoseEntry + " mg/dl"
            if(!condition.isEmpty)
            {
                var tempString : [String] = condition.components(separatedBy: " ")
                if(tempString[0] == "Pre")
                {
                    condition = "Before "+tempString[1]
                }
                else if(tempString[0] == "Post")
                {
                    if currentLocale == "ar"{
                        condition = "After "+tempString[1]
                    }
                    else{
                        condition = "2 hours after "+tempString[1]
                    }
                }
            }
            
            let conditionIndex = conditionsArrayEng.index(of: condition)
            
            if currentLocale == "ar"
            {
                inputConfirmationConditionLabel.text = conditionsArray[conditionIndex] as! String
            }
            else{
                inputConfirmationConditionLabel.text = condition

            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM hh:mm a"
            dateFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
            
            
            inputConfirmationDateLabel.text = "Reading for: "+dateFormatter.string(from: selectedDate)
            
            confirmationViewShown = true
            showOverlay(overlayView: inputConfirmationView)
        }
        else {
            showAlert(title: "Data missing", message: "Please enter all fields before submitting!")
        }
    }
    
    @IBAction func dateInputCancelTap(_ sender: Any) {
        selectedDate = lastSelectedDate
        print("Last selected date")
        print(lastSelectedDate)
        dateInputPicker.date = lastSelectedDate
        hideOverlay(overlayView: dateInputView)
    }
    
    @IBAction func dateInputOKTap(_ sender: Any) {
        updateSelectedDate(dateInputPicker.date)
        lastSelectedDate = dateInputPicker.date
        hideOverlay(overlayView: dateInputView)
    }
    
    @IBAction func inputConfirmationCancelTap(_ sender: Any) {
        inputConfirmationCommentTextView.resignFirstResponder()
        confirmationViewShown = false
        hideOverlay(overlayView: inputConfirmationView)
    }
    
    @IBAction func inputConfirmationConfirmTap(_ sender: Any) {
        inputConfirmationCommentTextView.resignFirstResponder()
        confirmationViewShown = false
        uploadGlucoseData()
        hideOverlay(overlayView: inputConfirmationView)
    }
    
    //MARK: - Helpers
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Navigation setup
    private func setupNavigationBar(title: String) {
        guard let navigationController = navigationController else { return }
        
        navigationController.isNavigationBarHidden = true
        
        navigationItem.title = title.uppercased()
        
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]
        // navigationController.navigationBar.backgroundColor = Colors.PrimaryColor
        //Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = navigationController.navigationBar.bounds
        
        //This needs to be done to show gradient under status bar
        gradientLayer.frame.origin.y = -20.0
        gradientLayer.frame.size.height = gradientLayer.frame.size.height + 20.0
        
        // let color1 = Colors.DHBackgroundGreen.cgColor
        //let color2 = Colors.DHBackgroundBlue.cgColor
        
        //let color1 = Colors.PrimaryColor.cgColor
        // gradientLayer.colors = [color1, color2]
        // gradientLayer.colors = [color1]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // navigationController.navigationBar.layer.backgroundColor = Colors.PrimaryColor.cgColor
        //navigationController.navigationBar.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func openSideMenu(_ sender: AnyObject) {
        //For now this will be used for logout
        //        DispatchQueue.main.async {
        //            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        //            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        //            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
        //                NotificationCenter.default.post(name: Notification.Name(rawValue: kDHNotificationUserLoggedOut), object: nil)
        //            }))
        //            self.present(alert, animated: true, completion: nil)
        //        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if confirmationViewShown, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if inputConfirmationYAlignmentConstraint.constant == 0 {
                inputConfirmationYAlignmentConstraint.constant -= keyboardSize.height / 2
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if inputConfirmationYAlignmentConstraint.constant != 0{
                inputConfirmationYAlignmentConstraint.constant += keyboardSize.height / 2
            }
        }
    }
    
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
