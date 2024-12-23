//
//  SearchPlaceViewController.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import UIKit
import Combine
import Domain

class SearchPlaceViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var placePredictions = [PlacePrediction]()
    
    private var searchPlaceViewModel: SearchPlaceViewModel
    
    public init(searchPlaceViewModel: SearchPlaceViewModel) {
        self.searchPlaceViewModel = searchPlaceViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var closeButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        return closeButton
    }()
    private lazy var navigationBar = {
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        let navigationItem = UINavigationItem(title: "위치 검색")
        navigationItem.rightBarButtonItem = closeButtonItem
        let navigationBar = UINavigationBar()
        navigationBar.setItems([navigationItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = UIColor(named: "PrimaryColor")
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소를 검색하세요"
        searchBar.backgroundColor = UIColor(named: "BackgroundColor")
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        bindSearchBar()
        
        bindViewModel()
        
        setupUI()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchPlaceTableViewCell.self, forCellReuseIdentifier: "searchPlaceTableViewCell")
    }
    
    private func bindSearchBar() {
        searchBar.textDidChangePublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.searchPlaceViewModel.fetchPlacePrediction(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        searchPlaceViewModel.$placePredictions
            .sink { [weak self] placePredictions in
                if let placePredictions = placePredictions {
                    self?.placePredictions = placePredictions
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
            .store(in: &cancellables)
        
        // 에러 메시지 바인딩
        searchPlaceViewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

extension SearchPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placePredictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchPlaceTableViewCell", for: indexPath) as? SearchPlaceTableViewCell else {
            return UITableViewCell()
        }
        cell.placeTitleLabel.text = placePredictions[indexPath.row].mainText
        cell.placeDescriptionLabel.text = placePredictions[indexPath.row].description
        return cell
    }
}
