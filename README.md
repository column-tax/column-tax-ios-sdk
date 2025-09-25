# Column Tax iOS SDK

A lightweight SwiftUI SDK for integrating [Column Tax](https://docs.columntax.com/) tax filing directly into your iOS application.

## Requirements

- iOS 13.2+
- Swift 5.7+

## Installation

### Swift Package Manager

Add the Column Tax iOS SDK to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/column-tax/column-tax-ios-sdk.git`
3. Click **Add Package**
4. Select the `ColumnTaxFile` library to add to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/column-tax/column-tax-ios-sdk.git", from: "1.0.0")
]
```

## Quick Start

### 1. Import the SDK

```swift
import SwiftUI
import ColumnTaxFile
```

### 2. Get a User URL

First, obtain a user URL from the [Column Tax API](https://docs.columntax.com/reference/express-initialize-tax-filing):

```swift
// Call your backend to get the user_url from Column Tax API
let userUrl = "https://app.columnapi.com/tax-filing?params=eyJ0b2tlbiI6ImV5Sm..."
```

### 3. Present the Tax Filing Interface

```swift
struct ContentView: View {
    @State private var showTaxFiling = false

    var body: some View {
        Button("Start Tax Filing") {
            showTaxFiling = true
        }
        .sheet(isPresented: $showTaxFiling) {
            ColumnTaxFile(
                userUrl: URL(string: userUrl)!,
                isPresented: $showTaxFiling,
                handleClose: {
                    // Tax filing completed
                    showTaxFiling = false
                    // Handle completion (e.g., refresh user data, show success message)
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}
```

## API Reference

### ColumnTaxFile

A SwiftUI view that presents the Column Tax interface in a secure WebView.

#### Parameters

- `userUrl: URL` - The user-specific URL obtained from the Column Tax API
- `isPresented: Binding<Bool>` - Controls the presentation state of the view
- `handleClose: () -> Void` - Callback executed when the tax filing process completes

#### Example

```swift
ColumnTaxFile(
    userUrl: URL(string: "https://columnapi.com/tax-filing/user/abc123")!,
    isPresented: $showTaxFiling,
    handleClose: {
        print("Tax filing completed")
        showTaxFiling = false
    }
)
```

## Error Handling

The SDK passes URLs directly to the WebView. We strongly recommend the URL is valid before passing them to the SDK:

```swift
guard let url = URL(string: userUrlString) else {
    // Handle invalid URL
    showError = "Invalid tax filing URL"
    return
}

ColumnTaxFile(userUrl: url, isPresented: $showTaxFiling, handleClose: handleClose)
```

## Camera Permissions (Optional)

If your tax filing flow includes document scanning features, add camera permissions to your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to scan tax documents</string>
```

## Sample App

Check out the complete example in the `Examples/column-swiftui-example` directory to see the SDK in action.

## Documentation

For detailed API documentation and integration guides, visit our [Mobile SDK documentation](https://docs.columntax.com/reference/mobile-sdk-guide).
