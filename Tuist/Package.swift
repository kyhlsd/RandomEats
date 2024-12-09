// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: ["CombineCocoa": .framework,
                       "GooglePlaces": .framework]
    )
#endif

let package = Package(
    name: "RandomEats",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.1"),
        .package(url: "https://github.com/googlemaps/ios-places-sdk.git", from: "9.2.0")
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
