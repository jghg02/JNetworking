# ``JNetwork``


<img width="60" alt="iOS" src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white"> <img width="70" alt="iOS" src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white">



This library provee all the necessary logic to make a request to any API from your application.


##  Installation

Add JNetwork Client as a dependency through Xcode or directly to Package.swift:

```
.package(url: "https://github.com/jghg02/JNetworking", branch: "master")
```

## Usage

GET request with no expected success or error response object types.

```swift 
import JNetworking

let client = JNWebClient<JNEmpty,JNEmpty>()
let request = JNRequest(url: URL(string: "http://API-URL")!)
client.request(request: request) { result in
    switch result {
    case .success(let data):
      print(data)
    case .failure(let error):
       print(error)
                
    }
}
```

## Important 
I had created a new NetWork Layer with async await. This is the link of the repo -> https://github.com/jghg02/NET
