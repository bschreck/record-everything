//
//  TableViewCell.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 2/22/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import UIKit

class CookingMethodTableViewCell: UITableViewCell {
    
    
    weak var tableView: ModifyCookingMethodsTableViewController? = nil
    var callback: ((text: String)-> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func modifyCookingMethod(sender: AnyObject) {
        let VC1 = self.tableView!.storyboard!.instantiateViewControllerWithIdentifier("SelectCookingMethod") as! CookingMethodViewController
        VC1.callback = callback
        self.tableView!.presentViewController(VC1, animated:true, completion: nil)
    }
}

class ModifyCookingMethodTableViewCell: CookingMethodTableViewCell {
    @IBOutlet weak var textLabelNew: UILabel!
}

class AddCookingMethodTableViewCell: CookingMethodTableViewCell {
    @IBOutlet weak var addButton: UIButton!
}