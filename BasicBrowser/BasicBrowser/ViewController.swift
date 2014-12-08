import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var containerView: UIView!

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        
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
        
        loadLocation("https://www.mozilla.org")
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
