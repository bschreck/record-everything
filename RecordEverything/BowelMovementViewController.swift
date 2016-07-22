//
//  BowelMovementViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 3/7/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift

struct RowData {
    
    let imageName:String
    let title:String
    
}

class BowelMovementViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var saveButton: UIBarButtonItem!
   
    var bsLabels = ["1 - Separate hard lumps",
                         "2 - Lumpy and sausage like",
                         "3 - A sausage shape w/ cracks",
                         "4 - Like a smooth, soft sausage",
                         "5 - Soft blobs w/ clear-cut edges",
                         "6 - Mushy consistency w/ ragged edges",
                         "7 - Liquid consistency w/ no solid pieces"
                        ]
    var bsPickerDataSource = [RowData]()
    var bsScale = 4
    
    @IBOutlet weak var bsPicker: UIPickerView!
    

    @IBOutlet weak var setDifferentTimeButton: UIButton!
    var date = Utils.roundDateToNearest10Min(NSDate()) {
        didSet {
            setDifferentTimeButton.setTitle(dateFormatter(date) + " >",forState: .Normal)
        }
    }

    @IBOutlet weak var durationPicker: UIDatePicker!
    
    var unsavedBMs = [BowelMovement]()
    var realm = try! Realm()
    
    init(type: String) {
        for (i,label) in bsLabels.enumerate() {
            bsPickerDataSource.append(RowData(imageName: "Type\(i+1)", title: label))
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        for (i,label) in bsLabels.enumerate() {
            bsPickerDataSource.append(RowData(imageName: "Type\(i+1)", title: label))
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bsPicker.delegate = self
        bsPicker.dataSource = self
        bsPicker.selectRow(3, inComponent: 0, animated: false)
        
        date = Utils.roundDateToNearest10Min(NSDate())
        
        //set duration to 5 minutes
        durationPicker.countDownDuration = 300
    }
    
    @IBAction func changeDate(sender: AnyObject) {
        let dateViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DateViewController") as? DateViewController
        dateViewController!.dateCallback = dateSetter
        Utils.presentViewControllerAnimatedOnMainThread(self, toPresent: dateViewController!)
    }
    func dateSetter(date:NSDate) {
        self.date = date
    }
    func dateFormatter(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        return formatter.stringFromDate(date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bsPickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return view.bounds.size.width
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let title = bsPickerDataSource[row].title
        
        return title
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bsScale = row+1
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let rowData = bsPickerDataSource[row]
        let customView = PickerRowViewWithImage(frame: CGRectZero, rowData: rowData)
        
        return customView
        
    }
    
    func clearBM(animated:Bool){
        bsScale = 4
        durationPicker.countDownDuration = 300
        bsPicker.selectRow(3, inComponent: 0, animated: animated)
        resetDate()
    }
    
    func resetDate() {
        date = Utils.roundDateToNearest10Min(NSDate())
    }
    
    func roundToNearestMin(seconds: Double) -> Int {
        return Int(round(seconds / 60))
    }
    
    @IBAction func save(sender: AnyObject) {
        let _date = Utils.roundDateToNearest10Min(self.date)
        let duration = roundToNearestMin(durationPicker.countDownDuration)
        let bm = BowelMovement(value: ["id": Utils.newUUID(), "bsScale": bsScale, "duration": duration, "date": _date])

        let bmsToSave = unsavedBMs + [bm]

        unsavedBMs = []
        clearBM(false)
        
        for (index,unsavedBM) in bmsToSave.enumerate(){
            print("saving bm:",unsavedBM.id)
            unsavedBM.saveToServer({
                (responseObject:NSDictionary?, error:NSError?) in
                if let _error = error {
                    if _error.code == 600 {
                        print("BM already exists")
                    } else {
                        print("unable to save bm (\(unsavedBM.bsScale),\(unsavedBM.date)) to server,",_error)
                        do {
                            let realm = try Realm()
                            try realm.write {
                                realm.add(unsavedBM)
                            }
                        } catch let error as NSError{
                            print("realm save error:",error)
                        }
                    }
                } else {
                    print(responseObject, error)
                    print("successfully saved to server")
                    if index < bmsToSave.count-1 {
                        do {
                            let realm = try Realm()
                            try realm.write {
                                realm.delete(unsavedBM)
                            }
                        } catch let error as NSError{
                            print("realm save error:",error)
                        }
                    }
                }
            })
        }
        self.performSegueWithIdentifier("UnwindRecordBowelMovement",sender:self)
    }
 


 



    func loadUnsavedBMsFromDisk(){
        unsavedBMs = []
        let unsavedBMsResult = realm.objects(BowelMovement)
        for bm in unsavedBMsResult {
            unsavedBMs.append(bm)
        }
    }

    func removeAllBMsFromDisk() {
        do {
            try realm.write {
                realm.delete(realm.objects(BowelMovement))
            }
        } catch let error as NSError{
            print("realm delete all error:",error)
        }
    }

}
