//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import AVKit
import IsometrikChat

/// A SwiftUI view that handles video playback in the chat interface
struct ISMChatVideoView: View {
    // Environment object to communicate with parent media viewer
    @EnvironmentObject var mediaPagesViewModel: ISMChatMediaViewerViewModel
    
    // View model handling video playback logic and state
    @StateObject var viewModel: ISMChatVideoViewModel

    var body: some View {
        Group {
            // Display video player when ready, otherwise show loading indicator
            if let player = viewModel.player, viewModel.status == .readyToPlay {
                content(for: player)
            } else {
                ProgressView()
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            // Initialize video playback when view appears
            viewModel.onStart()

            // Set up callbacks for external control of video playback
            mediaPagesViewModel.toggleVideoPlaying = {
                viewModel.togglePlay()
            }
            mediaPagesViewModel.toggleVideoMuted = {
                viewModel.toggleMute()
            }
        }
        .onDisappear {
            // Clean up resources when view disappears
            viewModel.onStop()
        }
        // Sync playback state with parent view model
        .onChange(of: viewModel.isPlaying) { _, newValue in
            mediaPagesViewModel.videoPlaying = newValue
        }
        // Sync mute state with parent view model
        .onChange(of: viewModel.isMuted) { _, newValue in
            mediaPagesViewModel.videoMuted = newValue
        }
        // Automatically start playback when video is ready
        .onChange(of: viewModel.status) { _, status in
            if status == .readyToPlay {
                viewModel.togglePlay()
            }
        }
    }

    /// Creates the video player view with the given AVPlayer instance
    /// - Parameter player: The AVPlayer instance to use for video playback
    /// - Returns: A VideoPlayer view configured with the provided player
    func content(for player: AVPlayer) -> some View {
        VideoPlayer(player: player)
    }
}

