//
//  Routes.swift
//
//  Created by Mac 3 on 28/01/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Routes {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kRoutesSummaryKey: String = "summary"
  private let kRoutesCopyrightsKey: String = "copyrights"
  private let kRoutesOverviewPolylineKey: String = "overview_polyline"
  private let kRoutesBoundsKey: String = "bounds"
  private let kRoutesWaypointOrderKey: String = "waypoint_order"
  private let kRoutesWarningsKey: String = "warnings"
  private let kRoutesLegsKey: String = "legs"

  // MARK: Properties
  public var summary: String?
  public var copyrights: String?
  public var overviewPolyline: OverviewPolyline?
  public var bounds: Bounds?
  public var waypointOrder: [Any]?
  public var warnings: [Any]?
  public var legs: [Legs]?

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
    summary = json[kRoutesSummaryKey].string
    copyrights = json[kRoutesCopyrightsKey].string
    overviewPolyline = OverviewPolyline(json: json[kRoutesOverviewPolylineKey])
    bounds = Bounds(json: json[kRoutesBoundsKey])
    if let items = json[kRoutesWaypointOrderKey].array { waypointOrder = items.map { $0.object} }
    if let items = json[kRoutesWarningsKey].array { warnings = items.map { $0.object} }
    if let items = json[kRoutesLegsKey].array { legs = items.map { Legs(json: $0) } }
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = summary { dictionary[kRoutesSummaryKey] = value }
    if let value = copyrights { dictionary[kRoutesCopyrightsKey] = value }
    if let value = overviewPolyline { dictionary[kRoutesOverviewPolylineKey] = value.dictionaryRepresentation() }
    if let value = bounds { dictionary[kRoutesBoundsKey] = value.dictionaryRepresentation() }
    if let value = waypointOrder { dictionary[kRoutesWaypointOrderKey] = value }
    if let value = warnings { dictionary[kRoutesWarningsKey] = value }
    if let value = legs { dictionary[kRoutesLegsKey] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

}
