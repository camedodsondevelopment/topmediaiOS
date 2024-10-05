//
//  GeocodedWaypoints.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct GeocodedWaypoints {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kGeocodedWaypointsPlaceIdKey: String = "place_id"
  private let kGeocodedWaypointsGeocoderStatusKey: String = "geocoder_status"
  private let kGeocodedWaypointsTypesKey: String = "types"

  // MARK: Properties
  public var placeId: String?
  public var geocoderStatus: String?
  public var types: [String]?

  // MARK: SwiftyJSON Initalizers
  /**
   Initates the instance based on the object
   - parameter object: The object of either Dictionary or Array kind that was passed.
   - returns: An initalized instance of the class.
  */
  public init(object: Any) {
    self.init(json: JSON(object))
  }

  /**
   Initates the instance based on the JSON that was passed.
   - parameter json: JSON object from SwiftyJSON.
   - returns: An initalized instance of the class.
  */
  public init(json: JSON) {
    placeId = json[kGeocodedWaypointsPlaceIdKey].string
    geocoderStatus = json[kGeocodedWaypointsGeocoderStatusKey].string
    if let items = json[kGeocodedWaypointsTypesKey].array { types = items.map { $0.stringValue } }
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = placeId { dictionary[kGeocodedWaypointsPlaceIdKey] = value }
    if let value = geocoderStatus { dictionary[kGeocodedWaypointsGeocoderStatusKey] = value }
    if let value = types { dictionary[kGeocodedWaypointsTypesKey] = value }
    return dictionary
  }

}
