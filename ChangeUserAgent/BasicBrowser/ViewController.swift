import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var containerView: UIView!

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self

        // EXPERIMENT - To change the User Agent, we can register the UserAgent default. This has to be done before the WKWebView has been loaded. Note that this changes the UserAgent globally for the application. Not just for the WKWebView but for the complete URL loading system.
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent" : "Custom Agent"])
        NSUserDefaults.standardUserDefaults().synchronize()

        webView = WKWebView()
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        containerView.addSubview(webView)
        
        let views = ["webView": webView]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|",
            options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|",
            options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        
        // EXPERIMENT - I looked in the access logs for my server and I see that the UA has been changed consistently for all types of requests
        loadLocation("http://stefan.arentz.ca/")
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loadLocation(textField.text)
        return true
    }
    
    func loadLocation(var location: String) {
        if !location.hasPrefix("http://") && !location.hasPrefix("https://") {
            location = "http://" + location
        }
        locationTextField.text = location
        webView.loadRequest(NSURLRequest(URL: NSURL(string: location)!))
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        locationTextField.text = webView.URL?.absoluteString
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        locationTextField.text = webView.URL?.absoluteString
        webView.loadHTMLString("<p>Fail Navigation: \(error.localizedDescription)</p>", baseURL: nil)
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        locationTextField.text = webView.URL?.absoluteString
        webView.loadHTMLString("<p>Fail Provisional Navigation: \(error.localizedDescription)</p>", baseURL: nil)
    }
}
