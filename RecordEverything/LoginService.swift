import Foundation
import UIKit
import Alamofire
import SwiftyJSON

public class LoginService : NSObject {
    
    // MARK: Properties
    var username: String?
    var password: String?
    
//    internal var session:NSURLSession!
//    private var tokenInfo:OAuthInfo!
//    
//    
//    // MARK: Types
//    
//    struct OAuthInfo {
//        let token: String!
//        let tokenExpiresAt: NSDate!
//        let refreshToken: String!
//        let refreshTokenExpiresAt: NSDate!
//        
//        
//        // MARK: Initializers
//        
//        init(issuedAt: NSDate, refreshTokenIssuedAt: NSDate, tokenExpiresIn: NSTimeInterval, refreshToken: String, token: String, refreshTokenExpiresIn: NSTimeInterval) {
//            
//            // Store OAuth token and associated data
//            self.refreshTokenExpiresAt = NSDate(timeInterval: refreshTokenExpiresIn, sinceDate: refreshTokenIssuedAt)
//            self.tokenExpiresAt = NSDate(timeInterval: tokenExpiresIn, sinceDate: issuedAt)
//            self.token = token
//            self.refreshToken = refreshToken
//            
//            // Persist the OAuth token and associated data to NSUserDefaults
//            NSUserDefaults.standardUserDefaults().setObject(self.refreshTokenExpiresAt, forKey: "refreshTokenExpiresAt")
//            NSUserDefaults.standardUserDefaults().setObject(self.tokenExpiresAt, forKey: "tokenExpiresAt")
//            NSUserDefaults.standardUserDefaults().setObject(self.token, forKey: "token")
//            NSUserDefaults.standardUserDefaults().setObject(self.refreshToken, forKey: "refreshToken")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
//        
//        init() {
//            // Retrieve OAuth info from NSUserDefaults if available
//            if let refreshTokenExpiresAt = NSUserDefaults.standardUserDefaults().valueForKey("refreshTokenExpiresAt") as? NSDate {
//                self.refreshTokenExpiresAt = refreshTokenExpiresAt
//            } else {
//                self.refreshTokenExpiresAt = nil
//            }
//            if let tokenExpiresAt = NSUserDefaults.standardUserDefaults().valueForKey("tokenExpiresAt") as? NSDate {
//                self.tokenExpiresAt = tokenExpiresAt
//            } else {
//                self.tokenExpiresAt = nil
//            }
//            if let token = NSUserDefaults.standardUserDefaults().valueForKey("token") as? String {
//                self.token = token
//            } else {
//                self.token = nil
//            }
//            if let refreshToken = NSUserDefaults.standardUserDefaults().valueForKey("refreshToken") as? String {
//                self.refreshToken = refreshToken
//            } else {
//                self.refreshToken = nil
//            }
//        }
    
        
//        // MARK: Sign Out
//        
//        func signOut() -> () {
//            
//            // Clear OAuth Info from NSUserDefaults
//            NSUserDefaults.standardUserDefaults().removeObjectForKey("refreshTokenExpiresAt")
//            NSUserDefaults.standardUserDefaults().removeObjectForKey("tokenExpiresAt")
//            NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
//            NSUserDefaults.standardUserDefaults().removeObjectForKey("refreshToken")
//        }
//    }
//    
    func signOut() {
        username = nil
        password = nil
    }
    //    public func signOut() {
    //
    //        // Clear the OAuth Info
    //        self.tokenInfo.signOut()
    //        self.tokenInfo = nil
    //    }

    
    // MARK: Singleton Support
    
    class var sharedInstance : LoginService {
        struct Singleton {
            static let instance = LoginService()
        }
        
//        // Check whether we already have an OAuthInfo instance
//        // attached, if so don't initialiaze another one
//        if Singleton.instance.tokenInfo == nil {
//            // Initialize new OAuthInfo object
//            Singleton.instance.tokenInfo = OAuthInfo()
//        }
        
        // Return singleton instance
        return Singleton.instance
    }
    
    
    // MARK: Initializers
    
    override init() {
        //let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        super.init()
        
        //session = NSURLSession(configuration: sessionConfig)
        
        // Ensure we only have one instance of this class and that it is the Singleton instance
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(0.1 * Double(NSEC_PER_SEC))
            ), dispatch_get_main_queue()) {
                assert(self === LoginService.sharedInstance, "Only one instance of LoginManager allowed!")
        }
    }
    
    
    // MARK: Login Utilities
    
    public func loginWithCompletionHandler(username: String, password: String, completionHandler: ((error: String?) -> Void)!) -> () {
        loginOrSignup(username, password: password, signup: false, completionHandler: completionHandler)
    }
    public func signupWithCompletionHandler(username: String, password: String, completionHandler: ((error: String?) -> Void)!) -> () {
        loginOrSignup(username, password: password, signup: true, completionHandler: completionHandler)
    }
    
    
    public func isLoggedIn() -> Bool {
//        var loggedIn:Bool = false
//        if let info = self.tokenInfo {
//            if let tokenExpiresAt = info.tokenExpiresAt {
//                
//                // Check to see OAuth token is still valid
//                if fabs(tokenExpiresAt.timeIntervalSinceNow) > 60 {
//                    loggedIn = true
//                }
//            }
//        }
//        
//        return loggedIn
        if let _ = self.username, let _ = self.password {
            return true
        }
        return false
    }
    
    
    // MARK: Token Utilities
    
