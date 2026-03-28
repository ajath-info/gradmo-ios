//
//  Constants.swift
//  Motivaid
//
//  Created by Yogyata on 14/07/25.
//

import Foundation
import UIKit

// MARK: - Screen Dimensions and Factors
let screen_height = UIScreen.main.bounds.size.height
let screen_width = UIScreen.main.bounds.size.width
let screenHeightFactor = UIScreen.main.bounds.height / 568
let screenWidthFactor = UIScreen.main.bounds.width / 320

let deviceModel = UIDevice.current.model
let appVersion = Bundle.main.appVersion
let deviceOSversion = UIDevice.current.systemVersion

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    public var appBuildNo: String { getInfo("CFBundleVersion") }
    public var appVersion: String { getInfo("CFBundleShortVersionString") }
    //public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
    //Text("Ver: \(Bundle.main.appVersionLong) (\(Bundle.main.appVersion)) ")
}

