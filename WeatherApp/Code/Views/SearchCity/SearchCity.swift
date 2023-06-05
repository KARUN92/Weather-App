//
//  SearchCity.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import UIKit

protocol SearchCityDelegate {
    func selectedCity(_ selectedModel: SearchCityModel)
}

class SearchCity: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSearchResult: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var delegate: SearchCityDelegate?
    private let searchCityViewModel = SearchCityViewModel()
    private var arraySearchResult = [SearchCityModel]()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Search City"
        
        setupNavBar()
    }
}

// MARK: - Setup
extension SearchCity {
    private func setupNavBar() {
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(btnCancelClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func btnCancelClicked() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableView Methods
extension SearchCity: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arraySearchResult.count <= 0 {
            self.lblNoData.isHidden = false
            self.view.bringSubviewToFront(self.lblNoData)
            return 0
        }
        
        self.lblNoData.isHidden = true
        return self.arraySearchResult.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSearchResult") as! CellSearchResult
        
        // Set Data
        let model = self.arraySearchResult[indexPath.row]
        cell.setData(ForCity: model)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Selected Model
        let model = self.arraySearchResult[indexPath.row]
        self.delegate?.selectedCity(model)
        
        // Dismiss
        self.btnCancelClicked()
    }
}

// MARK: - UISearchBar Delegate
extension SearchCity: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searched Text: \(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            getCityResult(WithSearchText: searchText)
        }
    }
}

// MARK: - API Call
extension SearchCity {
    private func getCityResult(WithSearchText searchText: String) {
        // Show Loading Screen
        LoaderView.sharedInstance.showLoader()
        
        self.searchCityViewModel.getCity(withSearchText: searchText) { model, error in
            // Hide Loading Screen
            LoaderView.sharedInstance.hideLoader()
            
            if let errorMessage = error {
                // Show Alert
                self.showAlert(withMessage: errorMessage)
            } else {
                // Get Array of Search Result
                self.arraySearchResult.removeAll()
                self.arraySearchResult = model ?? []
                
                // Reload UITableView
                DispatchQueue.main.async {
                    self.tableViewSearchResult.reloadData()
                }
            }
        }
    }
}

// MARK: - Show Alert
extension SearchCity {
    func showAlert(withMessage strMessage: String) {
        let alert = UIAlertController(title: "", message: strMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alert, animated: true)
    }
}
