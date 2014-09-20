//
//  ViewController.swift
//  Honeybee
//
//  Created by chao han on 14-9-20.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

import UIKit
import AudioService

class ViewController: UIViewController, SKMapViewDelegate, SKCalloutViewDelegate, SKRoutingDelegate, SKNavigationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var mapView:SKMapView = SKMapView(frame:self.view.frame)
        mapView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        mapView.visibleRegion = SKCoordinateRegion(center:CLLocationCoordinate2DMake(39.907333, 116.391083),zoomLevel:10)
        
        var internationalizationSettings:SKMapInternationalizationSettings = SKMapInternationalizationSettings()
        internationalizationSettings.primaryOption = SKMapInternationalizationOption.Local
        internationalizationSettings.fallbackOption = SKMapInternationalizationOption.Local
        internationalizationSettings.primaryInternationalLanguage = SKMapLanguage.EN
        internationalizationSettings.fallbackInternationalLanguage = SKMapLanguage.DE
        internationalizationSettings.showBothRows = true
        mapView.settings.mapInternationalization = internationalizationSettings
        
        mapView.delegate = self
        mapView.calloutView.delegate = self;
        
        self.view.addSubview(mapView);
        
        
        SKRoutingService.sharedInstance().routingDelegate = self // set for receiving routing callbacks
        SKRoutingService.sharedInstance().mapView = mapView
        
        var settings:SKAdvisorSettings = SKAdvisorSettings();
        settings.advisorVoice = "en us";
        settings.language  = "en_us";
        SKRoutingService.sharedInstance().advisorConfigurationSettings = settings;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView:SKMapView!, didRotateWithAngle angle:Float) {
        mapView.settings.showCompass = true
    }
    
    func mapViewDidSelectCompass(mapView:SKMapView!) {
        mapView.animateToBearing(0)
        mapView.settings.showCompass = false
    }
    
    func mapView(mapView:SKMapView!, didSelectMapPOI mapPOI:SKMapPOI!) {
        
        mapView.calloutView.titleLabel.text = mapPOI.name
        mapView.calloutView.subtitleLabel.text = String(mapPOI.category.toRaw())

        mapView.showCalloutAtLocation(mapPOI.coordinate, withOffset: CGPointMake(0, 0), animated: false)
        
//        var annotation:SKAnnotation = SKAnnotation()
//        annotation.identifier = 10
//        annotation.annotationType = SKAnnotationType.Purple
//        annotation.location = mapPOI.coordinate
//
//        mapView.addAnnotation(annotation)
        
    }
    
    func mapView(mapView:SKMapView!, didLongTapAtCoordinate coordinate:CLLocationCoordinate2D) {
        
        mapView.calloutView.titleLabel.text = "当前点"
        mapView.calloutView.subtitleLabel.text = "\(coordinate.latitude),\(coordinate.latitude)"
        
        mapView.showCalloutAtLocation(coordinate, withOffset: CGPointMake(0, 0), animated: false)
    }
    
    func calloutView(calloutView:SKCalloutView!, didTapLeftButton leftButton:UIButton!) {
        
        var route:SKRouteSettings = SKRouteSettings()
        route.startCoordinate = SKPositionerService.sharedInstance().currentCoordinate
        route.destinationCoordinate = calloutView.location;
        route.shouldBeRendered = true // If NO, the route will not be rendered.
        route.routeMode = SKRouteMode.CarFastest
        route.numberOfRoutes = 1
        route.avoidHighways = true
        SKRoutingService.sharedInstance().calculateRoute(route)
    }
    
    func routingService(routingService:SKRoutingService!, didFinishRouteCalculationWithInfo routeInformation:SKRouteInformation) {
        routingService.zoomToRouteWithInsets(UIEdgeInsetsZero) // zoom to current route
        
        var navSettings:SKNavigationSettings = SKNavigationSettings()
        navSettings.navigationType = SKNavigationType.Real
        navSettings.distanceFormat = SKDistanceFormat.MilesFeet
        SKRoutingService.sharedInstance().mapView.settings.displayMode = SKMapDisplayMode.Mode3D
        SKRoutingService.sharedInstance().startNavigationWithSettings(navSettings);
    }
    
    func routingService(routingService:SKRoutingService!, didUpdateFilteredAudioAdvices audioAdvices:NSArray){
        //Play audio advice.
        //AudioService.sharedInstance().play(audioAdvices);
    }

    func mapView(mapView:SKMapView!, didDoubleTapAtCoordinate coordinate:CLLocationCoordinate2D) {
        SKRoutingService.sharedInstance().stopNavigation();
    }
}

