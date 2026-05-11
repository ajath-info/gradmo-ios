//
//  ZoomManager.swift
//  Gradmo
//
//  Created by Codex on 26/04/26.
//

import UIKit

#if canImport(MobileRTC)
import MobileRTC
#endif

final class ZoomManager: NSObject {
    static let shared = ZoomManager()
    private var sdkDidInitialize = false
    private var sdkDidAuthenticate = false

    private override init() {
        super.init()
    }

    func prepareSDKIfPossible() {
        #if canImport(MobileRTC)
        prepareEmbeddedSDKIfPossible()
        #endif
    }

    func openLiveClass(from presenter: UIViewController, joinURLString: String?) {
        let target = resolveJoinTarget(from: joinURLString)

        #if canImport(MobileRTC)
        if attemptEmbeddedJoin(from: presenter, target: target) {
            return
        }
        #endif

        openExternally(from: presenter, target: target)
    }
}

private extension ZoomManager {
    struct ZoomJoinTarget {
        let rawValue: String
        let joinURL: URL?
        let meetingNumber: String?
        let passcode: String?
        let displayName: String
    }

    func resolveJoinTarget(from joinURLString: String?) -> ZoomJoinTarget {
        let fallbackURLString = (Bundle.main.object(forInfoDictionaryKey: "ZoomTestJoinURL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedRawValue = sanitized(joinURLString) ?? sanitized(fallbackURLString) ?? "https://zoom.us/test"
        let joinURL = URL(string: resolvedRawValue)
        let parsedMeetingNumber = meetingNumber(from: resolvedRawValue, url: joinURL)
        let parsedPasscode = passcode(from: joinURL)

        return ZoomJoinTarget(
            rawValue: resolvedRawValue,
            joinURL: joinURL,
            meetingNumber: parsedMeetingNumber,
            passcode: parsedPasscode,
            displayName: resolvedDisplayName()
        )
    }

    func resolvedDisplayName() -> String {
        let fullName = UserCache.fullName().trimmingCharacters(in: .whitespacesAndNewlines)
        if !fullName.isEmpty {
            return fullName
        }

        switch UserCache.getUserRole() {
        case .teacher:
            return "Gradmo Teacher"
        case .student:
            return "Gradmo Student"
        case .institute:
            return "Gradmo Institute"
        }
    }

    func meetingNumber(from rawValue: String, url: URL?) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.allSatisfy(\.isNumber), !trimmed.isEmpty {
            return trimmed
        }

        if let pathComponents = url?.pathComponents {
            for (index, component) in pathComponents.enumerated() where component == "j" {
                let nextIndex = pathComponents.index(after: index)
                guard nextIndex < pathComponents.endIndex else { continue }

                let candidate = pathComponents[nextIndex]
                if candidate.allSatisfy(\.isNumber) {
                    return candidate
                }
            }
        }

        return nil
    }

    func passcode(from url: URL?) -> String? {
        guard let components = URLComponents(url: url ?? URL(fileURLWithPath: ""), resolvingAgainstBaseURL: false) else {
            return nil
        }

        return components.queryItems?.first(where: { item in
            let name = item.name.lowercased()
            return name == "pwd" || name == "passcode"
        })?.value
    }

    func sanitized(_ value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    func openExternally(from presenter: UIViewController, target: ZoomJoinTarget) {
        let application = UIApplication.shared

        if let joinURL = target.joinURL, application.canOpenURL(joinURL) {
            application.open(joinURL)
            return
        }

        if let meetingNumber = target.meetingNumber,
           let encodedName = target.displayName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let deepLink = URL(string: "zoomus://zoom.us/join?confno=\(meetingNumber)&uname=\(encodedName)"),
           application.canOpenURL(deepLink) {
            application.open(deepLink)
            return
        }

        presenter.showToastSafely("Unable to open live class")
    }
}

#if canImport(MobileRTC)
extension ZoomManager: MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate {
    private struct SDKConfiguration {
        let domain: String
        let jwtToken: String?
    }

    func attemptEmbeddedJoin(from presenter: UIViewController, target: ZoomJoinTarget) -> Bool {
        prepareEmbeddedSDKIfPossible()

        guard sdkDidInitialize else { return false }
        if let configuration = sdkConfiguration(),
           let jwtToken = configuration.jwtToken,
           !jwtToken.isEmpty,
           !sdkDidAuthenticate {
            return false
        }
        guard let meetingNumber = target.meetingNumber, !meetingNumber.isEmpty else { return false }
        guard let meetingService = MobileRTC.shared().getMeetingService() else { return false }

        meetingService.delegate = self

        let joinParameters = MobileRTCMeetingJoinParam()
        joinParameters.userName = target.displayName
        joinParameters.meetingNumber = meetingNumber
        joinParameters.password = target.passcode

        let joinError = meetingService.joinMeeting(with: joinParameters)
        if joinError == .success {
            return true
        }

        presenter.showToastSafely("Zoom SDK join failed: \(joinError.rawValue)")
        return false
    }

    func prepareEmbeddedSDKIfPossible() {
        guard !sdkDidInitialize else { return }
        guard let configuration = sdkConfiguration() else { return }

        let context = MobileRTCSDKInitContext()
        context.domain = configuration.domain
        context.enableLog = true

        guard MobileRTC.shared().initialize(context) else { return }

        sdkDidInitialize = true

        guard let jwtToken = configuration.jwtToken, !jwtToken.isEmpty else {
            sdkDidAuthenticate = true
            return
        }

        guard let authService = MobileRTC.shared().getAuthService() else { return }
        authService.delegate = self
        authService.jwtToken = jwtToken
        authService.sdkAuth()
    }

    func sdkConfiguration() -> SDKConfiguration? {
        let cachedDomain = UserCache.zoomSDKDomain().trimmingCharacters(in: .whitespacesAndNewlines)
        let cachedJWTToken = UserCache.zoomSDKJWTToken().trimmingCharacters(in: .whitespacesAndNewlines)
        let bundleDomain = (Bundle.main.object(forInfoDictionaryKey: "ZoomSDKDomain") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bundleJWTToken = (Bundle.main.object(forInfoDictionaryKey: "ZoomSDKJWTToken") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let domain = cachedDomain.isEmpty ? bundleDomain : cachedDomain
        let jwtToken = cachedJWTToken.isEmpty ? bundleJWTToken : cachedJWTToken

        guard !domain.isEmpty else { return nil }

        return SDKConfiguration(
            domain: domain,
            jwtToken: jwtToken.isEmpty ? nil : jwtToken
        )
    }

    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        sdkDidAuthenticate = (returnValue == .success)
        debugPrint("Zoom SDK auth result: \(returnValue.rawValue)")
    }

    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        debugPrint("Zoom meeting state changed: \(state.rawValue)")
    }
}
#endif
