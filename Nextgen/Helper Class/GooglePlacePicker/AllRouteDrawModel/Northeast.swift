//
//  Northeast.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Northeast {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kNortheastLatKey: String = "lat"
  private let kNortheastLngKey: String = "lng"

  // MARK: Properties
  public var lat: Float?
  public var lng: Float?

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
    lat = json[kNortheastLatKey].float
    lng = json[kNortheastLngKey].float
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = lat { dictionary[kNortheastLatKey] = value }
    if let value = lng { dictionary[kNortheastLngKey] = value }
    return dictionary
  }

}
