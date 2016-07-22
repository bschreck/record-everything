//
//  AddTextTableVieCell.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 2/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import UIKit

class AddTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var callback: ((text: String)-> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.hidden = true
        textField.delegate = self
        
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        addButton.hidden = false
        textField.hidden = true
        callback!(text: textField.text!)
        textField.text = ""

        return true
    }
    
    @IBAction func addText(sender: AnyObject) {
        addButton!.hidden = true
        textField.hidden = false
        textField.becomeFirstResponder()
    }

}
