import CoreLocation
import Combine
import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var locationDescription: String = "Waiting for a fresh device location..."
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
            manager.startUpdatingLocation()
        }
    }

    var coordinate: (lat: Double, lon: Double) {
        guard let loc = lastLocation else { return (0, 0) }
        return (loc.coordinate.latitude, loc.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard location.timestamp.timeIntervalSinceNow > -120 else { return }
        guard location.horizontalAccuracy > 0, location.horizontalAccuracy <= 100 else { return }
        lastLocation = location

        Task {
            await self.updateLocationDescription(for: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            if self.lastLocation == nil {
                self.locationDescription = "Unable to read device location"
            }
        }
    }

    private func updateLocationDescription(for location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            await MainActor.run {
                self.locationDescription = coordinateString(for: location)
            }
            return
        }

        do {
            let mapItems = try await request.mapItems
            let placemark = mapItems.first?.placemark
            let parts = [placemark?.locality, placemark?.administrativeArea, placemark?.country].compactMap { $0 }

            await MainActor.run {
                self.locationDescription = parts.isEmpty ? self.coordinateString(for: location) : parts.joined(separator: ", ")
            }
        } catch {
            await MainActor.run {
                self.locationDescription = coordinateString(for: location)
            }
        }
    }

    private func coordinateString(for location: CLLocation) -> String {
        String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
    }
}
