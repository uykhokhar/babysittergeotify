
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation

struct GeoKey {
  static let latitude = "latitude"
  static let longitude = "longitude"
  static let radius = "radius"
  static let identifier = "identifier"
  static let babySitterName = "babySitterName"
  static let eventType = "eventType"
  static let rate = "rate"
}

enum EventType: String {
  case onEntry = "On Entry"
  case onExit = "On Exit"
}

class Geotification: NSObject, NSCoding, MKAnnotation {
  
  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var babySitterName: String
  var eventType: EventType
  var rate: Double
  
  var title: String? {
    if babySitterName.isEmpty {
      return "No babySitterName"
    }
    return babySitterName
  }
  
  var subtitle: String? {
    let eventTypeString = eventType.rawValue
    return "Radius: \(radius)m - \(eventTypeString)"
  }
  
  init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, babySitterName: String, eventType: EventType, rate: Double) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.babySitterName = babySitterName
    self.eventType = eventType
    self.rate = rate
  }
  
  // MARK: NSCoding
  required init?(coder decoder: NSCoder) {
    let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
    let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDouble(forKey: GeoKey.radius)
    identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
    babySitterName = decoder.decodeObject(forKey: GeoKey.babySitterName) as! String
    eventType = EventType(rawValue: decoder.decodeObject(forKey: GeoKey.eventType) as! String)!
    rate = decoder.decodeDouble(forKey: GeoKey.rate)
  }
  
  func encode(with coder: NSCoder) {
    coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
    coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
    coder.encode(radius, forKey: GeoKey.radius)
    coder.encode(identifier, forKey: GeoKey.identifier)
    coder.encode(babySitterName, forKey: GeoKey.babySitterName)
    coder.encode(eventType.rawValue, forKey: GeoKey.eventType)
    coder.encode(rate, forKey: GeoKey.rate)
  }
  
}
