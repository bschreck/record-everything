//
//  StomachPainViewController.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 3/7/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation

class StomachPainViewController: RatingViewController  {
    init() {
        super.init(type: "stomach_pain")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.type = "stomach_pain"
    }
    
    
    @IBAction override func save(sender: AnyObject) {
        super.save(sender)
        self.performSegueWithIdentifier("UnwindRecordStomachPain", sender: self)
    }
}