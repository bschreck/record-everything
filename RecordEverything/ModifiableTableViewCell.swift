//
//  TableViewCell.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 2/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import UIKit

class ModifiableTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    var listItem:ListItem? {
        didSet {
            textField.text = listItem!.text
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        if listItem != nil {
            listItem?.text = textField.text!
        }
        return true
    }

}
