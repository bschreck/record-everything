//
//  PickerRowViewWithImage.swift
//  RecordEverything
//
//  Created by Benjamin Schreck on 3/7/16.
//  Copyright © 2016 Benjamin Schreck. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class PickerRowViewWithImage: UIView {
    
    // MARK: - IBOutlets
    
    // MARK: - Properties
    let rowData:RowData
    
    var imageView:UIImageView!
    var label:UILabel!
    
    var didSetupConstraints:Bool = false
    
    // MARK: - Initializers methods
    init(frame: CGRect, rowData:RowData) {
        
        self.rowData = rowData
        
        super.init(frame: frame)
        

        createImageView()
        createLabel()
        
        //label.autoCenterInSuperview()
        label.autoConstrainAttribute(.Horizontal, toAttribute: .Horizontal, ofView: self)
        label.autoPinEdge(.Leading, toEdge: .Trailing, ofView: imageView, withOffset: 10)
        
        imageView.autoConstrainAttribute(.Horizontal, toAttribute: .Horizontal, ofView: self)
        imageView.autoPinEdgeToSuperviewEdge(.Leading)
        //imageView.autoPinEdge(.Leading, toEdge: .Leading, ofView: label, withOffset: -10)
        //imageView.autoCenterInSuperview()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    // MARK: - Private methods
    private func createImageView(){
        
        imageView = UIImageView.newAutoLayoutView()
        imageView.image = UIImage(named: rowData.imageName)
        addSubview(imageView)
        
    }
    
    private func createLabel(){
        
        label = UILabel.newAutoLayoutView()
//        label.numberOfLines = 0
//        label.lineBreakMode = UILineBreakModeWordWrap
        label.text = rowData.title
        label.font = label.font.fontWithSize(12)
        addSubview(label)
        
    }
    
    // MARK: - Public methods
    
    // MARK: - Getter & setter methods
    
    // MARK: - IBActions
    
    // MARK: - Target-Action methods
    
    // MARK: - Notification handler methods
    
    // MARK: - Datasource methods
    
    // MARK: - Delegate methods
    
}