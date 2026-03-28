//
//  UiFontFile.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit

let IS_IPAD = (UI_USER_INTERFACE_IDIOM() == .pad)
let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == .phone)
let IS_RETINA = (UIScreen.main.scale >= 2.0)
let SCREEN_WIDTH = (UIScreen.main.bounds.size.width)
let SCREEN_HEIGHT = (UIScreen.main.bounds.size.height)
let SCREEN_MAX_LENGTH = (max(SCREEN_WIDTH, SCREEN_HEIGHT))
let SCREEN_MIN_LENGTH = (min(SCREEN_WIDTH, SCREEN_HEIGHT))

let IS_IPAD_PRO_1366 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1366.0)
let IS_IPAD_PRO_1112 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1112.0)
let IS_IPAD_PRO_1024 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1024.0)

let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5         = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6         = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6P         = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
let IS_IPHONE_X         = (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
let IS_IPHONE_XSMax     = (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
let IS_IPAD_PRO_1180 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1180.0)
let IS_IPAD_PRO_1080 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1080.0)
let IS_IPAD_PRO_1194 = (IS_IPAD && max(SCREEN_WIDTH,SCREEN_HEIGHT) == 1194.0)
let IS_IPHONE_11Pro         = (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
let IS_IPHONE_11ProMax     = (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)
let IS_IPHONE_12   = (IS_IPHONE && SCREEN_MAX_LENGTH == 844.0)
let IS_IPHONE_12Pro  = (IS_IPHONE && SCREEN_MAX_LENGTH == 844.0)
let IS_IPHONE_12ProMax   = (IS_IPHONE && SCREEN_MAX_LENGTH == 926.0)
let IS_IPHONE_15ProMax   = (IS_IPHONE && SCREEN_MAX_LENGTH == 932.0)
let IS_IPHONE_11    = (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)


private func calculateSize(enter size : CGFloat) -> CGFloat {
    var sizeOfFont : CGFloat?
    
    if IS_IPHONE_4_OR_LESS {
        sizeOfFont = size - 2.0
    }
    if IS_IPHONE_5 {
        sizeOfFont = size + 1.0
    }
    if IS_IPHONE_6 {
        sizeOfFont = size + 3.0
    }
    if IS_IPHONE_6P {
        sizeOfFont = size + 3.0
    }
    if IS_IPHONE_11Pro ||  IS_IPHONE_X {
        sizeOfFont = size + 3.0
    }
    if IS_IPHONE_11ProMax || IS_IPHONE_11 || IS_IPHONE_15ProMax{
        sizeOfFont = size + 4.0
    }
        
    if IS_IPAD_PRO_1024{
        sizeOfFont = size + 12.0;
    }else if (IS_IPAD_PRO_1112){
        sizeOfFont = size + 10.0;
    }else if (IS_IPAD_PRO_1366){
        sizeOfFont = size + 20.0;
    }
    
    if IS_IPHONE, sizeOfFont == nil{
         sizeOfFont = size + 4.0
    }
    if IS_IPAD, sizeOfFont == nil{
         sizeOfFont = size + 10.0
    }
    return sizeOfFont!
}


extension UIFont {
    class func fontWithSize(size: CGFloat) -> CGFloat{
       return calculateSize(enter: size)
    }

    class func GilroyBlack(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Black", size: fontWithSize(size: size))!
    }
    class func GilroyBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Bold", size: fontWithSize(size: size))!
    }
    class func GilroyExtraBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-ExtraBold", size: fontWithSize(size: size))!
    }
    class func GilroyHeavy(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Heavy", size: fontWithSize(size: size))!
    }
    class func GilroyLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Light", size: fontWithSize(size: size))!
    }
    class func GilroyMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Medium", size: fontWithSize(size: size))!
    }
    class func GilroyRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Regular", size: fontWithSize(size: size))!
    }
    class func GilroySemiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-SemiBold", size: fontWithSize(size: size))!
    }
    class func GilroyThin(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-Thin", size: fontWithSize(size: size))!
    }
    class func GilroyUltraLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Gilroy-UltraLight", size: fontWithSize(size: size))!
    }
}
