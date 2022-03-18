//
//  ContentView.swift
//  PhotoGallery
//
//  Created by Trevor Welsh on 2/14/22.
//

import SwiftUI

struct ImagesGalleryView: View {
	@Namespace var namespace
	@Environment(\.presentationMode) var presentationMode
	@GestureState var cardOffset: CGSize = .zero
	@State var selectedMedia: EventContent? = nil
	@State var scrollVOffset: Int = 0
	@State private var backgroundOpacity: Double = 0.0
	@State private var cardScale: Double = 1.0
	private let gridItemLayout = Array(repeating: GridItem(.flexible()), count: 4)
	private let aspectRatio: CGFloat = 405 / 720
	private let eventContents: [EventContent] = [
		EventContent(id: UUID().uuidString, url: "1", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "3", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "3", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "5", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "5", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "6", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "7", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "8", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "9", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "10", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "11", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "12", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "13", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "14", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "16", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "16", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "17", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "18", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "19", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "20", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "21", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "22", voteCount: 1),
		EventContent(id: UUID().uuidString, url: "23", voteCount: 1)
	]
	var body: some View {
		GeometryReader { geo in
			let galleryMediaWidth: CGFloat = (geo.size.width/3.8) - 4
			Color.black.ignoresSafeArea()
				.zIndex(0)
			ScrollViewReader { scroll in
				ScrollView(.vertical, showsIndicators: true) {
					LazyVGrid(columns: self.gridItemLayout, alignment: .center, spacing: 1.0) {
						ForEach(self.eventContents) { media in
							Button {
								if self.selectedMedia == nil {
									self.selectedMedia = media
									self.backgroundOpacity = 1.0
									self.cardScale = 1.0
								}
							} label: {
								MediaCardView(eventContent: media)
									.aspectRatio(contentMode: .fill)
									.frame(width: galleryMediaWidth, height: galleryMediaWidth / self.aspectRatio, alignment: .center)
									.clipped()
									.contentShape(Rectangle())
									.scaleEffect(self.selectedMedia == media ? self.cardScale : 1.0)
									.offset(self.cardOffset)
									.matchedGeometryEffect(id: media.id, in: self.namespace)
									.id(media)
									.onChange(of: self.scrollVOffset, perform: { newValue in
										DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
											scroll.scrollTo(selectedMedia?.id, anchor: .center)
										}
									})
							}
						}
					}
				}
				.zIndex(1)
			}
			
			if self.selectedMedia != nil {
				Color.black
					.opacity(self.backgroundOpacity)
					.animation(.linear, value: self.backgroundOpacity)
					.ignoresSafeArea()
					.zIndex(2)
			}
			
			MediaCardFSV(cardOffset: self.cardOffset, scrollVOffset: self.$scrollVOffset, backgroundOpacity: self.$backgroundOpacity, selectedMedia: self.$selectedMedia, cardScale: self.$cardScale, geoSize: geo.size, namespace: self.namespace, eventContents: self.eventContents)
				.zIndex(3)
			
			if self.selectedMedia == nil {
				VStack {
					HStack(alignment: .bottom) {
						Button {
							self.presentationMode.wrappedValue.dismiss()
						} label: {
							Image(systemName: "chevron.left")
								.font(.system(size: 20).bold())
								.foregroundColor(Color.white)
								.padding(12)
								.background(BlurView(effect: .systemThinMaterialDark))
								.clipShape(Circle())
						}
						Spacer()
						Button {
//							self.showCustomMediaPicker = true
						} label: {
							Image(systemName: "plus")
								.font(.system(size: 20).bold())
								.foregroundColor(Color.white)
								.padding(12)
								.background(BlurView(effect: .systemThinMaterialDark))
								.clipShape(Circle())
						}
					}
					.padding(.horizontal, 12)
					Spacer()
				}
				.zIndex(4)
			}
		}
		.animation(.interpolatingSpring(mass: 0.3, stiffness: 170, damping: 30, initialVelocity: 0.0), value: self.selectedMedia)
		.preferredColorScheme(.dark)
		.navigationBarHidden(true)
	}
}

