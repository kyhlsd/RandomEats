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
                ]
            ),
            sources: ["RandomEats/Sources/**"],
            resources: ["RandomEats/Resources/**"],
            dependencies: []
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
    ]
)
