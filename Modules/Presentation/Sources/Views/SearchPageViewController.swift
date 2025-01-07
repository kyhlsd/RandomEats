//
//  SearchPlaceViewController.swift
//  Data
//
//  Created by 김영훈 on 12/23/24.
//

import UIKit
import Combine
import Domain
import Data

protocol SearchPageNavigationDelegate: AnyObject {
    func goToNextPage(with location: Location)
    func dismissModal(searchedLocation: Location, searchedPlaceName: String)
}

class SearchPageViewController: UIViewController {
    weak var locationViewModelDelegate: LocationViewModelDelegate?
    weak var randomRecommendViewModelDelegate: RandomRecommendViewModelDelegate?
    private var pages = [UIViewController]()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var backButton = {
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.isHidden = true
        return backButton
    }()
    private lazy var closeButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        return closeButton
    }()
    private lazy var navigationBar = {
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        let navigationItem = UINavigationItem(title: "위치 검색")
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = closeButtonItem
        let navigationBar = UINavigationBar()
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = UIColor(named: "PrimaryColor")
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pages = [searchPlaceViewController, searchMapViewController]
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageViewController
    }()
    private lazy var searchPlaceViewModel: SearchPlaceViewModel = {
        let locationService = LocationServiceImplementation()
        let locationRepository = LocationRepositoryImplementation(locationService: locationService)
        let locationUseCase = LocationUseCase(locationRepository: locationRepository)
        
        let searchPlaceService = SearchPlaceServiceImplementaion()
        let searchPlaceRepository = SearchPlaceRepositoryImplementation(searchPlacetService: searchPlaceService)
        let searchPlaceUseCase = SearchPlaceUseCase(searchPlaceRepository: searchPlaceRepository)
        
        let fetchCoordinatesService = FetchCoordinatesServiceImplementaion()
        let fetchCoordinatesRepository = FetchCoordinatesRepositoryImplementation(fetchCoordinatesService: fetchCoordinatesService)
        let fetchCoordinatesUseCase = FetchCoordinatesUseCase(fetchCoordinatesRepository: fetchCoordinatesRepository)
        
        let searchPlaceViewModel = SearchPlaceViewModel(locationUseCase: locationUseCase, searchPlaceUseCase: searchPlaceUseCase, fetchCoordinatesUseCase: fetchCoordinatesUseCase)
        return searchPlaceViewModel
    }()
    private lazy var searchPlaceViewController: SearchPlaceViewController = {
        let searchPlaceViewController = SearchPlaceViewController(searchPlaceViewModel: searchPlaceViewModel)
        searchPlaceViewController.delegate = self
        return searchPlaceViewController
    }()
    private lazy var searchMapViewController: SearchMapViewController = {
        let searchMapViewController = SearchMapViewController(searchPlaceViewModel: searchPlaceViewModel)
        searchMapViewController.searchPageNavigationDelegate = self
        return searchMapViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        backButton.addAction(UIAction { [weak self] _ in
            self?.backToPreviousPage()
        }, for: .touchUpInside)
        
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(pageViewController.view)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            pageViewController.view.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SearchPageViewController: SearchPageNavigationDelegate {
    
    internal func goToNextPage(with location: Location) {
        DispatchQueue.main.async {
            self.searchMapViewController.updateMapView()
            self.pageViewController.setViewControllers([self.pages[1]], direction: .forward, animated: true)
            self.backButton.isHidden = false
        }
    }
    
    internal func backToPreviousPage() {
        DispatchQueue.main.async {
            self.pageViewController.setViewControllers([self.pages[0]], direction: .reverse, animated: true)
            self.backButton.isHidden = true
        }
    }
    
    internal func dismissModal(searchedLocation: Location, searchedPlaceName: String) {
        locationViewModelDelegate?.setLocationWithSearchResult(searchedLocation: searchedLocation)
        randomRecommendViewModelDelegate?.setAddressWithSearchedResult(searchedAddress: searchedPlaceName)
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
