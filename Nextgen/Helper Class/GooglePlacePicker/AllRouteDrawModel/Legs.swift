//
//  Legs.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Legs {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kLegsStartLocationKey: String = "start_location"
  private let kLegsEndAddressKey: String = "end_address"
  private let kLegsEndLocationKey: String = "end_location"
  private let kLegsStartAddressKey: String = "start_address"
  private let kLegsStepsKey: String = "steps"
  private let kLegsDistanceKey: String = "distance"
  private let kLegsTrafficSpeedEntryKey: String = "traffic_speed_entry"
  private let kLegsDurationKey: String = "duration"
  private let kLegsViaWaypointKey: String = "via_waypoint"

  // MARK: Properties
  public var startLocation: StartLocation?
  public var endAddress: String?
  public var endLocation: EndLocation?
  public var startAddress: String?
  public var steps: [Steps]?
  public var distance: Distance?
  public var trafficSpeedEntry: [Any]?
  public var duration: Duration?
  public var viaWaypoint: [Any]?

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
    startLocation = StartLocation(json: json[kLegsStartLocationKey])
    endAddress = json[kLegsEndAddressKey].string
    endLocation = EndLocation(json: json[kLegsEndLocationKey])
    startAddress = json[kLegsStartAddressKey].string
    if let items = json[kLegsStepsKey].array { steps = items.map { Steps(json: $0) } }
    distance = Distance(json: json[kLegsDistanceKey])
    if let items = json[kLegsTrafficSpeedEntryKey].array { trafficSpeedEntry = items.map { $0.object} }
    duration = Duration(json: json[kLegsDurationKey])
    if let items = json[kLegsViaWaypointKey].array { viaWaypoint = items.map { $0.object} }
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = startLocation { dictionary[kLegsStartLocationKey] = value.dictionaryRepresentation() }
    if let value = endAddress { dictionary[kLegsEndAddressKey] = value }
    if let value = endLocation { dictionary[kLegsEndLocationKey] = value.dictionaryRepresentation() }
    if let value = startAddress { dictionary[kLegsStartAddressKey] = value }
    if let value = steps { dictionary[kLegsStepsKey] = value.map { $0.dictionaryRepresentation() } }
    if let value = distance { dictionary[kLegsDistanceKey] = value.dictionaryRepresentation() }
    if let value = trafficSpeedEntry { dictionary[kLegsTrafficSpeedEntryKey] = value }
    if let value = duration { dictionary[kLegsDurationKey] = value.dictionaryRepresentation() }
    if let value = viaWaypoint { dictionary[kLegsViaWaypointKey] = value }
    return dictionary
  }

}
