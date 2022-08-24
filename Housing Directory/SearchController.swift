import Foundation
import SwiftSoup
import UIKit

func getSearchResults(city: String, region_code: String) throws -> Array<Home>  {
  var searchResults = [Home]()
  let pCity = city.replacingOccurrences(of: " ", with: "-")
  let url = URL(string:"https://www.affordablehousing.com/\(pCity.lowercased())-\(region_code.lowercased())/")!
  let html = try String(contentsOf: url)
  let document = try SwiftSoup.parse(html)

    guard var nextSearchResult = try document.select("div.tnresult--card").first() else {
        // No homes available
        return []
    }

  while (nextSearchResult.hasClass("tnresult--card")) {

      var image = ""
      let imgUrl = try nextSearchResult.getElementsByClass("tnresult--img").html().components(separatedBy: "\"")
      if (imgUrl.count > 1) {
          image = imgUrl[1]
      }

      var address = ""
      address = try nextSearchResult.getElementsByClass("tnresult--propertyaddress").text()

      var price = ""
      price = try nextSearchResult.getElementsByClass("tnresult--price").text()

      var details = ""
      details = try nextSearchResult.getElementsByClass("tnresult--bedbath").text()
    
      if (!address.isEmpty) {
      searchResults.append(Home(image: image, address: address, price: price, details: details))
      }
    
      nextSearchResult = try nextSearchResult.nextElementSibling()!
    
  }
    return searchResults
    
}
