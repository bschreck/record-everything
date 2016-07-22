//
//  SicknessViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 6/20/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation

class SicknessViewController: RatingViewController  {
    init() {
        super.init(type: "sickness")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.type = "sickness"
    }
    
    
    @IBAction override func save(sender: AnyObject) {
        super.save(sender)
        self.performSegueWithIdentifier("UnwindRecordSickness", sender: self)
    }
}