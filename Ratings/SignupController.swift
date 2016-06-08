
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire

class SignupController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginSpinner.hidesWhenStopped = true
        
        view.backgroundColor = Util.getMainColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            print("already logged in. Going to MainController \(FBSDKAccessToken.currentAccessToken().tokenString)")
            gotoMain()
            
        } else {
            self.loginButton.readPermissions = ["public_profile", "email"]
            self.loginButton.delegate = self
        }
    }
    
    func gotoMain() {
        let mainNavController = storyboard?.instantiateViewControllerWithIdentifier("MainNavController")
        API.fetchAndSetUserId()
        self.presentViewController(mainNavController!, animated: true, completion: nil)
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("login()")
        if ((error) != nil)
        {
            print("error logging in \(error)")
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            print("result is cancelle!")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if (result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")) {
                self.loginSignup()
            } else {
                print("both permissions required to login")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func loginSignup() {
        
        loginSpinner.startAnimating()
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print("error in graphRequest: \(error)")
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
                            
                            print("errored in server login: \(JSON["error"]! as! String!)")
                            
                            // display a UIAlertView with message:
                            let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            print("successfuly logged in through the server!")
                            API.fetchAndSetUserId()
                        }
                    }
                    
                    // stop the loading:
                    self.loginSpinner.stopAnimating()
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

