
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire

class SignupController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            
            // Or Show Logout Button
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
            self.loginSignup()
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            print("error! \(error)")
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            print("result is cancelle!")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            
            print("loginSignup() time!!!")
            self.loginSignup()
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func startLoading() {
        
    }
    
    func stopLoading() {
        
    }
    
    func loginSignup() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // display a UIAlertView showing why it failed. And that's it..
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                // make request to server with the accessToken:
                let url = "https://one-mile.herokuapp.com/login-signup"
                Alamofire.request(.POST, url,
                    parameters: [
                        "accessToken": accessToken
                    ]
                ) .responseJSON { response in
                    if let JSON = response.result.value {
                        if (JSON["error"]! != nil) {
                            
                            // need to explicitly end refreshing in this method because setTheMeet() not called in this conditional brach:
                            
                            // display a UIAlertView with message:
                            let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let isSignup = JSON["isSignup"]! as! Bool!
                            print("isSignup: \(isSignup)")
                            
                            if (isSignup!) {
                                // transition to the profile page to get description input...
                                self.performSegueWithIdentifier("MainViewSegue", sender: nil)
                            } else {
                                // go straight to the main view controller...
                                self.performSegueWithIdentifier("MainViewSegue", sender: nil)
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

