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

struct Home: Hashable {
    let image: String
    let address: String
    let price: String
    let details: String // "3 Beds | 1 Bath | 900 Sqft"
}

class MapAPI: ObservableObject {
    
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "23282e20a70a87a53cc65a1a735ec8a1"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates = []
    @Published var locations: [Location] = []
    @Published private var city: String
    @Published private var region_code: String
    
    init(city: String, region_code: String) {
        self.city = city
        self.region_code = region_code
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.6389, longitude: 83.2910), span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)), at: 0)
        self.displayLocation(address: city) { () -> Void in
            updateSearchResults(city: self.city, region_code: self.region_code)
        }
    }
    
    
    func displayLocation(address: String, completion: @escaping () -> Void) {
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        let delta = 0.4
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
                
                if (self.searchQueryContainsStreet(label: label ?? " ", street: street ?? "_", number: number ?? "/"))
                {self.city = (label?.components(separatedBy: ", ")[1])!}
                else {self.city = (label?.components(separatedBy: ", ")[0])!}
                
                self.coordinates = [latitude, longitude]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                
                
                self.locations.removeAll()
                
                let searchResults = try! getSearchResults(city: self.city, region_code: self.region_code)
                
                let addressArray = searchResults.map({ (home: Home) -> String in
                    home.address
                })
                
                self.addPins(searchResults: addressArray)
                
                completion()
            }
          
          }.resume()
        
    }
    
    func addPins(searchResults: [String]) {
        for address in searchResults {
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
                                        
                    let location = Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    
                    self.locations.append(location)
                }
                
            }
            .resume()
        }
    }


    func searchQueryContainsStreet(label: String, street: String, number: String) -> Bool {
        return (label.components(separatedBy: ", ")[0] == (number + " " + street) ||
                label.components(separatedBy: ", ")[0] == street ||
                label.components(separatedBy: ", ")[0] == number )
    }
    
    func getCity() -> String {
        return self.city
    }
    
    func getRegion_Code() -> String {
        return self.region_code
    }
        
}
