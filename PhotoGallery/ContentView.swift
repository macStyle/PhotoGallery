//
//  ContentView.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

struct ImageGalleryView: View {
	@Namespace var namespace
	@GestureState private var selectedImageOffset: CGSize = .zero
	@State private var selectedImageIndex: Int? = nil
	@State private var selectedImageScale: CGFloat = 1
	@State private var isDragging: Bool = false
	@State private var isClosing: Bool = true
	private var gridItemLayout = Array(repeating: GridItem(.flexible()), count: 3)
	private let eventImages: [EventImage] = [
		EventImage(id: UUID().uuidString, url: "1", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "2", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "3", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "4", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "4", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "5", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "6", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "7", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "8", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "9", voteCount: 1),
		EventImage(id: UUID().uuidString, url: "10", voteCount: 1)
	]

	var body: some View {
		GeometryReader { geo in
			let geoWidth = geo.size.width
			let geoHeight = geo.size.height
			ScrollView(.vertical, showsIndicators: true) {
				LazyVGrid(columns: self.gridItemLayout, alignment: .center, spacing: 0.5) {
					ForEach(eventImages) { image in
						GalleryImage(image: image)
							.if(eventImages.firstIndex(of: image) == self.selectedImageIndex, transform: { view in
								view
									.matchedGeometryEffect(id: eventImages.firstIndex(of: image), in: self.namespace, isSource: self.isClosing ? true : false)
									.opacity(0)
							})
								.aspectRatio(contentMode: .fill)
								.frame(width: (geoWidth/2.9) - 3, height: (geoWidth/2.9) - 3, alignment: .center)
								.clipped()
								.contentShape(Rectangle())
								.onTapGesture {
								DispatchQueue.main.async {
									withAnimation(.spring()) {
										self.selectedImageIndex = eventImages.firstIndex(of: image)
										self.isClosing = false
									}
								}
							}
					}
				}
			}
			.zIndex(0)
			
			Color.black.ignoresSafeArea()
				.opacity(self.selectedImageIndex == nil || self.selectedImageOffset.height > 30 ? 0 : 1)
				.animation(.spring(), value: self.selectedImageOffset)
				.zIndex(1)
			
			ImageFSV(selectedImageOffset: self.selectedImageOffset, selectedImageIndex: self.$selectedImageIndex, selectedImageScale: self.$selectedImageScale, isClosing: self.$isClosing, isDragging: self.$isDragging, eventImages: self.eventImages, geoWidth: geoWidth, geoHeight: geoHeight, namespace: self.namespace)
		}
		.preferredColorScheme(.dark)
	}
}

struct ImageFSV: View {
	@GestureState var selectedImageOffset: CGSize
	@Binding var selectedImageIndex: Int?
	@Binding var selectedImageScale: CGFloat
	@Binding var isClosing: Bool
	@Binding var isDragging: Bool
	public var eventImages: [EventImage]
	public let geoWidth: CGFloat
	public let geoHeight: CGFloat
	public let namespace: Namespace.ID
	var body: some View {
		if let index = self.selectedImageIndex {
			LazyHStack(spacing: 0) {
				ForEach(eventImages) { image in
					GalleryImage(image: image)
						.matchedGeometryEffect(id: eventImages.firstIndex(of: image), in: self.namespace, isSource: true)
						.aspectRatio(contentMode: .fit)
						.frame(width: geoWidth, height: geoHeight, alignment: .center)
						.scaleEffect(eventImages.firstIndex(of: image) == index ? self.selectedImageScale : 1)
						.offset(x: -CGFloat(index) * geoWidth)
						.offset(eventImages.firstIndex(of: image) == index ? self.selectedImageOffset : .zero)
				}
			}
			.animation(.easeOut(duration: 0.25), value: index)
			.highPriorityGesture(
				DragGesture()
					.onChanged({ value in
						DispatchQueue.main.async {
							if !self.isClosing && (value.translation.width > 5 || value.translation.width < -5) {
								self.isDragging = true
							}
							if !self.isDragging && (value.translation.height > 5 || value.translation.height < -5) {
								self.isClosing = true
							}
						}
					})
					.updating(self.$selectedImageOffset, body: { value, state, _ in
						if self.isDragging {
							state = CGSize(width: value.translation.width, height: 0)
						} else if self.isClosing {
							state = CGSize(width: value.translation.width, height: value.translation.height)
						}
					})
					.onEnded({ value in
						DispatchQueue.main.async {
							self.isDragging = false
							if value.translation.height > 150 && self.isClosing {
								withAnimation(.spring()) {
									self.selectedImageIndex = nil
									self.isClosing = true
								}
							} else {
								self.isClosing = false
								let offset = value.translation.width / geoWidth*6
								if offset > 0.5 && self.selectedImageIndex! > 0 {
									self.selectedImageIndex! -= 1
								} else if offset < -0.5 && self.selectedImageIndex! < (eventImages.count - 1) {
									self.selectedImageIndex! += 1
								}
							}
						}
					})
			)
			.onChange(of: self.selectedImageOffset) { imageOffset in
				DispatchQueue.main.async {
					let progress = imageOffset.height / geoHeight
					if 1 - progress > 0.5 {
						self.selectedImageScale = 1 - progress
					}
				}
			}
			.zIndex(2)
		}
	}
}

struct GalleryImage: View {
	public var image: EventImage
	var body: some View {
		Image(image.url)
			.resizable()
	}
}
