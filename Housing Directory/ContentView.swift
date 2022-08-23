import SwiftUI
import MapKit
import Foundation
import SwiftSoup


struct ContentView: View {
    @StateObject private var mapAPI = MapAPI(city: "detroit", region_code: "mi")
    @State private var searchResults = try! getSearchResults(city: "detroit", region_code: "mi")
    @State private var text = ""
    
    var body: some View {
        NavigationView {
        VStack {
            HStack {
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $text)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .onSubmit {
                                    mapAPI.getLocation(address: text, delta: 0.5)
                                    searchResults = try! getSearchResults(city: mapAPI.getCity(), region_code: mapAPI.getRegion_Code())
                                }
                                .frame(width: 340, height: 40, alignment: .top)
                Image(systemName: "text.justify")
                    .frame(width: 40, height: 20, alignment: .topLeading)
            }
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) {
                    location in
                    MapMarker(coordinate: location.coordinate, tint: .gray)
                }
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .frame(height: 40)
                
                Color("GrayBoxColor")
                    .frame(width: 345, height: 33)
                    .cornerRadius(8)
                                        
                HStack(spacing: 3) {
                    ZStack {
                        ZStack {
                            Color("Color")
                                .frame(width: 76, height: 25)
                                .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                            
                            Color("White")
                                .frame(width: 74, height: 23)
                                .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                        }
                        Menu {
                            
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "dollarsign.circle")
                                Text("$1500+")
                              }
                            }
                            Button(action:{}) {
                                HStack {
                                    Image(systemName: "dollarsign.circle")
                                    Text("$1000 - $1500")
                                }
                                }
                            Button(action:{}) {
                                HStack {
                                Image(systemName: "dollarsign.circle")
                                Text("$500 - $1000")
                                }
                            }
                          Button(action:{}){
                            HStack {
                              Image(systemName: "dollarsign.circle")
                              Text("$0 - $500")
                            }
                          }
                        } label: {
                            Text("Price")
                                .foregroundColor(Color.black)
                        }
                    }
                    ZStack {
                        Color("White")
                            .frame(width: 75, height: 25)
                            .border(Color("Color"), width: 1)

                        Menu {
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "bed.double.circle")
                                Text("4+ Bedrooms")
                              }
                            }
                            Button(action:{}) {
                                HStack {
                                  Image(systemName: "bed.double.circle")
                                  Text("3 Bedrooms")
                                }
                              }
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "bed.double.circle")
                                Text("2 Bedrooms")
                              }
                            }
                            Button(action:{}){
                              HStack {
                                Image(systemName: "bed.double.circle")
                                Text("1 Bedroom")
                              }
                            }
                        } label: {
                            Text("Beds")
                                .foregroundColor(Color.black)
                        }
                    }
                    ZStack {
                        Color("White")
                            .frame(width: 75, height: 25)
                            .border(Color("Color"), width: 1)
                        
                        Menu {
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "drop.circle")
                                Text("4+ Baths")
                              }
                            }
                            
                            Button(action:{}) {
                                HStack {
                                  Image(systemName: "drop.circle")
                                  Text("3 Baths")
                                }
                              }
                            
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "drop.circle")
                                Text("2 Baths")
                              }
                            }
                            
                            Button(action:{}){
                              HStack {
                                Image(systemName: "drop.circle")
                                Text("1 Bath")
                              }
                            }
                            
                        } label: {
                            Text("Baths")
                                .foregroundColor(Color.black)
                        }
                    }
                    ZStack {
                        ZStack {
                            Color("Color")
                                .frame(width: 102, height: 25)
                                .cornerRadius(5, corners: [.topRight, .bottomRight])
                            
                            Color("White")
                                .frame(width: 100, height: 23)
                                .cornerRadius(5, corners: [.topRight, .bottomRight])

                        }
                        Menu {
                                Button(action:{}) {
                                  HStack {
                                    Image(systemName: "person.3.fill")
                                    Text("Senior Community")
                                  }
                                }
                            Button(action:{}) {
                              HStack {
                                Image(systemName: "hearingdevice.ear")
                                Text("Visual/Hearing (Smoke alarms, ADA Appliances)")
                              }
                            }
                            Button(action:{}){
                              HStack {
                                Image(systemName: "figure.roll")
                                Text("Physical (Ramps, Lifts, Grabbars)")
                              }
                            }
                            } label: {
                                Text("Accessibility")
                                    .foregroundColor(Color.black)
                            }
                    }
                    
                    }
                        .foregroundColor(.black)
                        
               

                }
                
            
            List {
                Section {
                  ForEach(searchResults, id: \.self) { result in
                      NavigationLink(destination: resultView(address: result.address, price: result.price, details: result.details, imageUrl: result.image)) {
                          Text(result.address)
                          }
                      }
                } header: {
                    Text("Search Results")
                }
            } .frame(height: 140)
              .navigationBarTitle("Search Results")
              .navigationBarHidden(true)
              .navigationBarBackButtonHidden(true)
          }
        }
    }
}

struct resultView: View {
    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var message: String = ""

    let address: String
    let price: String
    let details: String
    var imageUrl: String

    var body: some View {
        VStack {
            Text(address)
                .font(.system(size: 23))
                .frame(alignment: .topLeading)
            AsyncImage(
                url: URL(string: imageUrl),
                content: { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 400, height: 350)
                },
                placeholder: {
                    ProgressView()
                }
            )
            Text(details)
                .font(.system(size: 25))
            Text("Rent: \(price) per month")
                .font(.system(size: 20))
            Group {
                HStack {
                    Text("Name:")
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300, height: 25, alignment: .topLeading)
                }
                HStack {
                    Text("Phone/Email:")
                    TextField("", text: $contact)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 280, height: 25, alignment: .topLeading)
                }
                HStack {
                    Text("Notes:")
                    TextField("", text: $message)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300, height: 25)
                }
            
                Button {} label: {
                    Text("Contact Agent")
                        .padding(10)
                }
                .contentShape(Rectangle())
                .foregroundColor(Color.white)
                .background(Color.blue)
                .cornerRadius(8)
                .frame(width: 350, alignment: .topTrailing)
            }
            
        }
         .navigationBarTitle("")
         .navigationBarHidden(false)
         .navigationBarBackButtonHidden(false)
            
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))

    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
