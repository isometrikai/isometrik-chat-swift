//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import AVKit
import IsometrikChat

struct ISMChatVideoView: View {

    @EnvironmentObject var mediaPagesViewModel: ISMChatMediaViewerViewModel

    @StateObject var viewModel: ISMChatVideoViewModel

    var body: some View {
        Group {
            if let player = viewModel.player, viewModel.status == .readyToPlay {
                content(for: player)
            } else{
                ProgressView()
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            viewModel.onStart()

            mediaPagesViewModel.toggleVideoPlaying = {
                viewModel.togglePlay()
            }
            mediaPagesViewModel.toggleVideoMuted = {
                viewModel.toggleMute()
            }
        }
        .onDisappear {
            viewModel.onStop()
        }
        .onChange(of: viewModel.isPlaying) { _, newValue in
            mediaPagesViewModel.videoPlaying = newValue
        }
        .onChange(of: viewModel.isMuted) { _, newValue in
            mediaPagesViewModel.videoMuted = newValue
        }
        .onChange(of: viewModel.status) { _, status in
            if status == .readyToPlay {
                viewModel.togglePlay()
            }
        }
    }

    func content(for player: AVPlayer) -> some View {
        VideoPlayer(player: player)
    }
}

