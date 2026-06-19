import AVKit
import FrameflowCore
import SwiftUI

/// Drives a single Multi-View slot's video playback. Uses an `AVQueuePlayer` +
/// `AVPlayerLooper` so the clip loops seamlessly, and exposes simple play/pause
/// and mute controls that the Multi-View header toggles for every slot at once.
@MainActor
final class MultiViewPlayerController: ObservableObject {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var loadedURL: URL?

    init() {
        player.actionAtItemEnd = .advance
    }

    func load(_ url: URL) {
        guard loadedURL != url else { return }
        loadedURL = url
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
    }

    func apply(paused: Bool, muted: Bool) {
        player.isMuted = muted
        if paused {
            player.pause()
        } else {
            player.play()
        }
    }

    func stop() {
        player.pause()
        looper?.disableLooping()
        looper = nil
        player.removeAllItems()
        loadedURL = nil
    }
}

/// A looping, aspect-filled video surface for one Multi-View slot.
struct MultiViewVideoTile: View {
    let url: URL
    let paused: Bool
    let muted: Bool

    @StateObject private var controller = MultiViewPlayerController()

    var body: some View {
        NativeVideoSurface(player: controller.player, fillsFrame: true)
            .onAppear {
                controller.load(url)
                controller.apply(paused: paused, muted: muted)
            }
            .onDisappear {
                controller.stop()
            }
            .onChange(of: url) {
                controller.load(url)
                controller.apply(paused: paused, muted: muted)
            }
            .onChange(of: paused) {
                controller.apply(paused: paused, muted: muted)
            }
            .onChange(of: muted) {
                controller.apply(paused: paused, muted: muted)
            }
    }
}

/// Renders the media inside a Multi-View slot, filling the tile for every
/// supported media kind. Videos loop and honor the shared play/mute state;
/// still and animated images fill the frame.
struct MultiViewTileContent: View {
    let item: MediaItem
    let paused: Bool
    let muted: Bool

    var body: some View {
        ZStack {
            Color.black

            switch item.kind {
            case .video:
                MultiViewVideoTile(url: item.url, paused: paused, muted: muted)
            case .gif:
                NativeGIFImageView(url: item.url, trim: nil)
            case .webp:
                NativeWebImageView(url: item.url)
            case .image:
                StaticImagePreview(url: item.url)
            }
        }
        .clipped()
    }
}
