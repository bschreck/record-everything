//
//  TirednessViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 6/25/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation

class TirednessViewController: RatingViewController  {
    init() {
        super.init(type: "tiredness")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.type = "tiredness"
    }
    
    
    @IBAction override func save(sender: AnyObject) {
        super.save(sender)
        self.performSegueWithIdentifier("UnwindRecordTiredness", sender: self)
    }
}