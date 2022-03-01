# ``JNetworking``

This library provee all the necessary logic to make a request to any API from your application.

## How to use
 
In order to use this library in your application. The first thing to do is to add this package as a dependency in your project. 

For this you need to go to **File** > **Add Packages** and then enter the repository url. You can also navigate to your target’s General pane, and in the **Frameworks, Libraries, and Embedded Content** section, click the **+** button, select Add Other, and choose Add Package Dependency. 

#### URL
```
https://github.com/jghg02/JNetWorking
```

Then you must define the constants associated with the url and the paths that you will need to make the request. for this we create a structure like this 

```swift
struct ServicesConstants {
    static let baseURL = "https://base-url"
    static let path1 = "/path-1"
    static let path2 = "/path-2"
}
```

Then it is important to define the operations we want to do when connecting to that API. For this we can create a class that extends ``APIProtocol``

```swift
/// This enum will hold all API's actions we want to perform 
enum APIName {
    case getAllCharacters
}

/// If you need to add parameters to your requests you can define them here 
struct APIQueryParams {
    var characterId: Int? = 0
}

```



We then define an extension to implement ``APIProtocol``

```swift 
extension APIName: APIProtocol {
    func httpMthodType() -> HTTPMethodType {
        var methodType = HTTPMethodType.get
        switch self {
        case .getAllCharacters
            methodType = .get
        }
        return methodType
    }

    func apiEndPath() -> String {
        var path = ""
        switch self {
        case .getAllCharacters:
            path += ServicesConstants.path-1
        }
        return path
    }

    func apiBasePath() -> String {
        switch self {
        case .getAllCharacters:
            return ServicesConstants.baseURL
        }
    }


}
```
Finally we define our class where the logic will be to make the request and get the information we need. 

It would be something like this 

```swift

typealias GetAllCharactersResponse = (Result<Model, Error>) -> Void

protocol APIServicesRequestType {
@discardableResult func getAllCharacters(apiQueryModel: APIQueryParams, completion: @escaping GetAllCharactersResponse) -> URLSessionDataTask?
}

struct ServicesRequest: APIServicesRequestType {

func getAllCharacters(apiQueryModel: APIQueryParams, completion: @escaping GetAllCharactersResponse) -> URLSessionDataTask? {
    let requestModel = APIRequestModel(api: APIName.getAllCharacters)
    return JNWebserviceHelper.requestAPI(apiModel: requestModel) { response in
        switch response {
        case .success(let data):
            JNJSONResponseDecoder.decodeFrom(data, returningModelType: Model.self, completion: { (allData, error) in
                if let parserError = error {
                    completion(.failure(parserError))
                    return
                }

                if let data = allData {
                    completion(.success(data))
                }
            })
        case .failure(let error):
            completion(.failure(error))
            }
        }
    }

}

```


