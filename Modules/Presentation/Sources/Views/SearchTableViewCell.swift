//
//  SearchPlaceTableViewCell.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    lazy var placeTitleLabel = {
        let placeTitleLabel = UILabel()
        placeTitleLabel.text = ""
        placeTitleLabel.numberOfLines = 1
        placeTitleLabel.lineBreakMode = .byTruncatingHead
        placeTitleLabel.textAlignment = .left
        placeTitleLabel.textColor = .black
        placeTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        placeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeTitleLabel
    }()
    
    lazy var placeDescriptionLabel = {
        let placeDescriptionLabel = UILabel()
        placeDescriptionLabel.text = ""
        placeDescriptionLabel.numberOfLines = 1
        placeDescriptionLabel.lineBreakMode = .byTruncatingHead
        placeDescriptionLabel.textAlignment = .left
        placeDescriptionLabel.textColor = .systemGray
        placeDescriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeDescriptionLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(placeTitleLabel)
        contentView.addSubview(placeDescriptionLabel)
        
        NSLayoutConstraint.activate([
            placeTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            placeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            placeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            placeDescriptionLabel.topAnchor.constraint(equalTo: placeTitleLabel.bottomAnchor, constant: 5),
            placeDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            placeDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            placeDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
}
