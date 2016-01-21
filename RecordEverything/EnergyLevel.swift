//
//  EnergyLevel.swift
//  FoodTracker
//
//  Created by Benjamin Schreck on 1/10/16.
//
//

import Foundation

class EnergyLevelViewController: RatingViewController  {
    init() {
        super.init(type: "energy_level")
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.type = "energy_level"
    }
    
    
    @IBAction override func save(sender: AnyObject) {
        super.save(sender)
        self.performSegueWithIdentifier("unwindRecordEnergyLevel", sender: self)
    }
}