//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Karan Khurana on 7/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

//enum sortRowIdentifier : String {
//    case bestMatch = "Best Match"
//    case distance = "Distance"
//    case highestRated = "Highest Rated"
//}
//
//class sortPreferences {
//    var bestMatch = true, distance = false, highestRated = false
//}



class FiltersViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, RadioCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String: String]]!
    var distance: [[String: String]]!
    var sortOptions: [[String: String]]!
    var deals: [[String: String]]!
    var categorySwitchStates = [Int:Bool]()
    var distanceSwitchStates = [Int:Bool]()
    var sortSwitchStates = [Int:Bool]()
    var dealsSwitchStates = [Int:Bool]()

    
    
    var data = [[[String:String]]]()
    let dataHeaders = ["Deals", "Distance", "Sort By", "Category"]

    var currentSortPreference: String! = "Best Match"
    
    var dealSection = 0
    var distanceSection = 1
    var sortSection = 2
    var categorySection = 3
    
//    var currentSortPrefs: sortPreferences!
//    let tableStructure: [sortRowIdentifier] = [.bestMatch, .distance, .highestRated]
//    var prefValues: [sortRowIdentifier: Bool] = [:]
//    
//    // should be set by the class that instantiates this view controller
//    var currentSortPrefs: sortPreferences! {
//        didSet {
//            prefValues[.bestMatch] = currentSortPrefs.bestMatch
//            prefValues[.distance] = currentSortPrefs.distance
//            prefValues[.highestRated] = currentSortPrefs.highestRated
//            tableView?.reloadData()
//        }
//    }
//    
//    func preferencesFromTableData() -> sortPreferences {
//        let ret = sortPreferences()
//        ret.bestMatch = prefValues[.bestMatch] ?? ret.bestMatch
//        ret.distance = prefValues[.distance] ?? ret.distance
//        ret.highestRated = prefValues[.highestRated] ?? ret.highestRated
//        return ret
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categories = yelpCategories()
        distance = yelpDistance()
        sortOptions = yelpSort()
        deals = yelpDeals()
        
        
        //Setup sections

        data = [deals!, distance!, sortOptions!,categories!]
//        currentSortPrefs = currentSortPrefs ?? sortPreferences()
        
        
        //initialize tableview
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String : AnyObject]()

        //        for section in switchStates {
        //            for (row,isSelected) in section {
        //                if isSelected {
        //                    selectedCategories.append(categories[row]["code"]!)
        //                }
        //            }
        //        }
        
        
        //set Category Filter
        var selectedCategories = [String]()

        
        for (row,isSelected) in categorySwitchStates {
            if isSelected {
                print("Category Row: \(categories[row]["code"]!)")
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
    
        
        //set Deals Filter
        var selectedDeals = [String]()
        
        for (row,isSelected) in dealsSwitchStates {
            if isSelected {
                selectedDeals.append(deals[row]["code"]!)
            }
        }
        
        
        //set Distance Filter
        var selectedDistance = [String]()
        
        
        for (row,isSelected) in distanceSwitchStates {
            if isSelected {
                selectedDistance.append(distance[row]["code"]!)
            }
        }
        
        //set Sort Filter
        var selectedSort = [String]()
        
        
        for (row,isSelected) in sortSwitchStates {
            if isSelected {
                print("Sort Row: \(sortOptions[row]["code"]!)")
                selectedSort.append(sortOptions[row]["code"]!)
            }
        }
        print("Selected Sort: \(selectedSort)")
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        if selectedSort.count > 0 {
            filters["sort"] = selectedSort
        }
        if selectedDeals.count > 0 {
            filters["deals"] = selectedDeals
        }
        if selectedDistance.count > 0 {
            filters["distance"] = selectedDistance
        }

        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataHeaders[section]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    //Initiate the Table cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == dealSection { //Deals
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = data[indexPath.section][indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = dealsSwitchStates[indexPath.row] ?? false
            return cell
        } else if indexPath.section == distanceSection { //Distance
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = data[indexPath.section][indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = distanceSwitchStates[indexPath.row] ?? false
            return cell
        } else if indexPath.section == sortSection { //Sort
            let cell = tableView.dequeueReusableCellWithIdentifier("RadioCell", forIndexPath: indexPath) as! RadioCell
            cell.radioLabel.text = data[indexPath.section][indexPath.row]["name"]
            cell.delegate = self
            let sortOption = sortOptions[indexPath.row]["name"]!
            
            if sortOption == currentSortPreference {
                cell.selected = true
                cell.radioImage.highlighted = true
            } else {
                cell.selected = false
                cell.radioImage.highlighted = false
            }
            return cell
        } else if indexPath.section == categorySection { //Category
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = data[indexPath.section][indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = categorySwitchStates[indexPath.row] ?? false
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    //Sort Switch changes
    func radioCell(radioCell: RadioCell, didChangeValue value: Bool) {
//        print("\(radioCell.selected)")
        let indexPath = tableView.indexPathForCell(radioCell)!
        print("\(indexPath.section)")
        if indexPath.section == 2 {
            let on = radioCell.selected
            if on {
                currentSortPreference = sortOptions[indexPath.row]["name"]
                
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
                print(currentSortPreference)
            }
            sortSwitchStates[indexPath.row] = value
            print("\(sortSwitchStates)")
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        print("\(indexPath.section)")
        print("\(indexPath.row)")
        if indexPath.section == 0 {
            dealsSwitchStates[indexPath.row] = value
        } else if indexPath.section == 1 {
            distanceSwitchStates[indexPath.row] = value
        } else  if indexPath.section == 3 {
            categorySwitchStates[indexPath.row] = value
        }
    }
    
    func yelpDeals () -> [[String: String]] {
        return [["name" : "Deals", "code": "deal"]]
    }
    
    func yelpSort () -> [[String: String]] {
        return [["name" : "Best Match", "code": "0"],
                ["name" : "Distance", "code": "1"],
                ["name" : "Highest Rated", "code": "2"]]
    }
    
    
    func yelpDistance () -> [[String: String]] {
        return [["name" : "Auto", "code": "0"],
                ["name" : "0.3 mile", "code": "500"],
                ["name" : "1 mile", "code": "1600"],
                ["name" : "5 miles", "code": "8000"],
                ["name" : "20 miles", "code": "32000"]]
    }
    
    func yelpCategories () -> [[String: String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
