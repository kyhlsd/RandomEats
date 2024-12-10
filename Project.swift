import ProjectDescription

let project = Project(
    name: "RandomEats",
    targets: [
        .target(
            name: "RandomEats",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.RandomEats",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "NSLocationWhenInUseUsageDescription": "위치 정보를 사용합니다.",
                    "GOOGLE_PLACES_API_KEY": "$(GOOGLE_PLACES_API_KEY)"
                ]
            ),
            sources: ["RandomEats/Sources/**"],
            resources: ["RandomEats/Resources/**"],
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Shared"),
                .external(name: "CombineCocoa"),
            ]
        ),
        .target(
            name: "RandomEatsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.RandomEatsTests",
            infoPlist: .default,
            sources: ["RandomEats/Tests/**"],
            resources: [],
            dependencies: [.target(name: "RandomEats")]
        ),
        // Presentation Module
        .target(
            name: "Presentation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.example.presentation",
            infoPlist: .default,
            sources: ["Modules/Presentation/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Shared"),
                .external(name: "CombineCocoa")
            ]
        ),
        .target(
            name: "PresentationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.presentationTests",
            infoPlist: .default,
            sources: ["Modules/Presentation/Tests/**"],
            dependencies: [
                .target(name: "Presentation")
            ]
        ),
        // Domain Module
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.example.domain",
            infoPlist: .default,
            sources: ["Modules/Domain/Sources/**"],
            dependencies: [
                .target(name: "Shared")
            ]
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.domainTests",
            infoPlist: .default,
            sources: ["Modules/Domain/Tests/**"],
            dependencies: [
                .target(name: "Domain")
            ]
        ),
        // Data Module
        .target(
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.example.data",
            infoPlist: .default,
            sources: ["Modules/Data/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Shared"),
                .external(name: "GooglePlaces"),
                .external(name: "Alamofire")
            ]
        ),
        .target(
            name: "DataTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.dataTests",
            infoPlist: .default,
            sources: ["Modules/Data/Tests/**"],
            dependencies: [
                .target(name: "Data")
            ]
        ),
        // Shared Module
        .target(
            name: "Shared",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.example.shared",
            infoPlist: .default,
            sources: ["Modules/Shared/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "SharedTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.example.sharedTests",
            infoPlist: .default,
            sources: ["Modules/Shared/Tests/**"],
            dependencies: [
                .target(name: "Shared")
            ]
        )
    ]
)

