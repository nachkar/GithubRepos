 //
 //  HTTPRequest.swift
 //  GithubRepos
 //
 //  Created by Noel Achkar on 3/26/19.
 //  Copyright © 2019 Noel Achkar. All rights reserved.
 //

import UIKit
import Alamofire
import SVProgressHUD

class HTTPRequest: NSObject
{
    override init ()
    {
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 120
    }
    
    func setHeaders(request : URLRequest) -> URLRequest
    {
        var urlRequest = request
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        return urlRequest
    }
    
    func GET(requestUrl : String , parameters : Parameters, success: @escaping (_ response:Any) -> Void, failure: @escaping () -> Void)
    {
        let url = URL(string: requestUrl)!
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            
            switch response.result
            {
            case .success:
                let resultString = String(data: response.data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                if let dictionary = resultString.convertToDictionary()
                {
                    success(dictionary as Any)
                }
                else
                {
                    failure()
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                failure()
                break
            }
        }
    }
}
 
 extension TrendingViewController
 {    
    func getData()
    {
        SVProgressHUD.show()
        
        let urlString = "https://api.github.com/search/repositories"
        
        //Get date 30 days ago
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: fromDate!)

        var request = GithubReposRequest()
        request.q = "created:>\(dateStr)"
        request.sort = "start"
        request.order = "desc"
        request.page = "1"
        
        let httpRequest = HTTPRequest.init()
        httpRequest.GET(requestUrl: urlString, parameters: request.jsonDictionary(useOriginalJsonKey: true), success:{(response:Any)  in
            if response is NSDictionary
            {
                SVProgressHUD.dismiss()
                
                print("Github Repos "+"\(response)")
                
                self.responseModel = GithubReposResponse.init(json: response as? Dictionary)
                if self.responseModel != nil
                {
                    self.tableView.reloadData()
                }
            }
            else
            {
                //                Utilities.showMessage(message: Constants.Messages.ErrorMessage)
            }
        }, failure: {() in
            //            loader.hide()
            //            Utilities.showMessage(message: Constants.Messages.ErrorMessage)
        } )
    }
 }

