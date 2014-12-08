
WKWebView does not follow the Safari DNT setting.
There is no API to enable do not track
We can implement a custom (proxying) ProtocolHandler, but that only seems to work on UIWebView and not WKWebView

