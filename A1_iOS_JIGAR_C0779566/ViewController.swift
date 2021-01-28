//
//  ViewController.swift
//  A1_iOS_JIGAR_C0779566
//
//  Created by Jigar Pachchigar on 25/01/21.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    // MARK: - IBOUTLETS
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var navBtn: UIButton!
    
    // MARK: - DECLARATIONS
    
    var markerNameArray     = ["A","B","C"]
    var locationMnager      = CLLocationManager()
    var annotationArray     = [MKPointAnnotation]()
    var selectedAnnotation  : MKPointAnnotation?
    var destination         : CLLocationCoordinate2D!
    var polygon             : MKPolygon?

    // MARK: - VIEW_METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOfMapAndLocation()
        addLongPressOnMap()
        
    }
 
    // MARK: - FUNCTIONS
    
    func setupOfMapAndLocation() {
        map.delegate = self
        map.showsUserLocation = true
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()
    }
    
    func addLongPressOnMap() {
        let longprec = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longprec.minimumPressDuration = 0.4
        map.addGestureRecognizer(longprec)
    }
    
    @objc func handleTap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            if annotationArray.count > 2 {
                let alertController = UIAlertController(title: nil, message: "Marker limit Exceed!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            else {
                
                let loc = sender.location(in: map)
                let coordinate = map.convert(loc, toCoordinateFrom: map)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = namingTheMarker()
                annotation.subtitle = "Latitude:" + String(format: "\"%0.02f\"", annotation.coordinate.latitude) + ", Longitude:" + String(format: "\"%0.02f\"", annotation.coordinate.longitude)
                map.addAnnotation(annotation)
                annotationArray.append(annotation)
                
            }
            
            drawPolygon()
            
        }
    }
    
    func namingTheMarker() -> String {
        var strMarkerName = markerNameArray[0]
        let tempMarkerArray = annotationArray.compactMap({ $0.title! })
        if !tempMarkerArray.isEmpty {
            strMarkerName = markerNameArray.filter { !tempMarkerArray.contains($0) }.first!
        }
        return strMarkerName
    }
    
    func drawPolygon() {
        var locations = annotationArray.map { $0.coordinate }
        polygon = MKPolygon(coordinates: &locations, count: locations.count)
        map.addOverlay(polygon!)
    }
    
    // MARK: - BTN_ACTIONS
    
    @IBAction func navigationTapped(_ sender: UIButton) {
        
        let latDelta: CLLocationDegrees = 0.08
        let lngDelta: CLLocationDegrees = 0.08
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let coordinate = MKCoordinateRegion(center: map.userLocation.coordinate, span: span)
        
        map.setRegion(coordinate, animated: true)
        map.removeOverlays(map.overlays)

    }
    
}

// MARK: - EXTENSIONS_LOCATIONMANAGER_DELEGATE, MKMAPVIEW_DELEGATE

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "ic_place_icon")
            let deleteButton = UIButton(type: .custom)
            deleteButton.frame = .init(x: 0, y: 0, width: 30, height: 30)
            deleteButton.setImage(UIImage(named: "delete_icon"), for: .normal)
            annotationView.rightCalloutAccessoryView = deleteButton
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation, let title = annotation.title else { return }
        
        let alertController = UIAlertController(title: nil, message: "Would you like to delete \"\(title!)\" marker", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true)
        })

        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.map.removeAnnotation(annotation)
            if let idx = self.annotationArray.firstIndex(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                self.annotationArray.remove(at: idx)
                if let polygon = self.polygon {
                    self.map.removeOverlay(polygon)
                }
            }
        })

        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("mapView didSelect annotation view's coordinate ",view.annotation!.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}
