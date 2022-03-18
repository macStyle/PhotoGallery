//
//  BlurView.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 3/8/22.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
	var effect: UIBlurEffect.Style
	
	func makeUIView(context: Context) -> UIVisualEffectView {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: self.effect))
		return view
	}
	
	func updateUIView(_ uiView: UIViewType, context: Context) {}
}
