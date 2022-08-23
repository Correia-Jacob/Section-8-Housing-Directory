import Foundation
import SwiftSoup

struct Home: Hashable {
    let image: String
    let address: String
    let price: String
    let details: String // example: "3 Beds | 1 Bath | 900 Sqft"
}

private var searchResults = [Home]()

func getSearchResults(city: String, region_code: String) throws -> Array<Home>  {
let url = URL(string:"https://www.affordablehousing.com/\(city.lowercased())-\(region_code.lowercased())/")!
let html = try String(contentsOf: url)
let document = try SwiftSoup.parse(html)
var nextSearchResult = try document.select("div.tnresult--card").first()!

while (nextSearchResult.hasClass("tnresult--card")) {
    // image
    var image = ""
    let imgUrl = try nextSearchResult.getElementsByClass("tnresult--img").html().components(separatedBy: "\"")
    if (imgUrl.count > 1) {
        image = imgUrl[1]
    }
    // address
    var address = ""
    address = try nextSearchResult.getElementsByClass("tnresult--propertyaddress").text()
    // price
    var price = ""
    price = try nextSearchResult.getElementsByClass("tnresult--price").text()
    // details
    var details = ""
    details = try nextSearchResult.getElementsByClass("tnresult--bedbath").text()
    
    if (!address.isEmpty){
    searchResults.append(Home(image: image, address: address, price: price, details: details))
    }
    
    nextSearchResult = try nextSearchResult.nextElementSibling()!
     }
    return searchResults
}