struct MediaCardFSV: View {
	@GestureState var cardOffset: CGSize
	@State private var didLoadOriginalMedia: Bool = false
	@State private var showLikeAnimation: Bool = false
	@State private var likedContent: [EventContent] = []
	@Binding var scrollVOffset: Int
	@Binding var backgroundOpacity: Double
	@Binding var selectedMedia: EventContent?
	@Binding var cardScale: Double
	public let geoSize: CGSize
	public let namespace: Namespace.ID
	public let eventContents: [EventContent]
	var body: some View {
		if let selectedMedia = selectedMedia {
			ScrollViewReader { scroll in
				OffsettableScrollView(axes: .vertical, showsIndicator: true) { point in
					DispatchQueue.main.async {
						self.scrollVOffset = Int(point.y / self.geoSize.height)
						self.selectedMedia = self.eventContents[-self.scrollVOffset]
					}
				} content: {
					LazyVStack(spacing: 0) {
						ForEach(self.eventContents) { image in
							VStack(spacing: 12) {
								MediaCardView(eventContent: image)
									.aspectRatio(contentMode: .fit)
									.cornerRadius(15)
									.overlay(
										Image(systemName: "heart.fill")
											.font(.system(size: 100))
											.foregroundColor(Color.white)
											.shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 0)
											.scaleEffect(self.showLikeAnimation ? 1.0 : 0.8)
											.opacity(self.showLikeAnimation && image == self.likedContent.last ? 1.0 : 0.0)
											.animation(.interactiveSpring(), value: self.showLikeAnimation)
											.onChange(of: self.showLikeAnimation, perform: { show in
												if show {
													DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
														self.showLikeAnimation = false
													}
												}
											})
									)
								HStack {
									Button {
										if let index = self.likedContent.firstIndex(of: image), self.likedContent.contains(image) {
											self.likedContent.remove(at: index)
										} else {
											self.likedContent.append(image)
											self.showLikeAnimation = true
										}
									} label: {
										Image(systemName: self.likedContent.contains(image) ? "heart.fill" : "heart")
											.font(.system(size: 24))
											.foregroundColor(Color.white)
									}

									Button {
										// save to camera roll
									} label: {
										Image(systemName: "square.and.arrow.down")
											.font(.system(size: 24))
											.foregroundColor(Color.white)
									}

									Spacer()
									Text("User Full Name")
								}
								.padding(.horizontal, 12)
								.opacity(self.backgroundOpacity)
							}
							.if(selectedMedia == image && self.cardOffset != .zero, transform: { view in
								view
									.shadow(color: Color.black, radius: 20, x: 0, y: 0)
									.matchedGeometryEffect(id: image.id, in: self.namespace)
							})
								.frame(width: self.geoSize.width, height: self.geoSize.height, alignment: .center)
								.scaleEffect(self.cardScale)
								.offset(self.cardOffset)
								.opacity(selectedMedia.id != image.id && self.cardOffset != .zero ? 0.0 : 1.0)
								.id(image)
								.simultaneousGesture(
									TapGesture(count: 2)
										.onEnded({ _ in
											if self.likedContent.contains(image) {
												self.showLikeAnimation = true
											} else {
												self.likedContent.append(image)
												self.showLikeAnimation = true
											}
											print(self.likedContent)
										})
								)
						}
					}
					.onAppear {
						scroll.scrollTo(selectedMedia.id, anchor: .center)
					}
				}
			}
			.highPriorityGesture(
				DragGesture()
					.onChanged({ value in
						let valueWidth: CGFloat = value.translation.width
						switch valueWidth {
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
						
						let progress = valueWidth / geoSize.width
						if 1.0 - progress > 0.8 {
							withAnimation(.linear) {
								self.cardScale = 1.0 - progress
								
							}
						}
					})
					.updating(self.$cardOffset, body: { value, state, _ in
						if value.translation.width > 0 {
							state = value.translation
						}
					})
					.onEnded({ value in
						let valueWidth: CGFloat = value.translation.width
						if valueWidth > 75 {
							self.didLoadOriginalMedia = false
							self.selectedMedia = nil
						} else {
							self.cardScale = 1.0
							self.backgroundOpacity = 1.0
						}
					})
			)
			.onChange(of: self.scrollVOffset) { newValue in
				self.backgroundOpacity = 1.0
				self.cardScale = 1.0
			}
//			.ignoresSafeArea()
		}
		
		//	private func rectReader() -> some View {
		//		return GeometryReader { (geometry) -> AnyView in
		//			let imageSize = geometry.size
		//			DispatchQueue.main.async {
		//				print(">> \(imageSize)") // use image actual size in your calculations
		//				self.imageSize = imageSize
		//			}
		//			return AnyView(Rectangle().fill(Color.clear))
		//		}
	}
}

struct MediaCardFSVNavbar: View {
	@State private var showNavBarAfterDelay: Bool = false
	@Binding var selectedMedia: EventContent?
	@Binding var didLoadOriginalMedia: Bool
	@Binding var cardScale: Double
	public let geoSize: CGSize
	var body: some View {
		VStack(spacing: 0) {
			HStack(alignment: .bottom) {
				Button {
					self.cardScale = 0.8
					self.didLoadOriginalMedia = false
					self.selectedMedia = nil
				} label: {
					Image(systemName: "chevron.left")
						.font(.system(size: 20).bold())
						.foregroundColor(Color.white)
						.padding(12)
						.background(BlurView(effect: .systemThinMaterialDark))
						.clipShape(Circle())
				}
				Spacer()
			}
			.padding(.horizontal, 12)
			.opacity(self.showNavBarAfterDelay ? 1.0 : 0.0)
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.showNavBarAfterDelay = true
				}
			}
			Spacer()
		}
	}
}

struct MediaCardView: View {
	public let eventContent: EventContent?
	var body: some View {
//		GeometryReader { geo in
			Image(eventContent?.url ?? "")
				.resizable()
//				.aspectRatio(contentMode: .fit)
//				.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
//				.onAppear {
//					print(geo.size)
//				}
//		}
	}
}

private struct OffsetPreferenceKey: PreferenceKey {
	
