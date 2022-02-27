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
	@State var showFSVTab: Bool = false
	@State var didFinishClosingImage: Bool = true
	@State var selectedImageIndex: Int? = nil
	@State var selectedImageScale: CGFloat = 1
	@State var showImageFSV: Bool = false
	@State var isSwiping: Bool = false
	@State var isSelecting: Bool = false
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
			let geoHeightSafeArea = geo.size.height - (geo.safeAreaInsets.top - geo.safeAreaInsets.bottom)
			Color.black.ignoresSafeArea()
				.zIndex(0)
			ScrollView(.vertical, showsIndicators: true) {
				ScrollViewReader { scroll in
					LazyVGrid(columns: self.gridItemLayout, alignment: .center, spacing: 0.5) {
						ForEach(eventImages) { image in
							Image(image.url)
								.resizable()
								.matchedGeometryEffect(id: eventImages.firstIndex(of: image), in: self.namespace, isSource: true)
								.aspectRatio(contentMode: .fill)
								.frame(width: (geoWidth/2.9) - 3, height: (geoWidth/2.9) - 3, alignment: .center)
								.clipped()
								.contentShape(Rectangle())
								.opacity(eventImages.firstIndex(of: image) == selectedImageIndex ? 0 : 1)
								.id(eventImages.firstIndex(of: image))
								.onChange(of: self.isSwiping) { value in
									scroll.scrollTo(self.selectedImageIndex, anchor: .center)
								}
								.onTapGesture {
									DispatchQueue.main.async {
										if self.didFinishClosingImage {
											withAnimation(.easeIn(duration: 0.2)) {
												self.isSelecting = true
												self.showImageFSV = true
												self.selectedImageIndex = eventImages.firstIndex(of: image)
												self.showFSVTab = true
											}
										}
									}
								}
//								.onAppear {
//									DispatchQueue.main.async {
//										if self.didFinishClosingImage {
//											withAnimation(.easeIn(duration: 0.2)) {
//												self.showFSV = true
//												self.selectedImageIndex = eventImages.firstIndex(of: image)
//											}
//										}
//									}
//								}
						}
					}
				}
			}
			.zIndex(1)
			
			ImageFSV(selectedImageOffset: self.selectedImageOffset, didFinishClosingImage: self.$didFinishClosingImage, showImageFSV: self.$showImageFSV, selectedImageIndex: self.$selectedImageIndex, selectedImageScale: self.$selectedImageScale, isSelecting: self.$isSelecting, isSwiping: self.$isSwiping, showFSVTab: self.$showFSVTab, eventImages: self.eventImages, geoWidth: geoWidth, geoHeightSafeArea: geoHeightSafeArea, namespace: self.namespace)
		}
		.preferredColorScheme(.dark)
	}
}

struct ImageFSV: View {
	@GestureState var selectedImageOffset: CGSize
	@State private var backgroundOpacity: CGFloat = 1
	@Binding var didFinishClosingImage: Bool
	@Binding var showImageFSV: Bool
	@Binding var selectedImageIndex: Int?
	@Binding var selectedImageScale: CGFloat
	@Binding var isSelecting: Bool
	@Binding var isSwiping: Bool
	@Binding var showFSVTab: Bool
	public var eventImages: [EventImage]
	public let geoWidth: CGFloat
	public let geoHeightSafeArea: CGFloat
	public let namespace: Namespace.ID
	var body: some View {
		if self.showImageFSV, let index = self.selectedImageIndex {
			LazyHStack(spacing: 0) {
				ForEach(eventImages) { image in
					Image(image.url)
						.resizable()
						.cornerRadius(5)
						.if(self.eventImages.firstIndex(of: image) == self.selectedImageIndex && self.isSelecting, transform: { view in
							view
								.matchedGeometryEffect(id: self.selectedImageIndex, in: self.namespace, isSource: true)
						})
							.aspectRatio(contentMode: .fit)
							.frame(width: geoWidth, height: geoHeightSafeArea, alignment: .center)
							.scaleEffect(self.isSwiping ? 0.98 : 1.0)
							.scaleEffect(eventImages.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageScale : 1)
							.offset(x: -CGFloat(index) * geoWidth)
							.offset(self.selectedImageOffset)
							.opacity(eventImages.firstIndex(of: image) != self.selectedImageIndex && self.isSelecting ? 0 : 1)
							.shadow(color: eventImages.firstIndex(of: image) == self.selectedImageIndex ? Color.black.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 0)
				}
			}
			.background(
				Color.black.ignoresSafeArea()
					.opacity(self.backgroundOpacity)
			)
			.animation(.easeOut(duration: 0.25), value: self.selectedImageOffset.width)
			.highPriorityGesture(
				DragGesture()
					.onChanged({ value in
						DispatchQueue.main.async {
							if !self.isSelecting && (value.translation.width > 5 || value.translation.width < -5) {
								withAnimation(.easeInOut(duration: 0.2)) {
									self.isSwiping = true
								}
							} else if !self.isSwiping && (value.translation.height > 5 || value.translation.height < -5) {
								self.isSelecting = true
								self.showFSVTab = false
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
							self.selectedImageIndex = index
							if value.translation.height > 150 && self.isSelecting {
								withAnimation(.interactiveSpring()) {
									self.didFinishClosingImage = false
									self.showImageFSV = false
									self.showFSVTab = false
									self.selectedImageIndex = nil
								}
							} else if self.isSwiping {
								let offset = value.translation.width / geoWidth*6
								if offset > 0.5 && index > 0 {
									self.selectedImageIndex! -= 1
								} else if offset < -0.5 && index < (eventImages.count - 1) {
									self.selectedImageIndex! += 1
								}
							}
							self.showFSVTab = true
							self.isSelecting = false
							self.isSwiping = false
						}
					})
			)
			.simultaneousGesture(TapGesture(count: 2).onEnded {
				print("LIKE")
			})
			.gesture(TapGesture(count: 1).onEnded {
				self.showFSVTab.toggle()
			})
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					self.isSelecting = false
				}
			}
			.onDisappear {
				self.didFinishClosingImage = true
			}
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
					
					let progress = imageOffset.height / geoHeightSafeArea
					if 1 - progress > 0.5 {
						self.selectedImageScale = 1 - progress
					}
				}
			}
			.zIndex(2)
		}
	}
}

struct ImageGallerysView_Previews: PreviewProvider {
	static var previews: some View {
		ImagesGalleryView()
	}
}
