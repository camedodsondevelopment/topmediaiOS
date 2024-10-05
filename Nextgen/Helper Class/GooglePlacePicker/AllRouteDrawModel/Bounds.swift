//
//  Bounds.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Bounds {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kBoundsNortheastKey: String = "northeast"
  private let kBoundsSouthwestKey: String = "southwest"

  // MARK: Properties
  public var northeast: Northeast?
  public var southwest: Southwest?

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
    northeast = Northeast(json: json[kBoundsNortheastKey])
    southwest = Southwest(json: json[kBoundsSouthwestKey])
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = northeast { dictionary[kBoundsNortheastKey] = value.dictionaryRepresentation() }
    if let value = southwest { dictionary[kBoundsSouthwestKey] = value.dictionaryRepresentation() }
    return dictionary
  }

}
