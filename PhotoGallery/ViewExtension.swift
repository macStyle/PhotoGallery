//
//  ViewExtension.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

extension View {
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}
