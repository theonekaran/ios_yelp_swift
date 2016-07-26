//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BusinessesViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {

    var businesses: [Business]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var searchTerm = "Thai"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.hidden = true
        let centerLocation = CLLocation(latitude: 37.7858, longitude: -122.406)
        goToLocation(centerLocation)
        
        //Initialize tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //add Searchbar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = false
        self.navigationItem.titleView = searchBar

        Business.searchWithTerm(searchTerm, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            //reload tableview once data is available
            self.tableView.reloadData()
            
            //Clear Map
            self.clearMap()
            
            for business in businesses {
                let pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(business.coordinates!["latitude"]! as! CLLocationDegrees, business.coordinates!["longitude"]! as! CLLocationDegrees)
                self.addAnnotationAtCoordinate(business.name!, coordinate: pinCoordinate)
            }
        })

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    
    func clearMap () {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotationAtCoordinate(name: String, coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func onMapButtonPressed(sender: AnyObject) {
        if mapView.hidden {
            mapView.hidden = false
        } else if !mapView.hidden {
            mapView.hidden = true
        }
    }
    
    //Search methods
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTerm = searchBar.text!
        Business.searchWithTerm(searchTerm, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            //reload tableview once data is available
            self.tableView.reloadData()
            self.clearMap()
            for business in businesses {
                let pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(business.coordinates!["latitude"]! as! CLLocationDegrees, business.coordinates!["longitude"]! as! CLLocationDegrees)
                self.addAnnotationAtCoordinate(business.name!, coordinate: pinCoordinate)
            }
            
        })
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()

    }
    
    //Table methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        let sort = filters["sort"] as! Int
//        let distance = filters["distance"]![0] as! [String]
        let deals = filters["deals"] as? Bool
        Business.searchWithTerm(searchTerm, sort: YelpSortMode(rawValue: sort), categories: categories, deals: deals) { (businesses:[Business]!, error: NSError!) in
            self.businesses = businesses
            self.tableView.reloadData()
            self.clearMap()
            for business in businesses {
                let pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(business.coordinates!["latitude"]! as! CLLocationDegrees, business.coordinates!["longitude"]! as! CLLocationDegrees)
                self.addAnnotationAtCoordinate(business.name!, coordinate: pinCoordinate)
            }
        }
    }

}
