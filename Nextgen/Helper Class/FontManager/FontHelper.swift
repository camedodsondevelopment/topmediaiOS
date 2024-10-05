import Foundation
import UIKit
// Usage Examples
let TitilliumSemiBoldS16   = Font(.installed(.TitilliumSemibold), size: .standard(.S16)).instance
let TitilliumSemiBoldS22   = Font(.installed(.TitilliumSemibold), size: .standard(.S22)).instance

//let TitilliumMedium16   = Font(.installed(.TitilliumMedium), size: .standard(.S16)).instance
//let TitilliumMedium20   = Font(.installed(.TitilliumMedium), size: .standard(.S20)).instance
let TitilliumSemiBoldS18   = Font(.installed(.TitilliumSemibold), size: .standard(.S18)).instance
let TitilliumRegularS10   = Font(.installed(.TitilliumBlack), size: .standard(.S10)).instance
let TitilliumRegularS11  = Font(.installed(.TitilliumBlack), size: .standard(.S11)).instance
let TitilliumRegularS12   = Font(.installed(.TitilliumBlack), size: .standard(.S12)).instance
let TitilliumRegularS13   = Font(.installed(.TitilliumBlack), size: .standard(.S13)).instance
let TitilliumRegularS16   = Font(.installed(.TitilliumRegular), size: .standard(.S16)).instance
let TitilliumLightS16   = Font(.installed(.TitilliumLight), size: .standard(.S16)).instance
let PoppinsRegular16    =   Font(.installed(.PoppinRegular), size: .standard(.S16)).instance
let PoppinsRegular18    =   Font(.installed(.PoppinRegular), size: .standard(.S18)).instance
let PoppinsRegular20    =   Font(.installed(.PoppinRegular), size: .standard(.S20)).instance
let PoppinsRegular22    =   Font(.installed(.PoppinRegular), size: .standard(.S22)).instance

struct Font {
    
    enum FontName: String {
 
        case TitilliumRegular = "Titillium-Regular"
        case TitilliumRegularUpright = "Titillium-RegularUpright"
        case TitilliumRegularItalic = "Titillium-RegularItalic"
        case TitilliumThin = "Titillium-Thin"
        case TitilliumThinUpright = "Titillium-ThinUpright"
        case TitilliumThinItalic = "Titillium-ThinItalic"
        case TitilliumLight = "Titillium-Light"
        case TitilliumLightUpright = "Titillium-LightUpright"
        case TitilliumLightItalic = "Titillium-LightItalic"
        case TitilliumSemibold = "Titillium-Semibold"
        case TitilliumSemiboldUpright = "Titillium-SemiboldUpright"
        case TitilliumSemiboldItalic = "Titillium-SemiboldItalic"
        case TitilliumBold = "Titillium-Bold"
        case TitilliumBoldUpright = "Titillium-BoldUpright"
        case TitilliumBoldItalic = "Titillium-BoldItalic"
        case TitilliumBlack = "Titillium-Black"
        case PoppinRegular = "poppins.regular"
        case PoppinsMedium = "poppins.medium"
        case PoppinsSemibold = "poppins.semibold"
        
    }
    
    enum FontType {
        case installed(FontName)
        case custom(String)
        case system
        case systemBold
        case systemItatic
        case systemWeighted(weight: Double)
        case monoSpacedDigit(size: Double, weight: Double)
    }
    
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let StandardSize):
                return StandardSize.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    
    enum StandardSize: Double {
        case S10 = 10.0
        case S11 = 11.0
        case S12 = 12.0
        case S13 = 13.0
        case S14 = 14.0
        case S15 = 15.0
        case S16 = 16.0
        case S17 = 17.0
        case S18 = 18.0
        case S19 = 19.0
        case S20 = 20.0
        case S21 = 21.0
        case S22 = 22.0
        case S23 = 23.0
    }
    
    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension Font {
    
    var instance: UIFont {
        
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .system:
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value))
        case .systemBold:
            instanceFont = UIFont.boldSystemFont(ofSize: CGFloat(size.value))
        case .systemItatic:
            instanceFont = UIFont.italicSystemFont(ofSize: CGFloat(size.value))
        case .systemWeighted(let weight):
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value),
                                             weight: UIFont.Weight(rawValue: CGFloat(weight)))
        case .monoSpacedDigit(let size, let weight):
            instanceFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size),
                                                            weight: UIFont.Weight(rawValue: CGFloat(weight)))
        }
        return instanceFont
    }
}

class Utility {
    /// Logs all available fonts from iOS SDK and installed custom font
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}

func fontInProject() {
    for family in UIFont.familyNames {
        print("\(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            print("   \(name)")
        }
    }
}

