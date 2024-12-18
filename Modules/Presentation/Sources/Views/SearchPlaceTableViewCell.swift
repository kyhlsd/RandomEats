//
//  SearchPlaceTableViewCell.swift
//  Data
//
//  Created by 김영훈 on 12/18/24.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {
    lazy var placeLabel = {
        let placeLabel = UILabel()
        placeLabel.text = ""
        placeLabel.numberOfLines = 1
        placeLabel.lineBreakMode = .byTruncatingHead
        placeLabel.textAlignment = .left
        placeLabel.textColor = .black
        placeLabel.font = .systemFont(ofSize: 15, weight: .medium)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(placeLabel)
        
        NSLayoutConstraint.activate([
            placeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            placeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            placeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            placeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
}
