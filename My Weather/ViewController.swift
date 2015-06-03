//
//  ViewController.swift
//  My Weather
//
//  Created by Jonathan on 23/05/15.
//  Copyright (c) 2015 Jonathan. All rights reserved.
//
// http://api.openweathermap.org/data/2.5/weather?q=medellin&units=metric&lang=es


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"

    @IBOutlet weak var ciudad: UILabel!
    @IBOutlet weak var climaLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var Table: UITableView!
    var city:String?
    var InfoClima:String?
    var icon:String?
    var temp:String?
    var max:String?
    var min:String?
    var UrlPath:String!
    var arr:NSArray?
    var dias_semana:NSArray? = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo"]
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func LlamaWebService(){
        let Url = NSURL(string:self.UrlPath)
        let session =  NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(Url!, completionHandler: {data, response, error -> Void in
            if (error != nil){
                println(error.localizedDescription)
            }
            var nsdata:NSData =  NSData(data:data)
            self.recuperarJson(nsdata)
            dispatch_async(dispatch_get_main_queue(), {self.Table.reloadData();self.iconImg.image = UIImage(named: self.icon!); self.climaLabel.text =  self.InfoClima!; self.tempLabel.text = self.temp; self.maxLabel.text = self.max; self.minLabel.text = self.min})
        })
        task.resume()
    }
    
    func recuperarJson(nsdata:NSData){
        let jsonCompleto: AnyObject! = NSJSONSerialization.JSONObjectWithData(nsdata, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if let ppal = jsonCompleto["list"] as? NSArray{
            self.arr = ppal
            if let entra = ppal[0]["weather"] as? NSArray{
                entra.enumerateObjectsUsingBlock({model, index, stop in
                    self.InfoClima = model["description"] as? String
                    self.icon = model["icon"] as? String
                });
                if let MainArray =  ppal[0]["temp"] as? Dictionary<String, AnyObject>{
                    let temperatura = MainArray["day"] as! Int
                    let max_temp = MainArray["max"] as! Int
                    let min_temp = MainArray["min"] as! Int
                    var x =  String(temperatura)
                    var y = String(max_temp)
                    var z = String(min_temp)
                    self.temp = x + "º"
                    self.max = "Max:" + y+"º"
                    self.min = "Min:" + z+"º"
                }
                
            }
            
            
        }
        
    }
    
    
    //location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                println("Error:" + error.localizedDescription)
                return
            }
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }else {
                println("Error con los datos")
            }
        })
    }
    
    
    
    func displayLocationInfo(placemark: CLPlacemark) {
        self.locationManager.stopUpdatingLocation()
        var location = placemark.locality + ", " + placemark.country
        dispatch_async(dispatch_get_main_queue(), {self.ciudad.text = location })
        /*println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)*/
        var loc = placemark.locality
        var loc_url = String(filter(loc.generate()) { $0 != " "})
        println(loc_url)
        self.UrlPath = "http://api.openweathermap.org/data/2.5/forecast/daily?q=\(loc_url)&lang=sp&units=metric"
        LlamaWebService()


    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    //table
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        
        return 7
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        self.Table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        var cell:UITableViewCell = self.Table.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        for (var i = 1; i < 7; i++){
            if let entra = self.arr?[indexPath.row]["weather"] as? NSArray{
                entra.enumerateObjectsUsingBlock({model, index, stop in
                    self.InfoClima = model["description"] as? String
                    self.icon = model["icon"] as? String
                });
                if let MainArray =  self.arr?[indexPath.row]["temp"] as? Dictionary<String, AnyObject>{
                    let temperatura = MainArray["day"] as! Int
                    let max_temp = MainArray["max"] as! Int
                    let min_temp = MainArray["min"] as! Int
                    var x =  String(temperatura)
                    var y = String(max_temp)
                    var z = String(min_temp)
                    self.temp = x + "º"
                    self.max = "Max:" + y+"º"
                    self.min = "Min:" + z+"º"
                    
                    var dias = String((self.dias_semana![indexPath.row] as! String) + ":" + x + "º")
                    cell.textLabel?.text = dias as! String
                    cell.imageView!.image = UIImage(named: self.icon!)
                }
                
            }
        
        }
        
        //println(indexPath.row)

        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    
    


}