//    public func token() -> String {
//        if isLoggedIn() {
//            return self.tokenInfo.token
//        } else {
//            return ""
//        }
//    }
    
//    public func refreshToken() -> String {
//        var refreshToken: String = ""
//        
//        if self.tokenInfo != nil {
//            if fabs(self.tokenInfo.refreshTokenExpiresAt.timeIntervalSinceNow) > 60 {
//                refreshToken = self.tokenInfo.refreshToken
//            }
//        }
//        
//        return refreshToken
//    }
//    
//    public func setAuthHeader(mutableURLRequest: NSMutableURLRequest) {
//        if token() != "" {
//            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        } else if refreshToken() != "" {
//            getNewTokenFromRefreshToken { _ in
//                if token() != "" {
//                    mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                }
//            }
//        }
//        
//    }
    
    
    // MARK: Private Methods
    
    private func loginOrSignup(username: String, password: String, signup: Bool, completionHandler: ((error: String?) -> Void)!) -> () {
        self.username = username
        self.password = password
        var path = "login"
        if signup {
            path = "signup"
        }
        
        let url = AppConstants.apiURLWithPathComponents(path)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
//        let params =  "client_id=\(AppConstants.clientId)"
//        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setAuthorizationHeader()

        Alamofire.request(request).responseString { response in
            var statusCode: Int
            if let httpError = response.result.error {
                statusCode = httpError.code
                print("Status Code:",statusCode)
            } else { //no errors
                statusCode = (response.response?.statusCode)!
                print("Status Code:", statusCode)
            }
            
            switch statusCode {
            case 200:
                completionHandler(error: nil)
            case -1004,-1002:
                completionHandler(error: "No Response")
            default:
                if let error = response.result.value {
                    completionHandler(error: error)
                } else {
                    completionHandler(error: "Unknown Error")
                }
            }
        }
    }
    
//    private func getNewTokenFromRefreshToken(completion: ()->()) {
//        
//    }
//    
//    private func exchangeTokenForUserAccessTokenWithCompletionHandler(username: String, password: String, signup: Bool, completion: (OAuthInfo?, error: String?) -> ()) {
//        //TODO: do something with signup
//        let path = "oauth/token"
//        let url = AppConstants.apiURLWithPathComponents(path)
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        
//        let params =  "client_id=\(AppConstants.clientId)&client_secret=\(AppConstants.clientSecret)&grant_type=password&username=\(username)&password=\(password)"
//        
//        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.
//        
//        let utf8str = "\(AppConstants.clientId):\(AppConstants.clientSecret)".dataUsingEncoding(NSUTF8StringEncoding)
//        let token = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//        request.addValue("Authorization \(token)", forHTTPHeaderField: "Authorization")
//        
//        Alamofire.request(request).responseJSON { response in
//            if let httpError = response.result.error {
//                print("Error:",httpError)
//                completion(nil, error: httpError.domain)
//            } else {
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    
//                    if let token = json["access_token"].string,
//                            let tokenExpiresIn = json["expires_in"].double,
//                            let refreshToken = json["refresh_token"].string,
//                            let refreshTokenExpiresIn = json["refresh_token_expires_in"].double {
//
//                                
//                        let calendar = NSCalendar.currentCalendar()
//                        let currentDate = NSDate()
//                        let epochIssuedAt = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: currentDate)
//                        let epochRefreshTokenIssuedAt = epochIssuedAt
//                        //add some cushion
//                        epochIssuedAt.minute -= 1
//                        epochRefreshTokenIssuedAt.minute -= 1
//                    
//                    
//                        let oauthInfo = OAuthInfo(issuedAt: calendar.dateFromComponents(epochIssuedAt)!, refreshTokenIssuedAt: calendar.dateFromComponents(epochRefreshTokenIssuedAt)!, tokenExpiresIn: tokenExpiresIn, refreshToken: refreshToken, token: token, refreshTokenExpiresIn: refreshTokenExpiresIn)
//                    
//                        completion(oauthInfo, error: nil)
//                    }
//                    if let error = json["error"].string {
//                        completion(nil, error: error)
//                    }
//                }
//            }
//        }
//    }
}