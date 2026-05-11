//
//  AppDelegate.swift
//  Gradmo
//
//  Created by Philanderer on 14/03/26.
//

import CoreLocation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let locationCaptureManager = LaunchLocationCaptureManager()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationCaptureManager.start()
        UserCache.printSavedDefaults()
        AppDefaultsService.refreshIfAuthenticated()
        ZoomManager.shared.prepareSDKIfPossible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

private final class LaunchLocationCaptureManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var hasRequestedLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func start() {
        UserCache.saveCoordinates(latitude: nil, longitude: nil)

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocationIfNeeded()
        case .restricted, .denied:
            UserCache.printSavedDefaults()
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocationIfNeeded()
        case .restricted, .denied:
            UserCache.printSavedDefaults()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        UserCache.saveCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        UserCache.printSavedDefaults()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Location capture failed: \(error.localizedDescription)")
    }

    private func requestLocationIfNeeded() {
        guard !hasRequestedLocation else { return }
        hasRequestedLocation = true
        locationManager.requestLocation()
    }
}
