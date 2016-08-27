//
//  ViewController.swift
//  Ulysses
//
//  Created by Matteo Muscella on 26/08/16.
//  Copyright © 2016 The Ulysses Team. All rights reserved.
//

import AVFoundation
import UIKit
import MapKit

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var backgroundMusicPlayer = AVAudioPlayer()
    var wantsToPlay = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paris = Note(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", audio: "01.mp3")

        mapView.addAnnotation(paris)
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

