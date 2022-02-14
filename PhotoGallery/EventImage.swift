//
//  EventImage.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

struct EventImage: Identifiable, Equatable {
	var id = UUID().uuidString
	var url: String
	var voteCount: Int
	
	private enum eventImage: String, CodingKey {
		case id
		case imageURL
		case voteCount
	}
}
