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
    private var pages: [UIPageViewController]
    weak var delegate: SearchPageNavigationDelegate?
    
    private var searchPlaceViewModel: SearchPlaceViewModel
    
    public init(searchPlaceViewModel: SearchPlaceViewModel) {
        self.searchPlaceViewModel = searchPlaceViewModel
        self.pages = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var searchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소를 검색하세요"
        searchBar.backgroundColor = UIColor(named: "BackgroundColor")
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        // textField 기본 좌우 여백 제거
        let textField = searchBar.searchTextField
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            textField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -8)
        ])
        
        return searchBar
    }()
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 10
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BackgroundColor")
        
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
        
        searchPlaceViewModel.$placeLocation
            .sink { [weak self] placeLocation in
                if let placeLocation = placeLocation {
                    self?.delegate?.goToNextPage(with: placeLocation)
                }
            }
            .store(in: &cancellables)
        
        // 에러 메시지 바인딩
        searchPlaceViewModel.$errorMessage
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    if errorMessage == LocationServiceError.permissionDenied.errorDescription {
                        self.showPermissionDeniedAlert()
                    } else if errorMessage == LocationServiceError.permissionRestricted.errorDescription {
                        self.showPermissionRestrictedAlert()
                    } else if errorMessage == LocationServiceError.unknownError.errorDescription {
                        self.showLocationUnknownErrorAlert()
                    }
                    else {
                        self.showErrorAlert(errorMessage: errorMessage)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    //MARK: Alert 함수
    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.searchPlaceViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showPermissionRestrictedAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "위치 서비스 권한 필요",
                message: self.searchPlaceViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showLocationUnknownErrorAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "위치 정보 가져오기 실패",
                message: self.searchPlaceViewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
    }
    
    private func showErrorAlert(errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "닫기", style: .default))
            
            self.present(alert, animated: true)
        }
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchPlaceViewModel.selectedPrediction = placePredictions[indexPath.row]
        searchPlaceViewModel.fetchCoordinates(placeId: placePredictions[indexPath.row].placeId)
    }
}
