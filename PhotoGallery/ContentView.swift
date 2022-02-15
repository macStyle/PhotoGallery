//
//  ContentView.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

struct ImagesGalleryView: View {
	@Namespace var namespace
	@GestureState private var selectedImageOffset: CGSize = .zero
	@State private var showFSV: Bool = false
	@State private var selectedImageIndex: Int? = nil
	@State private var selectedImageScale: CGFloat = 1
	@State private var isSwiping: Bool = false
	@State private var isSelecting: Bool = false
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
						Image(image.url)
							.resizable()
							.matchedGeometryEffect(id: eventImages.firstIndex(of: image), in: self.namespace, isSource: self.showFSV ? false : true)
							.aspectRatio(contentMode: .fill)
							.frame(width: (geoWidth/2.9) - 3, height: (geoWidth/2.9) - 3, alignment: .center)
							.clipped()
							.contentShape(Rectangle())
							.onTapGesture {
								DispatchQueue.main.async {
									withAnimation(.spring()) {
										self.showFSV = true
										self.selectedImageIndex = eventImages.firstIndex(of: image)
									}
								}
							}
					}
				}
			}
			.zIndex(0)
			
			ImageFSV(selectedImageOffset: self.selectedImageOffset, showFSV: self.$showFSV, selectedImageIndex: self.$selectedImageIndex, selectedImageScale: self.$selectedImageScale, isSelecting: self.$isSelecting, isSwiping: self.$isSwiping, eventImages: self.eventImages, geoWidth: geoWidth, geoHeight: geoHeight, namespace: self.namespace)
				.zIndex(2)
		}
		.preferredColorScheme(.dark)
	}
}

struct ImageFSV: View {
	@GestureState var selectedImageOffset: CGSize
	@State private var backgroundOpacity: CGFloat = 1
	@Binding var showFSV: Bool
	@Binding var selectedImageIndex: Int?
	@Binding var selectedImageScale: CGFloat
	@Binding var isSelecting: Bool
	@Binding var isSwiping: Bool
	public var eventImages: [EventImage]
	public let geoWidth: CGFloat
	public let geoHeight: CGFloat
	public let namespace: Namespace.ID
	var body: some View {
		if self.showFSV, let index = self.selectedImageIndex {
			Color.black.ignoresSafeArea()
				.opacity(self.backgroundOpacity)
				.zIndex(1)
			LazyHStack(spacing: 0) {
				ForEach(eventImages) { image in
					Image(image.url)
						.resizable()
						.if(self.eventImages.firstIndex(of: image) == self.selectedImageIndex && self.isSelecting, transform: { view in
							view
								.matchedGeometryEffect(id: self.selectedImageIndex, in: self.namespace, isSource: true)
						})
							.aspectRatio(contentMode: .fit)
							.frame(width: geoWidth, height: geoHeight, alignment: .center)
							.scaleEffect(eventImages.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageScale : 1)
							.offset(x: -CGFloat(index) * geoWidth)
							.offset(eventImages.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageOffset : .zero)
				}
			}
			.animation(.easeOut(duration: 0.25), value: index)
			.highPriorityGesture(
				DragGesture()
					.onChanged({ value in
						DispatchQueue.main.async {
							if !self.isSelecting && (value.translation.width > 5 || value.translation.width < -5) {
								self.isSwiping = true
							}
							if !self.isSwiping && (value.translation.height > 5 || value.translation.height < -5) {
								self.isSelecting = true
							}
						}
					})
					.updating(self.$selectedImageOffset, body: { value, state, _ in
						if self.isSwiping {
							state = CGSize(width: value.translation.width, height: 0)
						} else if self.isSelecting {
							state = CGSize(width: value.translation.width, height: value.translation.height)
						}
					})
					.onEnded({ value in
						DispatchQueue.main.async {
							self.isSwiping = false
							if value.translation.height > 150 && self.isSelecting {
								withAnimation(.spring()) {
									self.showFSV = false
									self.selectedImageIndex = nil
								}
							} else {
								self.isSelecting = false
								let offset = value.translation.width / geoWidth*6
								if offset > 0.5 && self.selectedImageIndex ?? 0 > 0 {
									self.selectedImageIndex! -= 1
								} else if offset < -0.5 && self.selectedImageIndex ?? 0 < (eventImages.count - 1) {
									self.selectedImageIndex! += 1
								}
							}
						}
					})
			)
			.onChange(of: self.selectedImageOffset) { imageOffset in
				DispatchQueue.main.async {
					withAnimation(.easeIn) {
						switch imageOffset.height {
							case 50..<70:
								self.backgroundOpacity = 0.8
							case 70..<90:
								self.backgroundOpacity = 0.6
							case 90..<110:
								self.backgroundOpacity = 0.4
							case 110..<130:
								self.backgroundOpacity = 0.2
							case 130..<1000:
								self.backgroundOpacity = 0.0
							default:
								self.backgroundOpacity = 1.0
						}
					}
					
					let progress = imageOffset.height / geoHeight
					if 1 - progress > 0.5 {
						self.selectedImageScale = 1 - progress
					}
				}
			}
		}
	}
}
