import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        InstagramWebView()
            .ignoresSafeArea(edges: .bottom)
    }
}

struct InstagramWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default() // keeps you logged in between launches

        let script = WKUserScript(
            source: noReelsJS,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        webView.load(URLRequest(url: URL(string: "https://www.instagram.com/")!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// Same logic as the Safari userscript.
// Set REDIRECT_REEL_PAGES to false to allow opening Reels sent in DMs.
let noReelsJS = """
(function () {
  const REDIRECT_REEL_PAGES = true;

  function redirectIfReels() {
    if (!REDIRECT_REEL_PAGES) return;
    const p = location.pathname;
    if (p.startsWith("/reels") || p.startsWith("/reel/")) {
      location.replace("/");
    }
  }

  function hideReels() {
    document.querySelectorAll('a[href^="/reels"]').forEach((a) => {
      a.style.display = "none";
    });
    document.querySelectorAll('article a[href*="/reel/"]').forEach((a) => {
      const post = a.closest("article");
      if (post) post.style.display = "none";
    });
  }

  function run() {
    redirectIfReels();
    hideReels();
  }

  new MutationObserver(run).observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  let lastUrl = location.href;
  setInterval(function () {
    if (location.href !== lastUrl) {
      lastUrl = location.href;
      run();
    }
  }, 500);

  run();
})();
"""
