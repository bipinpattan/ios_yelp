//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate,  FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    
    var categoryStates: [Int : Bool]!
    var distancesStates: [Int : Bool]!
    var sortByStates: [Int : Bool]!
    var offeringADealState: Bool!
    var isMoreDataLoading = false
    var searchTerm = "Thai"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        search(withTerm: searchTerm)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationViewController = segue.destination as! UINavigationController
        let filtersViewController = navigationViewController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        filtersViewController.switchStates = categoryStates
        filtersViewController.distancesSwitchStates = distancesStates
        filtersViewController.sortBySwitchStates = sortByStates
        filtersViewController.offeringADealState = offeringADealState
    }
    
    // MARK:- Delegate callbacks
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses?.count ?? 0;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = self.businesses[indexPath.row]
        return cell
        
    }
    
    // MARK: FiltersViewControllerDelegate
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject], withDistance distance: Int, withDeals deals: Bool, withSortBy sortBy: Int, withCategoryStates categoryState: [Int : Bool]!, withDistancesStates distanceState: [Int : Bool]!, withSortByStates sortByState: [Int : Bool]!, withOfferingDealState dealState: Bool!) {
        
        var mode: YelpSortMode
        switch sortBy {
        case 1:
            mode = .distance
            break
        case 2:
            mode = .highestRated
            break
        default:
            mode = .bestMatched
            break
        }
        self.categoryStates = categoryState
        self.distancesStates = distanceState
        self.sortByStates = sortByState
        self.offeringADealState = dealState
        
        let categories = filters["categories"] as? [String]
        Business.searchWithTerm(term: "restaurants", sort: mode, categories: categories, deals: deals, radiusMeters: distance, offset: nil) {
            (businesses:[Business]?, error:Error?) in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
                print("Load more data")
                search(withTerm: searchTerm)
            }
        }
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = searchBar.text!
        search(withTerm: searchTerm)
        searchBar.resignFirstResponder()
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.text = searchTerm
        
        navigationItem.titleView = searchBar
        navigationController?.navigationBar.barTintColor = UIColor.red;
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.isTranslucent = false;
    }
    
    func setupData() {
        categoryStates = [Int : Bool]()
        distancesStates = [Int : Bool]()
        sortByStates = [Int : Bool]()
        offeringADealState = Bool()
        businesses = [Business]()
    }
    
    func search(withTerm term: String) {
        Business.searchWithTerm(term: term, offset:businesses.count, completion: { (businesses: [Business]?, error: Error?) -> Void in

            self.isMoreDataLoading = false
            if let businesses = businesses {
                for business in businesses {
                    self.businesses.append(business)
                }
            }
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
    }
}
