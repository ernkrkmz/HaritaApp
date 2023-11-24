//
//  DetailsVC.swift
//  HaritaApp
//
//  Created by Eren Korkmaz on 17.04.2023.
//

import UIKit
import MapKit
import CoreData
class DetailsVC: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var nameLabel: UITextField!
    
    @IBOutlet weak var notLabel: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var pinVarmi = false
    
    var selectedLatitude = Double()
    var selectedLongitude = Double()

    var secilenisim = ""
    var secilenid : UUID?
    
    var annoName = ""
    var annoNot = ""
    var longitude = Double()
    var latitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRec = UILongPressGestureRecognizer(target: self , action: #selector(konumSec(gestureRec: )))
        gestureRec.minimumPressDuration = 2
        map.addGestureRecognizer(gestureRec)

        if secilenisim != "" {
            
            locationManager.stopUpdatingLocation()
            
            if let uuidStrig = secilenid?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchReq.predicate = NSPredicate(format: "id = %@", uuidStrig)
                fetchReq.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchReq)
                    
                    if sonuclar.count > 0 {
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let name = sonuc.value(forKey: "name") as? String {
                                nameLabel.text = name
                                annoName = name
                            }
                            if let not = sonuc.value(forKey: "not") as? String {
                                notLabel.text = not
                                annoNot = not
                            }
                            if let lat = sonuc.value(forKey: "lattitude") as? Double {
                                latitude = lat
                            }
                            if let lon = sonuc.value(forKey: "longitude") as? Double {
                                longitude = lon
                            }
                            let annotation = MKPointAnnotation()
                            annotation.title = annoName
                            annotation.subtitle = annoNot
                            
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            annotation.coordinate = coordinate
                            
                            map.addAnnotation(annotation)
                            pinVarmi = true
                            
                            saveBtn.isEnabled = false
                            
                            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let reigon = MKCoordinateRegion(center: location, span: span)
                            map.setRegion(reigon, animated: true)
                            
                            nameLabel.isUserInteractionEnabled = false
                            notLabel.isUserInteractionEnabled = false
                        }
                    }
                }catch{}
                
            }
        }
 
        
    }
    @objc func konumSec(gestureRec : UILongPressGestureRecognizer){
        
        if pinVarmi == false && secilenisim == "" {
            if gestureRec.state == .began {
                let dokulunlanNokta = gestureRec.location(in: map)
                let dokunulanKordinat = map.convert(dokulunlanNokta, toCoordinateFrom: map)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = dokunulanKordinat
                annotation.title    = nameLabel.text
                annotation.subtitle = notLabel.text
                
                map.addAnnotation(annotation)
                pinVarmi = true
                
                selectedLatitude = dokunulanKordinat.latitude
                selectedLongitude = dokunulanKordinat.longitude
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if secilenisim == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let reigon = MKCoordinateRegion(center: location, span: span)
            map.setRegion(reigon, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ return nil }
        let reuseId = "asd"
        var pinview = map.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinview == nil {
            pinview = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinview?.canShowCallout = true
            pinview?.tintColor = .purple
            
            let button = UIButton(type: .infoDark)
            pinview?.rightCalloutAccessoryView = button
            
        }else {
            pinview?.annotation = annotation
        }
        
        return pinview
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenisim != "" {
            var reqLocation = CLLocation(latitude: latitude, longitude: longitude)

            CLGeocoder().reverseGeocodeLocation(reqLocation) { placemarkDizisi, hata in
                if let placemarks = placemarkDizisi {
                    if placemarks.count > 0 {
                        
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        
                        item.name = self.annoName
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        
        if pinVarmi == true {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // import CoreData
            let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
            
            yeniYer.setValue(nameLabel.text, forKey: "name")
            yeniYer.setValue(notLabel.text, forKey: "not")
            yeniYer.setValue(selectedLatitude, forKey: "lattitude")
            yeniYer.setValue(selectedLongitude, forKey: "longitude")
            yeniYer.setValue(UUID(), forKey: "id")
            
            do{
                try context.save()
                
            }catch{
            
            }
            
        }
        else{
        
            let alert = UIAlertController(title: "Alert", message: "Pin a point", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    

}
