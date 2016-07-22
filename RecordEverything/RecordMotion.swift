//
//  RecordMotion.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 6/26/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
//Call functions periodically, maybe every 10 seconds, every 30 seconds, or every minute,
//which access deviceMotion data and others for maybe 1-5 seconds and record data in that interval every 0.1 seconds
//This is all saved to realm in the functions with longer intervals
//At even longer intervals, say periods of 5 minutes apart, save data to server


//Data to save: 
//deviceMotion from watch
//heart rate from watch
//