//
//  EventImage.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

struct EventContent: Identifiable, Codable, Hashable {
	var id: String?
	var url: String?
	var data: Data?
	var isVideo: Bool?
	var voteCount: Int?
	var userFullName: String?
	
	private enum EventContent: String, CodingKey {
		case id
		case imageURL
		case data
		case isVideo
		case voteCount
		case userFullName
	}
}
