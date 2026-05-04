import SwiftUI
import WebKit

struct PaymentWebView: UIViewRepresentable {
    let url: URL
    let successUrlKeyword: String
    var onOrderCompleted : () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        webView.backgroundColor = .white
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: PaymentWebView
        
        init(_ parent: PaymentWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                let urlString = url.absoluteString
                
                if urlString.contains(parent.successUrlKeyword) {
                    decisionHandler(.allow)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let urlString = webView.url?.absoluteString,
               urlString.contains(parent.successUrlKeyword) {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.parent.onOrderCompleted()
                }
            }
        }
    }
}
