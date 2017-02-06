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

class GIntakeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    
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
    
    var selectedConditionIndex : Int = 0
    var lastSelectedDate = Date()
    var topBackView:UIView = UIView()
    var currentLocale : String = ""
    
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
        dateInputOKButton.setTitle("Ok".localized, for: .normal)
        
    
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
            enterGlucoseLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
            doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
           // conditionSegmentedControl.titleForSegment(at: 0) = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
            conditionSegmentedControl.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold) ], for: .normal)
            conditionSegmentedControl.setTitleTextAttributes([ NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold) ], for: .selected)
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        guard let textFieldText = self.enterGlucoseTextField.text else { return; }
        
        if(textFieldText.length == 0 || textFieldText == "0")
        {
            enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
            enterGlucoseTextField.textColor = Colors.PrimaryColor
            //showAlert(title: "Data missing".localized, message: "Please input a valid number".localized)
            
            //return;
        }
        else{
            self.enterGlucoseTextField.resignFirstResponder()
            self.enterGlucoseTextField.resignFirstResponder()
            self.enterGlucoseTextField.textColor = UIColor.white
            enterGlucoseTextFieldView.backgroundColor = Colors.DHTabBarGreen
            
            mealPickerView.isUserInteractionEnabled = true
            mealPickerView.alpha = 1.0
            
            conditionSegmentedControl.isUserInteractionEnabled = true
            conditionSegmentedControl.alpha = 1.0
        }
        
        self.enterGlucoseTextField.resignFirstResponder()
        self.enterGlucoseTextField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAppearance()
        
       
        
        //        if mealArray.count > 0 {
        //            let index = mealArray.count == 1 ? 1 : mealArray.count % 2 + 1
        //            mealPickerView.selectRow(index, inComponent: 0, animated: false)
        //            selectedMeal = mealArray[index]
        //        }
        
        //Get indexes for fasting and bedtime
        fastingIndex = mealArrayEng.index(of: "Fasting")
        bedtimeIndex = mealArrayEng.index(of: "Bedtime")
        breakfastIndex = mealArrayEng.index(of: "Breakfast")
    }
    
    func createCustomTopView() {
        
        topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
        topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
        let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
        userImgView.image = UIImage(named: "user.png")
        // topBackView.addSubview(userImgView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
        topBackView.addGestureRecognizer(tapGesture)
        topBackView.isUserInteractionEnabled = true
        
        self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
        self.navigationController?.navigationBar.addSubview(topBackView)
        
        
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
        enterGlucoseTextField.textColor = Colors.PrimaryColor
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
            conditionSegmentedControl.setEnabled(true, forSegmentAt: 1)
            conditionSegmentedControl.setEnabled(true, forSegmentAt: 0)
            doneButton.isEnabled = false
            doneButton.alpha = 0.25
        }
        
        
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
        enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
        enterGlucoseTextField.textColor = Colors.PrimaryColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GIntakeViewController.dismissKeyboard(_:))))
        //        glucoseEntry = textField.text
        
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
        
        textField.text = textFieldText + " mg/dl"
        
        
       // mealPickerView.isUserInteractionEnabled = true
       // mealPickerView.alpha = 1.0
        //conditionSegmentedControl.isUserInteractionEnabled = true
        //conditionSegmentedControl.alpha = 1.0
    }
    
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        
        guard let textFieldText = enterGlucoseTextField.text else { return; }
        
        if let number = Int(textFieldText)
        {
             if(textFieldText.length == 0 || textFieldText == "0")
             {
                enterGlucoseTextFieldView.backgroundColor = Colors.DHLightGray
                enterGlucoseTextField.textColor = Colors.PrimaryColor
            //showAlert(title: "Data missing", message: "Please input a valid number".localized)
            
            //return;
             }
             else{
          
                enterGlucoseTextField.textColor = UIColor.white
                enterGlucoseTextFieldView.backgroundColor = Colors.DHTabBarGreen
            
                mealPickerView.isUserInteractionEnabled = true
                mealPickerView.alpha = 1.0
                conditionSegmentedControl.isUserInteractionEnabled = true
                conditionSegmentedControl.alpha = 1.0
            }
            enterGlucoseTextField.resignFirstResponder()
            view.removeGestureRecognizer(sender)
        }
        else{
            showAlert(title: "Valid Data", message: "Please input a valid number".localized)
        }
       
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
        string.append(NSAttributedString(string: "\(dateFormatter.string(from: date))", attributes: [NSForegroundColorAttributeName: Colors.PrimaryColor, NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)]))
        string.append(NSAttributedString(string: " >", attributes: [NSForegroundColorAttributeName: Colors.DHDarkGray, NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)]))
        
        dateButton.setAttributedTitle(string, for: .normal)
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
            showAlert(title: "Data missing", message: "Please input a valid number".localized)
            return
        }
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
                self.tabBarController!.selectedIndex = 1
                break
                
            case .failure:
                break
            }
            
            //            }
        }
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
        
        let trimmedCondition = condition.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
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
        switch condition {
        case "Before Meal", "Snacks", "Before Breakfast", "Before Lunch", "Before Dinner":
            return "Normal Range: 70 to 130".localized
        case "2 hours after Meal", "2 hours after Breakfast", "2 hours after Lunch", "2 hours after Dinner":
            return "Normal Range: Under 180".localized
        case "Before Exercise", "2 hours after Exercise", "Exercise":
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
                inputConfirmationGlucoseLabel.textColor = UIColor.orange
                inputConfirmationDescriptionLabel.text = "Comments?"
               // inputConfirmationDescriptionLabel.text = "The value you have entered is out of the normal (lower) range for \(condition) condition. Please specify a reason:"
            }
            else if readingState == .high {
                inputConfirmationWarningLabel.text = getNormalRange(condition: condition)
                inputConfirmationGlucoseLabel.textColor = UIColor.orange
                inputConfirmationHeightConstraint.constant = inputConfirmationHeightBig
                inputConfirmationTitleLabel.text = "Out of Range".localized
                inputConfirmationDescriptionLabel.text = "Comments?"
               // inputConfirmationDescriptionLabel.text = "The value you have entered is out of the normal (higher) range for \(condition) condition. Please specify a reason:"
            }
            else  {
                inputConfirmationWarningLabel.text = ""
                inputConfirmationGlucoseLabel.textColor = Colors.DHIntakeGreen //57C5B8
                inputConfirmationHeightConstraint.constant = inputConfirmationHeightSmall
                inputConfirmationTitleLabel.text = "Confirmation".localized
               // inputConfirmationDescriptionLabel.text = "Are you sure you want to add this G-Intake value to your reading history?"
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
        //selectedDate = lastSelectedDate
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
        
        navigationController.isNavigationBarHidden = false
        
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
