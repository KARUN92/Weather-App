//
//  LoaderView.swift
//  WeatherApp

import UIKit

class LoaderView: UIView {
    
    public static let sharedInstance = LoaderView()
    var loaderView: LoaderView!
    
    //MARK: - IBOutlets
    @IBOutlet weak var viewSpinner: UIView!
    
    func showLoader() {
        let window = UIApplication.shared.windows.last
        
        // Get XIB
        self.loaderView = getXIB()
        
        // Layer Properties
        self.loaderView.viewSpinner.layer.cornerRadius = 8.0
        self.loaderView.viewSpinner.layer.masksToBounds = true
        
        // Add to Window
        window?.addSubview(self.loaderView)
        window?.bringSubviewToFront(self.loaderView)
    }
    
    func getXIB() -> LoaderView {
        let xib = UINib(nibName: "LoaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoaderView
        return xib
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView.removeFromSuperview()
        }
    }

}
