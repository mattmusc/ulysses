//
//  ViewController.swift
//  Ulysses
//
//  Created by Matteo Muscella on 26/08/16.
//  Copyright © 2016 The Ulysses Team. All rights reserved.
//

import AddressBookUI
import Alamofire
import AVFoundation
import ContactsUI
import UIKit
import MapKit
import SwiftyJSON
import FontAwesome_swift

class ViewController: UIViewController, AVAudioPlayerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // controllers
    var resultSearchController:UISearchController? = nil
    
    var backgroundMusicPlayer = AVAudioPlayer()
    var locationManager = CLLocationManager()

    var audioPlaying = false
    var DEBUG = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Setup the map
        mapView.showsUserLocation = true
        // Zoom out the map
        mapView.region.span.longitudeDelta /= 1.5
        mapView.region.span.latitudeDelta /= 1.5
        // Center around Europe
        mapView.region.center = CLLocationCoordinate2D(latitude: 45, longitude: 50)
        mapView.setRegion(mapView.region, animated: true)

        
        if (DEBUG) {
        // Fetch data from my server and add it to the map
        Alamofire.request(.GET, Constants.SERVER_URL).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let values = response.result.value {
                    let json = JSON(values)
                    
                    for (_,j) in json {
                        let note = Note(
                            title: j["title"].stringValue,
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(j["latitude"].stringValue)!,
                                longitude: Double(j["longitude"].stringValue)!),
                            info: j["info"].stringValue,
                            audio: j["audio"].stringValue)

                        self.mapView.addAnnotation(note)
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
        }
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // 1
        let identifier = "Note"
        
        // 2
        if annotation is Note {
            // 3
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
                
            } else {
                // 6
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        // 7
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let note = view.annotation as! Note
        let placeName = note.title
        let placeInfo = note.info
        let audioFile = note.audio
        
        let callActionHandler = { (action:UIAlertAction!) -> Void in
            self.audioPlaying = self.audioPlaying ? false : true
            self.playBackgroundMusic(audioFile)
        }
        
        let closeActionHandler = { (action:UIAlertAction!) -> Void in
            
        }
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        
        ac.addAction(UIAlertAction(title: self.audioPlaying ? "stop" : "play", style: .Default, handler: callActionHandler))
        ac.addAction(UIAlertAction(title: "close", style: .Default, handler: closeActionHandler))
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                if placemark?.areasOfInterest?.count > 0 {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print(areaOfInterest)
                } else {
                    print("No area of interest found.")
                }
            }
        })
    }
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            else if placemarks?.count > 0 {
                let pm = placemarks![0]
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
                print("\n\(address)")
                if pm.areasOfInterest?.count > 0 {
                    let areaOfInterest = pm.areasOfInterest?[0]
                    print(areaOfInterest!)
                } else {
                    print("No area of interest found.")
                }
            }
        })
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            NSLog("Could not find file: \(filename)")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.delegate = self
            backgroundMusicPlayer.prepareToPlay()
            
            if (self.audioPlaying) {
                backgroundMusicPlayer.play()
            } else {
                backgroundMusicPlayer.pause()
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        
        let region = MKCoordinateRegion (center:  location,span: span)
        
        mapView.setRegion(region, animated: true)
    }
}
