import Foundation
import MapKit

struct Address: Codable {
    let data: [Datum]
}

struct Datum: Codable {
    let latitude: Double
    let longitude: Double
    let name: String?
    let label: String? // "Detroit, Michigan, MI, USA" or "8917 Oakwood St, Detroit, Michigan, MI, USA"
    let region_code: String? // "MI"
    let number: String?
    let street: String?
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

class MapAPI: ObservableObject {
    public var city: String
    public var region_code: String
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "23282e20a70a87a53cc65a1a735ec8a1"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates = []
    @Published var locations: [Location] = []
    
    init() {
        self.city = "detroit"
        self.region_code = "mi"
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.360069, longitude: -83.163139), span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 42.360069, longitude: -83.163139)), at: 0)
    }
    
    func getLocation(address: String, delta: Double) {
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: url_string) else {
            // invalid URL
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                return
            }
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else { return }
            
            if newCoordinates.data.isEmpty {
                // Could not find address
                return
            }
            
            DispatchQueue.main.async {
                let details = newCoordinates.data[0]
                let latitude = details.latitude
                let longitude = details.longitude
                let name = details.name
                let label = details.label
                let number = details.number
                let street = details.street
                self.region_code = details.region_code!
                if (self.LocationIncludesStreet(label: label ?? " ", street: street ?? "_", number: number ?? "/"))
                {
                    self.city = (label?.components(separatedBy: ", ")[1])!
                }
                else
                {
                    self.city = (label?.components(separatedBy: ", ")[0])!
                }

                self.coordinates = [latitude, longitude]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                
                let new_location = Location(name: name ?? "Pin", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                
                self.locations.removeAll()
                self.locations.insert(new_location , at: 0)
            }
            
            
        }
        .resume()

    }

    func LocationIncludesStreet(label: String, street: String, number: String) -> Bool {
        return (label.components(separatedBy: ", ")[0] == (number + " " + street) ||
                label.components(separatedBy: ", ")[0] == street ||
                label.components(separatedBy: ", ")[0] == number )
    }
    
}
