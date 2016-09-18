//
//  GradientView.swift
//  SorryApp
//
//  Created by Arvindram Krishnamoorthy on 9/18/16.
//  Copyright © 2016 Arvindram Krishnamoorthy. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame);
        setupView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setupView();
    }
    
    private func setupView() {
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1);
        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1);
        
        theLayer.colors = [topColor.CGColor, bottomColor.CGColor];
        theLayer.locations = [0.0, 1.0];
        theLayer.frame = self.bounds;
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self;
    }

}
