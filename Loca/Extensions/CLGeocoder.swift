//
//  CoreLocation.swift
//  Tacks
//
//  Created by Ian Dundas on 07/09/2015.
//  Copyright © 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveKit

public let GeocoderTimeoutError =  NSError(domain: "tacks", code: 0, userInfo: [NSLocalizedDescriptionKey : "Timed out whilst geocoding"])

public extension CLGeocoder {
    
    
//    let a = placemark.name; // eg. Apple Inc.
//    let b = placemark.thoroughfare; // street name, eg. Infinite Loop
//    let c = placemark.subThoroughfare; // eg. 1
//    let d = placemark.locality; // city, eg. Cupertino
//    let e = placemark.subLocality; // neighborhood, common name, eg. Mission District
//    let f = placemark.administrativeArea; // state, eg. CA
//    let g = placemark.subAdministrativeArea; // county, eg. Santa Clara
//    let h = placemark.postalCode; // zip code, eg. 95014
//    let i = placemark.ISOcountryCode; // eg. US
//    let j = placemark.country; // eg. United States
//    let k = placemark.inlandWater; // eg. Lake Tahoe
//    let l = placemark.ocean; // eg. Pacific Ocean
//    
//    let m = placemark.addressDictionary
//    let x = m!["FormattedAddressLines"]
//    let n = placemark.areasOfInterest

    
    public static func geocodeStreetnameOperation(location: CLLocation) -> Signal<String?, NSError>{
        return CLGeocoder.reverseGeocodeOperation(location: location)
            .first()
            .map {$0.first}.ignoreNil()
            .map { placemark -> String? in
                let best = [placemark.subThoroughfare, placemark.thoroughfare].flatMap{$0}
                if best.count > 0 {
                    return best.joined(separator: " ")
                }
                else {
                    return placemark.name
                }
        }
    }
    
    public static func geocodeShortAddressOperation(location: CLLocation) -> Signal<String?, NSError>{
        return CLGeocoder.reverseGeocodeOperation(location: location).first()
            .map {$0.first}.ignoreNil()
            .map { placemark -> String? in
                let best = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality]
                    .flatMap{$0}
                    
                if best.count > 0 {
                    return best.joined(separator: " ")
                }
                else{
                    return placemark.name
                }
        }
    }
    
    public static func reverseGeocodeOperation(location: CLLocation) -> Signal<Array<CLPlacemark>, NSError>{
        return Signal { observer in
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error{
                    observer.failed(error as NSError)
                }
                else{
                    observer.next(placemarks ?? [])
                    observer.completed()
                }
            }
            
            return BlockDisposable {
                geocoder.cancelGeocode()
            }
            }
            .executeIn(LocaQueue.context)
            .observeIn(DispatchQueue.main.context)
    }
}
