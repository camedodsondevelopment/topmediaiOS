//
//  Steps.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Steps {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kStepsStartLocationKey: String = "start_location"
  private let kStepsPolylineKey: String = "polyline"
  private let kStepsEndLocationKey: String = "end_location"
  private let kStepsTravelModeKey: String = "travel_mode"
  private let kStepsDistanceKey: String = "distance"
  private let kStepsHtmlInstructionsKey: String = "html_instructions"
  private let kStepsManeuverKey: String = "maneuver"
  private let kStepsDurationKey: String = "duration"

  // MARK: Properties
  public var startLocation: StartLocation?
  public var polyline: Polyline?
  public var endLocation: EndLocation?
  public var travelMode: String?
  public var distance: Distance?
  public var htmlInstructions: String?
  public var maneuver: String?
  public var duration: Duration?

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
    startLocation = StartLocation(json: json[kStepsStartLocationKey])
    polyline = Polyline(json: json[kStepsPolylineKey])
    endLocation = EndLocation(json: json[kStepsEndLocationKey])
    travelMode = json[kStepsTravelModeKey].string
    distance = Distance(json: json[kStepsDistanceKey])
    htmlInstructions = json[kStepsHtmlInstructionsKey].string
    maneuver = json[kStepsManeuverKey].string
    duration = Duration(json: json[kStepsDurationKey])
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = startLocation { dictionary[kStepsStartLocationKey] = value.dictionaryRepresentation() }
    if let value = polyline { dictionary[kStepsPolylineKey] = value.dictionaryRepresentation() }
    if let value = endLocation { dictionary[kStepsEndLocationKey] = value.dictionaryRepresentation() }
    if let value = travelMode { dictionary[kStepsTravelModeKey] = value }
    if let value = distance { dictionary[kStepsDistanceKey] = value.dictionaryRepresentation() }
    if let value = htmlInstructions { dictionary[kStepsHtmlInstructionsKey] = value }
    if let value = maneuver { dictionary[kStepsManeuverKey] = value }
    if let value = duration { dictionary[kStepsDurationKey] = value.dictionaryRepresentation() }
    return dictionary
  }

}
