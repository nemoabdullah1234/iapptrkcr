import UIKit
import AKLog
class NoInternetConnection: NSObject {
    
    func checkReachablity() {
        AFNetworkReachabilityManager.shared()
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange({(status) in
            
            if status == .notReachable {
                print("No Internet Connection")
                self.showAlertAction("No Internet Connection")
                AKApplicationState.sharedHandler.setRole = roleLog
                AKApplicationState.sharedHandler.setWIFIAvailable("0")

                
            }
            else{
                
                AKApplicationState.sharedHandler.setRole = roleLog
                AKApplicationState.sharedHandler.setWIFIAvailable("1")


            }
        })
    }
    
    func showAlertAction(_ alertMessage : String) {
        let alertController: UIAlertController = UIAlertController()
        
        alertController.message = alertMessage
        
        
        alertController.title = ApplicationName.appName.rawValue
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        
        let topController = topMostController()
        alertController.popoverPresentationController?.sourceView = topController.view
        
        topController.present(alertController, animated:true, completion:nil)
        
        
    }
    func topMostController()->UIViewController
    {
        var topController = UIApplication.shared.keyWindow!.rootViewController;
        
        while (topController!.presentedViewController != nil)
        {
            topController = topController!.presentedViewController;
        }
        
        return topController!;
    }
    
}


