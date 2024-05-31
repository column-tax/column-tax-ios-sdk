import SwiftUI
import Foundation
import WebKit
import UIKit

public class ColumnWebView: WKWebView {
    public override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

class NavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let allowedDomains = [
            "localhost",
            "columnapi.com",
            "env.bz"
        ]

        // Check if the navigation is in a subframe (like an iframe)
        if navigationAction.targetFrame?.isMainFrame == false {
            // If it's not the main frame, always allow it to load within the WebView
            decisionHandler(.allow)
            return
        }

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        guard let host = url.host else {
            decisionHandler(.allow)
            return
        }

        let searchParams = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )?.queryItems;

        let isExternalLink = searchParams?.filter { param in
            param.name == "columntax-external-link" && param.value == "true"
        }.count ?? 0 > 0

        let isAllowedInWebview = allowedDomains.filter { domain in
            host == domain || host.hasSuffix(domain)
        }.count > 0

        if !isExternalLink && isAllowedInWebview {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        UIApplication.shared.open(url)
    }
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    var handleClose: () -> Void

    init(handleClose: @escaping () -> Void) {
        self.handleClose = handleClose
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "column-on-close" {
            handleClose()
        }
    }
}

public struct ColumnTaxView: UIViewRepresentable {
    let userUrl: URL
    @Binding var isPresented: Bool
    var handleClose: () -> Void // Closure to handle close event

    var navigationDelegate: WKNavigationDelegate = NavigationDelegate()
    var scriptMessageHandler: ScriptMessageHandler // Handle user events

    public func updateUIView(_ uiView: ColumnWebView, context: Context) {
        let request = URLRequest(url: userUrl)
        uiView.load(request)
    }

    public func makeUIView(context: Context) -> ColumnWebView  {
        let columnWebView = ColumnWebView()
        // support handleClose event
        columnWebView.configuration.userContentController.add(self.scriptMessageHandler, name: "column-on-close")
        columnWebView.navigationDelegate = self.navigationDelegate;
        let request = URLRequest(url: userUrl)
        columnWebView.load(request)
        return columnWebView
    }

    public init(userUrl: URL, isPresented: Binding<Bool>, handleClose: @escaping () -> Void) {
        self.userUrl = userUrl
        self._isPresented = isPresented
        self.handleClose = handleClose
        self.scriptMessageHandler = ScriptMessageHandler(handleClose: handleClose)
    }

    // Implement the WebView message handling to listen for the "column-on-close" event
    // Call the handleClose closure when "column-on-close" event is received
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "column-on-close" {
            handleClose()
        }
    }
}
