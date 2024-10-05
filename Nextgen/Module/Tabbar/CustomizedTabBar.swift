//
//  CustomizedTabBar.swift
//  CurvedTabbar
//
//  Created by Gagan  Vishal on 3/25/21.
//

import UIKit

@IBDesignable
class CustomizedTabBar: UITabBar {
    private var shapeLayer: CALayer?
    @objc private func addShape() {
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        if modeKey == "DARK"{
            shapeLayer.fillColor = UIColor.black.cgColor
        }else{
            shapeLayer.fillColor = UIColor.white.cgColor
        }

        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.lightGray.cgColor
        shapeLayer.shadowOpacity = 0.3

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
        NotificationCenter.default.addObserver(self, selector: #selector(addShape), name: Notification.Name("HandleDarkMode"), object: nil)
    }
    
    
    func createPath() -> CGPath {
        let height: CGFloat = 38.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - height - 5), y: 0))

        path.addCurve(to: CGPoint(x: centerWidth, y: height),
        controlPoint1: CGPoint(x: (centerWidth - 38), y: 0), controlPoint2: CGPoint(x: centerWidth - 38, y: height))

        path.addCurve(to: CGPoint(x: (centerWidth + height + 5), y: 0),
        controlPoint1: CGPoint(x: centerWidth + 38, y: height), controlPoint2: CGPoint(x: (centerWidth + 38), y: 0))

        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        return path.cgPath
    }

    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
            for member in subviews.reversed() {
                let subPoint = member.convert(point, from: self)
                guard let result = member.hitTest(subPoint, with: event) else { continue }
                return result
            }
            return nil
        }
}