	static var defaultValue: CGPoint = .zero
	
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

struct OffsettableScrollView<T: View>: View {
	let axes: Axis.Set
	let showsIndicator: Bool
	let onOffsetChanged: (CGPoint) -> Void
	let content: T
	
	init(axes: Axis.Set = .vertical,
		 showsIndicator: Bool = true,
		 onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
		 @ViewBuilder content: () -> T
	) {
		self.axes = axes
		self.showsIndicator = showsIndicator
		self.onOffsetChanged = onOffsetChanged
		self.content = content()
	}
	
	var body: some View {
		ScrollView(axes, showsIndicators: showsIndicator) {
			GeometryReader { proxy in
				Color.clear.preference(
					key: OffsetPreferenceKey.self,
					value: proxy.frame(
						in: .named("ScrollViewOrigin")
					).origin
				)
			}
			.frame(width: 0, height: 0)
			content
		}
		.coordinateSpace(name: "ScrollViewOrigin")
		.onPreferenceChange(OffsetPreferenceKey.self,
							perform: onOffsetChanged)
	}
}



//struct MediaCardFSVTabView: View {
//	@State private var dataLoaded: Bool = false
//	@Binding var showFSVTab: Bool
//	@Binding var selectedImageIndex: Int?
//	public let EventContents: [EventContent]
//	public let geoSize: CGSize
//	var body: some View {
//		VStack {
//			if let index = self.selectedImageIndex {
//				Spacer()
//				HStack {
//					Button {
//						//					<#code#>
//					} label: {
//						Image(systemName: "heart")
//							.font(.system(size: 24))
//							.foregroundColor(Color.theme.textLight)
//					}
//					Text("\(self.EventContents[index].voteCount ?? 1)")
//						.font(Font.pjsMedium(size: 16))
//						.foregroundColor(Color.theme.textLight)
//					Spacer()
//				}
//				.padding(.horizontal, 30)
//				.frame(width: self.geoSize.width, height: 40, alignment: .top)
//				.padding(.top, 12)
//				.opacity(self.dataLoaded ? 1 : 0)
//				.animation(.easeIn, value: self.dataLoaded)
//				.offset(y: self.showFSVTab ? 0 : self.geoSize.height)
//				.onAppear {
//					self.dataLoaded = true
//				}
//				.onDisappear {
//					self.dataLoaded = false
//				}
//			}
//		}
//		.frame(width: self.geoSize.width, height: self.geoSize.height)
//		.animation(.default, value: self.showFSVTab)
//	}
//}

//private struct OffsetPreferenceKey: PreferenceKey {
//
//	static var defaultValue: CGPoint = .zero
//
//	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
//}
//
//struct OffsettableScrollView<T: View>: View {
//	let axes: Axis.Set
//	let showsIndicator: Bool
//	let onOffsetChanged: (CGPoint) -> Void
//	let content: T
//
//	init(axes: Axis.Set = .vertical,
//		 showsIndicator: Bool = true,
//		 onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
//		 @ViewBuilder content: () -> T
//	) {
//		self.axes = axes
//		self.showsIndicator = showsIndicator
//		self.onOffsetChanged = onOffsetChanged
//		self.content = content()
//	}
//
//	var body: some View {
//		ScrollView(axes, showsIndicators: showsIndicator) {
//			GeometryReader { proxy in
//				Color.clear.preference(
//					key: OffsetPreferenceKey.self,
//					value: proxy.frame(
//						in: .named("ScrollViewOrigin")
//					).origin
//				)
//			}
//			.frame(width: 0, height: 0)
//			content
//		}
//		.coordinateSpace(name: "ScrollViewOrigin")
//		.onPreferenceChange(OffsetPreferenceKey.self,
//							perform: onOffsetChanged)
//	}
//}
//
//struct ImagesGalleryView: View {
//	@Namespace var namespace
//	@GestureState var cardOffset: CGSize = .zero
//	@State var selectedMedia: EventContent? = nil
//	@State var shouldScrollToNewPosition: Bool = false
//	@State var columns: Int = 3
//	@State private var backgroundOpacity: Double = 1.0
//	@State private var cardScale: Double = 1.0
//	private let gridItemLayout = Array(repeating: GridItem(.flexible()), count: 3)
//	private let EventContents: [EventContent] = [
//		EventContent(id: UUID().uuidString, url: "1", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "2", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "3", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "4", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "4", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "5", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "6", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "7", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "8", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "9", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "10", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "11", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "12", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "13", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "14", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "15", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "16", voteCount: 1)
//	]
//
//	var body: some View {
//		GeometryReader { geo in
//			Color.black.ignoresSafeArea()
//				.zIndex(0)
//			StaggeredGrid(shouldScrollToNewPosition: self.$shouldScrollToNewPosition, selectedMedia: self.$selectedMedia, columns: self.$columns, showsIndicators: true, spacing: 4, list: self.EventContents, content: { image in
//				Button {
//					if self.selectedMedia == nil {
//						self.selectedMedia = image
//						self.cardScale = 1.0
//						self.backgroundOpacity = 1.0
////						self.columns = 1
////						self.shouldScrollToNewPosition = true
//					}
//				} label: {
//					MediaCardView(EventContent: image)
//						.matchedGeometryEffect(id: image.id, in: self.namespace)
//						.scaleEffect(self.selectedMedia == image ? self.cardScale : 1.0)
//						.offset(self.cardOffset)
//				}
//			})
//				.zIndex(1)
//			if self.selectedMedia != nil {
//				Color.black
//					.opacity(self.backgroundOpacity)
//					.ignoresSafeArea()
//					.zIndex(2)
//			}
//			MediaCardFSV(cardOffset: self.cardOffset, backgroundOpacity: self.$backgroundOpacity, selectedMedia: self.$selectedMedia, cardScale: self.$cardScale, shouldScrollToNewPosition: self.$shouldScrollToNewPosition, geoSize: geo.size, namespace: self.namespace, EventContents: self.EventContents)
//				.zIndex(3)
//		}
////		.animation(.easeOut, value: self.shouldScrollToNewPosition)
//				.animation(.interpolatingSpring(mass: 0.3, stiffness: 170, damping: 30, initialVelocity: 0.0), value: self.selectedMedia)
//		.preferredColorScheme(.dark)
//		.navigationBarHidden(true)
//	}
//}
//
//struct MediaCardView: View {
//	public let EventContent: EventContent
//	var body: some View {
//		Image(self.EventContent.url)
//			.resizable()
//			.aspectRatio(contentMode: .fit)
//			.cornerRadius(5)
//	}
//}
//
//struct MediaCardFSV: View {
//	@GestureState var cardOffset: CGSize
//	@State private var didLoadOriginalMedia: Bool = false
//	@State private var scrollVOffset: Int = 0
//	@State private var originalIndex: Int = 0
//	@Binding var backgroundOpacity: Double
//	@Binding var selectedMedia: EventContent?
//	@Binding var cardScale: Double
//	@Binding var shouldScrollToNewPosition: Bool
//	public let geoSize: CGSize
//	public let namespace: Namespace.ID
//	public let EventContents: [EventContent]
//	var body: some View {
//		if let selectedMedia = selectedMedia, let index = self.EventContents.firstIndex(of: selectedMedia) {
//			ZStack {
//				ScrollViewReader { scroll in
//					OffsettableScrollView(axes: .vertical, showsIndicator: true) { point in
//						DispatchQueue.main.async {
//							self.scrollVOffset = Int(point.y / self.geoSize.height)
//							self.selectedMedia = self.EventContents[-self.scrollVOffset]
//							if self.scrollVOffset != 0 {
//								if -self.scrollVOffset > (self.originalIndex + 2) {
//									self.shouldScrollToNewPosition = true
//								} else if -self.scrollVOffset < (self.originalIndex - 2) {
//									self.shouldScrollToNewPosition = true
//								}
//							}
//						}
//					} content: {
//						LazyVStack {
//							ForEach(self.EventContents) { image in
//								MediaCardView(EventContent: image)
//									.frame(width: geoSize.width, height: geoSize.height)
//									.opacity(selectedMedia.id != image.id && self.cardOffset != .zero ? 0.0 : 1.0)
//									.opacity(self.didLoadOriginalMedia ? 1.0 : 0.0)
//									.id(image)
//									.onTapGesture {
//										self.didLoadOriginalMedia = false
//										self.selectedMedia = nil
//									}
//							}
//						}
//						.onAppear {
//							scroll.scrollTo(selectedMedia, anchor: .center)
//							self.originalIndex = index
//						}
//					}
//				}
//				.zIndex(0)
//
//				if !self.didLoadOriginalMedia || self.cardOffset != .zero {
//					MediaCardView(EventContent: selectedMedia)
//						.matchedGeometryEffect(id: selectedMedia.id, in: self.namespace, isSource: true)
//						.frame(width: self.geoSize.width, height: self.geoSize.height)
//						.opacity(self.cardOffset != .zero ? 0.0 : 1.0)
//						.onAppear {
//							if self.cardOffset == .zero {
//								DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//									self.didLoadOriginalMedia = true
//								}
//							}
//						}
//						.zIndex(1)
//				}
//			}
//			.frame(width: self.geoSize.width, height: self.geoSize.height)
//			.scaleEffect(self.cardScale)
//			.offset(self.cardOffset)
//			.animation(.linear, value: self.cardOffset)
//			.highPriorityGesture(
//				DragGesture()
//					.onChanged({ value in
//						let valueWidth: CGFloat = value.translation.width
//						withAnimation(.easeIn) {
//							switch valueWidth {
//								case 50..<70:
//									self.backgroundOpacity = 0.8
//								case 70..<90:
//									self.backgroundOpacity = 0.6
//								case 90..<110:
//									self.backgroundOpacity = 0.4
//								case 110..<130:
//									self.backgroundOpacity = 0.2
//								case 130..<1000:
//									self.backgroundOpacity = 0.0
//								default:
//									self.backgroundOpacity = 1.0
//							}
//						}
//
//						let progress = valueWidth / geoSize.width
//						if 1 - progress > 0.5 {
//							self.cardScale = 1 - progress
//						}
//					})
//					.updating(self.$cardOffset, body: { value, state, _ in
//						if value.translation.width > 0 {
//							state = value.translation
//						}
//					})
//					.onEnded({ value in
//						let valueWidth: CGFloat = value.translation.width
//						if valueWidth > 75 {
//							self.didLoadOriginalMedia = false
//							self.selectedMedia = nil
//						} else {
//							self.cardScale = 1.0
//							self.backgroundOpacity = 1.0
//						}
//					})
//			)
//			.onChange(of: self.scrollVOffset) { newValue in
//				self.backgroundOpacity = 1.0
//				self.cardScale = 1.0
//			}
//		}
//	}
//}
//
//struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
//	@Binding var shouldScrollToNewPostion: Bool
//	@Binding var selectedMedia: EventContent?
//	@Binding var columns: Int
//	public let content: (T) -> Content
//	public let list: [T]
//	public let showsIndicators: Bool
//	public let spacing: CGFloat
//	private var originalMediaIndex: Int = 0
//	init(shouldScrollToNewPosition: Binding<Bool>, selectedMedia: Binding<EventContent?>, columns: Binding<Int>, showsIndicators: Bool, spacing: CGFloat, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
//		self._shouldScrollToNewPostion = shouldScrollToNewPosition
//		self._selectedMedia = selectedMedia
//		self._columns = columns
//		self.showsIndicators = showsIndicators
//		self.spacing = spacing
//		self.content = content
//		self.list = list
//	}
//
//	var body: some View {
//		ScrollViewReader { scroll in
//			ScrollView(.vertical, showsIndicators: self.showsIndicators) {
//				HStack(alignment: .top, spacing: self.spacing) {
//					ForEach(self.setupList(), id: \.self) { columns in
//						LazyVStack(spacing: self.spacing) {
//							ForEach(columns) { i in
//								content(i)
//									.id(i)
//							}
//						}
//					}
//				}
//			}
//			.onChange(of: self.shouldScrollToNewPostion) { shouldScroll in
//				if shouldScroll {
//					scroll.scrollTo(self.selectedMedia, anchor: .trailing)
//					self.shouldScrollToNewPostion = false
//				}
//			}
//		}
//	}
//
//	private func setupList() -> [[T]] {
//		var gridArray: [[T]] = Array(repeating: [], count: self.columns)
//		var currentIndex: Int = 0
//		for i in list {
//			gridArray[currentIndex].append(i)
//			if currentIndex == (self.columns - 1) {
//				currentIndex = 0
//			} else {
//				currentIndex += 1
//			}
//		}
//		return gridArray
//	}
//}
//
//struct ImageFSV: View {
//	@GestureState var selectedImageOffset: CGSize
//	@State private var backgroundOpacity: CGFloat = 1
//	@Binding var didFinishClosingImage: Bool
//	@Binding var showImageFSV: Bool
//	@Binding var selectedImageIndex: Int?
//	@Binding var selectedImageScale: CGFloat
//	@Binding var isSelecting: Bool
//	@Binding var isSwiping: Bool
//	@Binding var showFSVTab: Bool
//	public var EventContents: [EventContent]
//	public let geoWidth: CGFloat
//	public let geoHeightSafeArea: CGFloat
//	public let namespace: Namespace.ID
//
//	var body: some View {
//		if self.showImageFSV, let index = self.selectedImageIndex {
//			LazyVStack(spacing: 0) {
//				ForEach(self.EventContents) { image in
//					Image(image.url)
//						.resizable()
//						.cornerRadius(5)
//						.if(self.EventContents.firstIndex(of: image) == self.selectedImageIndex && self.isSelecting, transform: { view in
//							view
//								.matchedGeometryEffect(id: self.selectedImageIndex, in: self.namespace, isSource: true)
//						})
//							.aspectRatio(contentMode: .fit)
//							.frame(width: geoWidth, height: geoHeightSafeArea, alignment: .center)
//							.scaleEffect(self.isSwiping ? 0.98 : 1.0)
//							.scaleEffect(EventContents.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageScale : 1)
//							.offset(y: -CGFloat(index) * geoHeightSafeArea)
//							.offset(self.selectedImageOffset)
//							.opacity(EventContents.firstIndex(of: image) != self.selectedImageIndex && self.isSelecting ? 0 : 1)
//							.shadow(color: EventContents.firstIndex(of: image) == self.selectedImageIndex ? Color.black.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 0)
//				}
//			}
//			.background(
//				Color.black.ignoresSafeArea()
//					.opacity(self.backgroundOpacity)
//			)
//			.animation(.easeOut(duration: 0.25), value: self.selectedImageOffset.width)
//			.highPriorityGesture(
//				DragGesture()
//					.onChanged({ value in
//						DispatchQueue.main.async {
//							if !self.isSelecting && (value.translation.height > 10 || value.translation.height < -10) {
//								withAnimation(.easeInOut(duration: 0.2)) {
//									self.isSwiping = true
//								}
//							} else if !self.isSwiping && (value.translation.width > 5 || value.translation.width < -5) {
//								self.isSelecting = true
//								self.showFSVTab = false
//							}
//						}
//					})
//					.updating(self.$selectedImageOffset, body: { value, state, _ in
//						if self.isSwiping {
//							state = CGSize(width: value.translation.width, height: 0)
//						} else if self.isSelecting {
//							state = CGSize(width: value.translation.width, height: value.translation.height)
//						}
//					})
//					.onEnded({ value in
//						DispatchQueue.main.async {
//							self.selectedImageIndex = index
//							if value.translation.height > 50 && self.isSelecting {
//								withAnimation(.interactiveSpring()) {
//									self.didFinishClosingImage = false
//									self.showImageFSV = false
//									self.showFSVTab = false
//									self.selectedImageIndex = nil
//								}
//							} else if self.isSwiping {
//								let offset = value.translation.height / geoHeightSafeArea*6
//								if offset > 0.5 && index > 0 {
//									self.selectedImageIndex! -= 1
//								} else if offset < -0.5 && index < (EventContents.count - 1) {
//									self.selectedImageIndex! += 1
//								}
//							}
//							self.showFSVTab = true
//							self.isSelecting = false
//							self.isSwiping = false
//						}
//					})
//			)
//			.simultaneousGesture(TapGesture(count: 2).onEnded {
//				print("LIKE")
//			})
//			.gesture(TapGesture(count: 1).onEnded {
//				self.showFSVTab.toggle()
//			})
//			.onAppear {
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//					self.isSelecting = false
//				}
//			}
//			.onDisappear {
//				self.didFinishClosingImage = true
//			}
//			.onChange(of: self.selectedImageOffset) { imageOffset in
//				DispatchQueue.main.async {
//					withAnimation(.easeIn) {
//						switch imageOffset.height {
//							case 50..<70:
//								self.backgroundOpacity = 0.8
//							case 70..<90:
//								self.backgroundOpacity = 0.6
//							case 90..<110:
//								self.backgroundOpacity = 0.4
//							case 110..<130:
//								self.backgroundOpacity = 0.2
//							case 130..<1000:
//								self.backgroundOpacity = 0.0
//							default:
//								self.backgroundOpacity = 1.0
//						}
//					}
//
//					let progress = imageOffset.height / geoHeightSafeArea
//					if 1 - progress > 0.5 {
//						self.selectedImageScale = 1 - progress
//					}
//				}
//			}
//		}
//	}
//}
//
//struct ImageFSV1: View {
//	@GestureState var selectedImageOffset: CGSize
//	@State private var backgroundOpacity: CGFloat = 1
//	@Binding var didFinishClosingImage: Bool
//	@Binding var showImageFSV: Bool
//	@Binding var selectedImageIndex: Int?
//	@Binding var selectedImageScale: CGFloat
//	@Binding var isSelecting: Bool
//	@Binding var isSwiping: Bool
//	@Binding var showFSVTab: Bool
//	public var EventContents: [EventContent]
//	public let geoWidth: CGFloat
//	public let geoHeightSafeArea: CGFloat
//	public let namespace: Namespace.ID
//	var body: some View {
//		if self.showImageFSV, let index = self.selectedImageIndex {
//			LazyVStack(spacing: 0) {
//				ForEach(self.EventContents) { image in
//					Image(image.url)
//						.resizable()
//						.cornerRadius(5)
//						.if(self.EventContents.firstIndex(of: image) == self.selectedImageIndex && self.isSelecting, transform: { view in
//							view
//								.matchedGeometryEffect(id: self.selectedImageIndex, in: self.namespace, isSource: true)
//						})
//							.aspectRatio(contentMode: .fit)
//							.frame(width: geoWidth, height: geoHeightSafeArea, alignment: .center)
//							.scaleEffect(self.isSwiping ? 0.98 : 1.0)
//							.scaleEffect(EventContents.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageScale : 1)
//							.offset(x: -CGFloat(index) * geoWidth)
//							.offset(self.selectedImageOffset)
//							.opacity(EventContents.firstIndex(of: image) != self.selectedImageIndex && self.isSelecting ? 0 : 1)
//							.shadow(color: EventContents.firstIndex(of: image) == self.selectedImageIndex ? Color.black.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 0)
//				}
//			}
//			.background(
//				Color.black.ignoresSafeArea()
//					.opacity(self.backgroundOpacity)
//			)
//			.animation(.easeOut(duration: 0.25), value: self.selectedImageOffset.width)
//			.highPriorityGesture(
//				DragGesture()
//					.onChanged({ value in
//						DispatchQueue.main.async {
//							if !self.isSelecting && (value.translation.width > 5 || value.translation.width < -5) {
//								withAnimation(.easeInOut(duration: 0.2)) {
//									self.isSwiping = true
//								}
//							} else if !self.isSwiping && (value.translation.height > 10 || value.translation.height < -10) {
//								self.isSelecting = true
//								self.showFSVTab = false
//							}
//						}
//					})
//					.updating(self.$selectedImageOffset, body: { value, state, _ in
//						if self.isSwiping {
//							state = CGSize(width: value.translation.width, height: 0)
//						} else if self.isSelecting {
//							state = CGSize(width: value.translation.width, height: value.translation.height)
//						}
//					})
//					.onEnded({ value in
//						DispatchQueue.main.async {
//							self.selectedImageIndex = index
//							if value.translation.height > 50 && self.isSelecting {
//								withAnimation(.interactiveSpring()) {
//									self.didFinishClosingImage = false
//									self.showImageFSV = false
//									self.showFSVTab = false
//									self.selectedImageIndex = nil
//								}
//							} else if self.isSwiping {
//								let offset = value.translation.width / geoWidth*6
//								if offset > 0.5 && index > 0 {
//									self.selectedImageIndex! -= 1
//								} else if offset < -0.5 && index < (EventContents.count - 1) {
//									self.selectedImageIndex! += 1
//								}
//							}
//							self.showFSVTab = true
//							self.isSelecting = false
//							self.isSwiping = false
//						}
//					})
//			)
//			.simultaneousGesture(TapGesture(count: 2).onEnded {
//				print("LIKE")
//			})
//			.gesture(TapGesture(count: 1).onEnded {
//				self.showFSVTab.toggle()
//			})
//			.onAppear {
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//					self.isSelecting = false
//				}
//			}
//			.onDisappear {
//				self.didFinishClosingImage = true
//			}
//			.onChange(of: self.selectedImageOffset) { imageOffset in
//				DispatchQueue.main.async {
//					withAnimation(.easeIn) {
//						switch imageOffset.height {
//							case 50..<70:
//								self.backgroundOpacity = 0.8
//							case 70..<90:
//								self.backgroundOpacity = 0.6
//							case 90..<110:
//								self.backgroundOpacity = 0.4
//							case 110..<130:
//								self.backgroundOpacity = 0.2
//							case 130..<1000:
//								self.backgroundOpacity = 0.0
//							default:
//								self.backgroundOpacity = 1.0
//						}
//					}
//
//					let progress = imageOffset.height / geoHeightSafeArea
//					if 1 - progress > 0.5 {
//						self.selectedImageScale = 1 - progress
//					}
//				}
//			}
//			.zIndex(2)
//		}
//	}
//}

//struct ImagesGalleryView: View {
//	@Namespace var namespace
//	@GestureState var selectedImageOffset: CGSize = .zero
//	@State var showFSVTab: Bool = false
//	@State var didFinishClosingImage: Bool = true
//	@State var selectedImageIndex: Int? = nil
//	@State var selectedImageScale: CGFloat = 1
//	@State var showImageFSV: Bool = false
//	@State var isSwiping: Bool = false
//	@State var isSelecting: Bool = false
//	private var gridItemLayout = Array(repeating: GridItem(.flexible()), count: 3)
//	private let EventContents: [EventContent] = [
//		EventContent(id: UUID().uuidString, url: "1", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "2", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "3", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "4", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "4", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "5", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "6", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "7", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "8", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "9", voteCount: 1),
//		EventContent(id: UUID().uuidString, url: "10", voteCount: 1)
//	]
//
//	var body: some View {
//		GeometryReader { geo in
//			let geoWidth = geo.size.width
//			let geoHeight = geo.size.height
//			let geoHeightSafeArea = geo.size.height - (geo.safeAreaInsets.top - geo.safeAreaInsets.bottom)
//			Color.black.ignoresSafeArea()
//				.zIndex(0)
////			if !self.showImageFSV {
//				ScrollView(.vertical, showsIndicators: true) {
//					ScrollViewReader { scroll in
//						LazyVGrid(columns: self.gridItemLayout, alignment: .center, spacing: 0.5) {
//							ForEach(self.EventContents) { image in
//								Image(image.url)
//									.resizable()
//									.matchedGeometryEffect(id: self.EventContents.firstIndex(of: image), in: self.namespace, isSource: true)
//									.aspectRatio(contentMode: .fill)
//									.frame(width: (geoWidth/2.9) - 3, height: (geoWidth/2.9) - 3, alignment: .center)
//									.clipped()
//									.contentShape(Rectangle())
//									.opacity(EventContents.firstIndex(of: image) == selectedImageIndex ? 0 : 1)
//									.id(EventContents.firstIndex(of: image))
//									.onChange(of: self.isSwiping) { value in
//										scroll.scrollTo(self.selectedImageIndex, anchor: .center)
//									}
//									.onTapGesture {
//										DispatchQueue.main.async {
//											if self.didFinishClosingImage {
//												withAnimation(.easeIn(duration: 0.2)) {
//													self.isSelecting = true
//													self.showImageFSV = true
//													self.selectedImageIndex = EventContents.firstIndex(of: image)
//													self.showFSVTab = true
//												}
//											}
//										}
//									}
//							}
//						}
//					}
//				}
//				.zIndex(1)
////			}
//
//
//			ImageFSV(selectedImageOffset: self.selectedImageOffset, didFinishClosingImage: self.$didFinishClosingImage, showImageFSV: self.$showImageFSV, selectedImageIndex: self.$selectedImageIndex, selectedImageScale: self.$selectedImageScale, isSelecting: self.$isSelecting, isSwiping: self.$isSwiping, showFSVTab: self.$showFSVTab, EventContents: self.EventContents, geoWidth: geoWidth, geoHeightSafeArea: geoHeightSafeArea, namespace: self.namespace)
//		}
//		.preferredColorScheme(.dark)
//	}
//}
//
//struct ImageFSV: View {
//	@GestureState var selectedImageOffset: CGSize
//	@State private var backgroundOpacity: CGFloat = 1
//	@Binding var didFinishClosingImage: Bool
//	@Binding var showImageFSV: Bool
//	@Binding var selectedImageIndex: Int?
//	@Binding var selectedImageScale: CGFloat
//	@Binding var isSelecting: Bool
//	@Binding var isSwiping: Bool
//	@Binding var showFSVTab: Bool
//	public var EventContents: [EventContent]
//	public let geoWidth: CGFloat
//	public let geoHeightSafeArea: CGFloat
//	public let namespace: Namespace.ID
//	var body: some View {
//		if self.showImageFSV, let index = self.selectedImageIndex {
//			LazyHStack(spacing: 0) {
//				ForEach(EventContents) { image in
//					Image(image.url)
//						.resizable()
//						.cornerRadius(5)
//						.if(self.EventContents.firstIndex(of: image) == self.selectedImageIndex && self.isSelecting, transform: { view in
//							view
//								.matchedGeometryEffect(id: self.selectedImageIndex, in: self.namespace, isSource: true)
//						})
//							.aspectRatio(contentMode: .fit)
//							.frame(width: geoWidth, height: geoHeightSafeArea, alignment: .center)
//							.scaleEffect(self.isSwiping ? 0.98 : 1.0)
//							.scaleEffect(EventContents.firstIndex(of: image) == self.selectedImageIndex ? self.selectedImageScale : 1)
//							.offset(x: -CGFloat(index) * geoWidth)
//							.offset(self.selectedImageOffset)
//							.opacity(EventContents.firstIndex(of: image) != self.selectedImageIndex && self.isSelecting ? 0 : 1)
//							.shadow(color: EventContents.firstIndex(of: image) == self.selectedImageIndex ? Color.black.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 0)
//				}
//			}
//			.background(
//				Color.black.ignoresSafeArea()
//					.opacity(self.backgroundOpacity)
//			)
//			.animation(.easeOut(duration: 0.25), value: self.selectedImageOffset.width)
//			.highPriorityGesture(
//				DragGesture()
//					.onChanged({ value in
//						DispatchQueue.main.async {
//							if !self.isSelecting && (value.translation.width > 5 || value.translation.width < -5) {
//								withAnimation(.easeInOut(duration: 0.2)) {
//									self.isSwiping = true
//								}
//							} else if !self.isSwiping && (value.translation.height > 10 || value.translation.height < -10) {
//								self.isSelecting = true
//								self.showFSVTab = false
//							}
//						}
//					})
//					.updating(self.$selectedImageOffset, body: { value, state, _ in
//						if self.isSwiping {
//							state = CGSize(width: value.translation.width, height: 0)
//						} else if self.isSelecting {
//							state = CGSize(width: value.translation.width, height: value.translation.height)
//						}
//					})
//					.onEnded({ value in
//						DispatchQueue.main.async {
//							self.selectedImageIndex = index
//							if value.translation.height > 50 && self.isSelecting {
//								withAnimation(.interactiveSpring()) {
//									self.didFinishClosingImage = false
//									self.showImageFSV = false
//									self.showFSVTab = false
//									self.selectedImageIndex = nil
//								}
//							} else if self.isSwiping {
//								let offset = value.translation.width / geoWidth*6
//								if offset > 0.5 && index > 0 {
//									self.selectedImageIndex! -= 1
//								} else if offset < -0.5 && index < (EventContents.count - 1) {
//									self.selectedImageIndex! += 1
//								}
//							}
//							self.showFSVTab = true
//							self.isSelecting = false
//							self.isSwiping = false
//						}
//					})
//			)
//			.simultaneousGesture(TapGesture(count: 2).onEnded {
//				print("LIKE")
//			})
//			.gesture(TapGesture(count: 1).onEnded {
//				self.showFSVTab.toggle()
//			})
//			.onAppear {
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//					self.isSelecting = false
//				}
//			}
//			.onDisappear {
//				self.didFinishClosingImage = true
//			}
//			.onChange(of: self.selectedImageOffset) { imageOffset in
//				DispatchQueue.main.async {
//					withAnimation(.easeIn) {
//						switch imageOffset.height {
//							case 50..<70:
//								self.backgroundOpacity = 0.8
//							case 70..<90:
//								self.backgroundOpacity = 0.6
//							case 90..<110:
//								self.backgroundOpacity = 0.4
//							case 110..<130:
//								self.backgroundOpacity = 0.2
//							case 130..<1000:
//								self.backgroundOpacity = 0.0
//							default:
//								self.backgroundOpacity = 1.0
//						}
//					}
//
//					let progress = imageOffset.height / geoHeightSafeArea
//					if 1 - progress > 0.5 {
//						self.selectedImageScale = 1 - progress
//					}
//				}
//			}
//			.zIndex(2)
//		}
//	}
//}

struct ImageGallerysView_Previews: PreviewProvider {
	static var previews: some View {
		ImagesGalleryView()
	}
}
