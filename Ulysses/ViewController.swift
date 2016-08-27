//
//  ViewController.swift
//  Ulysses
//
//  Created by Matteo Muscella on 26/08/16.
//  Copyright © 2016 The Ulysses Team. All rights reserved.
//

import Alamofire
import AVFoundation
import UIKit
import MapKit
import SwiftyJSON

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var backgroundMusicPlayer = AVAudioPlayer()
    var wantsToPlay = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom out the map
        mapView.region.span.longitudeDelta /= 1.5
        mapView.region.span.latitudeDelta /= 1.5
        // Center around Europe
        mapView.region.center = CLLocationCoordinate2D(latitude: 45, longitude: 50)
        mapView.setRegion(mapView.region, animated: true)

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
            self.wantsToPlay = self.wantsToPlay ? false : true
            self.playBackgroundMusic(audioFile)
        }
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "play", style: .Default, handler: callActionHandler))
        ac.addAction(UIAlertAction(title: "stop", style: .Default, handler: callActionHandler))
        presentViewController(ac, animated: true, completion: nil)
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
            
            if (self.wantsToPlay) {
                backgroundMusicPlayer.play()
            } else {
                backgroundMusicPlayer.pause()
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}
