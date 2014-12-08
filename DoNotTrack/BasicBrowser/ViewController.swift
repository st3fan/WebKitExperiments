import UIKit
import WebKit



class CustomURLProtocol: NSURLProtocol {
    
    var connection: NSURLConnection!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        println("canInitWithRequest \(request.URL.absoluteString)")
        if NSURLProtocol.propertyForKey("CustomURLProtocol", inRequest: request) != nil {
            return false
        }
        return true
    }

    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, toRequest:b)
    }
    
    override func startLoading() {
        var newRequest = self.request.copy() as NSMutableURLRequest
        
        newRequest.setValue("1", forHTTPHeaderField: "DNT")
        
        NSURLProtocol.setProperty(true, forKey: "CustomURLProtocol", inRequest: newRequest)
        self.connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.client!.URLProtocol(self, didLoadData: data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.client!.URLProtocolDidFinishLoading(self)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.client!.URLProtocol(self, didFailWithError: error)
    }
}



class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var containerView: UIView!

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self

        NSURLProtocol.registerClass(CustomURLProtocol)
        
        webView = WKWebView()
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        webView.allowsBackForwardNavigationGestures = true
//        webView.navigationDelegate = self
        containerView.addSubview(webView)
        
        let views = ["webView": webView]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|",
            options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|",
            options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        
        loadLocation("http://www.xhaus.com/headers")
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
