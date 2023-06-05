//
//  CellSearchResult.swift
//  WeatherApp
//
//  Created by Karun Kumaron 02/06/23.
//

import UIKit

class CellSearchResult: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var lblCityName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Set Data
    func setData(ForCity model: SearchCityModel) {
        let strName = model.name ?? ""
        let strState = model.state ?? ""
        let strCountry = model.country ?? ""
        self.lblCityName.text = strName + " " + strState + " " + strCountry
    }

}
