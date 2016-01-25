//
//  CookingMethodViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 1/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
class CookingMethodViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {

    var cookingMethodPickerDataSource = ["Bake","Roast","Broil","Grill","Microwave","Raw","Stir-Fry","Fry","Saute","Boil","Simmer"]
    
    @IBOutlet weak var cookingMethodPicker: UIPickerView!
    var cookingMethod = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cookingMethodPicker.delegate = self
        cookingMethodPicker.dataSource = self
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cookingMethodPickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cookingMethodPickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cookingMethod = cookingMethodPickerDataSource[row]
    }
}