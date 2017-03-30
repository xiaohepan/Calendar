//
//  RoundBackgroundLabel.swift
//  seasonview
//
//  Created by panxiaohe on 16/4/13.
//  Copyright © 2016年 panxiaohe. All rights reserved.
//

import UIKit

class RoundBackgroundLabel: UILabel {
    
    var backRoundColor: UIColor = UIColor.lightGray
    var roundType:RoundType = .single
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        switch roundType {
        case .single:
            context?.addEllipse(in: rect)
            backRoundColor.set()
            context?.drawPath(using: CGPathDrawingMode.fill)
        case .middle:
            context?.addRect(rect)
            backRoundColor.set()
            context?.drawPath(using: CGPathDrawingMode.fill)
        case .start:
            context?.addArc(center: CGPoint(x:rect.width/2,y:rect.height/2), radius: rect.width/2, startAngle: .pi/2, endAngle: .pi/2*3, clockwise: false)
           
            context?.addRect(CGRect(x: rect.width/2, y: 0, width: rect.width/2, height: rect.height))
            backRoundColor.set()
            context?.drawPath(using: CGPathDrawingMode.fillStroke)
        case.end:
            context?.addArc(center: CGPoint(x:rect.width/2,y:rect.height/2), radius: rect.width/2, startAngle: -.pi/2, endAngle: .pi/2, clockwise: false)
            context?.addRect(CGRect(x: 0, y: 0, width: rect.width/2, height: rect.height))
            backRoundColor.set()
            context?.drawPath(using: CGPathDrawingMode.fill)
        case .none:
            break
        }
        super.draw(rect)
    }
    
    
}
public enum RoundType {
    case single,start,middle,end,none
}
