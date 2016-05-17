
import UIKit

class API {
    private static func dataTask(path: String, params: Dictionary<String, AnyObject>? = nil, method: String, completion: (success: Bool, object: JSON?) -> ()) {
        
        let request = requestForPathWithParams(path, params: params)
        
        request.HTTPMethod = method
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data: data)
                if let response = response as? NSHTTPURLResponse where 200...299 ~= response.statusCode {
                    completion(success: true, object: json)
                } else {
                    completion(success: false, object: json)
                }
            }
            }.resume()
    }
    
    private static func post(path: String, params: Dictionary<String, AnyObject>? = nil, completion: (success: Bool, object: JSON?) -> ()) {
        dataTask(path, params: params, method: "POST", completion: completion)
    }
    
    private static func put(path: String, params: Dictionary<String, AnyObject>? = nil, completion: (success: Bool, object: JSON?) -> ()) {
        dataTask(path, params: params, method: "PUT", completion: completion)
    }
    
    private static func get(path: String, params: Dictionary<String, AnyObject>? = nil, completion: (success: Bool, object: JSON?) -> ()) {
        dataTask(path, params: params, method: "GET", completion: completion)
    }
    
    private static func delete(path: String, params: Dictionary<String, AnyObject>? = nil, completion: (success: Bool, object: JSON?) -> ()) {
        dataTask(path, params: params, method: "DELETE", completion: completion)
    }
    
    private static func requestForPathWithParams(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate.apiServer + path)!)
        if let params = params {
            var paramString = ""
            for (key, value) in params {
                let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                paramString += "\(escapedKey)=\(escapedValue)&"
            }
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        return request
    }
    
    private static func stringToJSON(string: String) -> Array<AnyObject> {
        var json: Array<AnyObject>!
        do {
            json = try NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions()) as? Array
        } catch {
            print(error)
        }
        
        return json
    }
    
    static func test(completion: (success: Bool, message: JSON) -> ()) {
        
        get("users") { (success, json) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print(json)
                if let json = json {
                    completion(success: success, message: json)
                } else {
                    completion(success: success, message: nil)
                }
            })
        }
    }
        
    
}
