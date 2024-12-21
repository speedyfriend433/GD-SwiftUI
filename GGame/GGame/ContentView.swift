//
//  ContentView.swift
//  GGame
//
//  Created by speedy on 2024/12/21.
//

import SwiftUI
import GameplayKit

struct ContentView: View {
    @State private var playerPosition = CGPoint(x: 100, y: 300)
    @State private var isJumping = false
    @State private var velocity: CGFloat = 0
    @State private var obstacles: [CGPoint] = [CGPoint(x: 600, y: 300)]
    @State private var gameTimer: Timer?
    @State private var isGameOver = false
    @State private var score = 0
    
    let gravity: CGFloat = 0.8
    let jumpForce: CGFloat = -15
    let groundLevel: CGFloat = 300
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Player
            Rectangle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .position(playerPosition)
                .rotation3DEffect(.degrees(isJumping ? 360 : 0), axis: (x: 0, y: 0, z: 1))
                .animation(.linear(duration: 0.5), value: isJumping)
            
            // Obstacles
            ForEach(obstacles.indices, id: \.self) { index in
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 40, height: 80)
                    .position(obstacles[index])
            }
            
            // Score
            Text("Score: \(score)")
                .foregroundColor(.white)
                .position(x: 50, y: 50)
            
            if isGameOver {
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Button("Restart") {
                        restartGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .gesture(
            TapGesture()
                .onEnded { _ in
                    if !isJumping && !isGameOver {
                        jump()
                    }
                }
        )
        .onAppear {
            startGame()
        }
    }
    
    func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            updateGame()
        }
    }
    
    func updateGame() {
        if isGameOver { return }
        
        // Update player physics
        if isJumping {
            velocity += gravity
            playerPosition.y += velocity
            
            // Check ground collision
            if playerPosition.y >= groundLevel {
                playerPosition.y = groundLevel
                isJumping = false
                velocity = 0
            }
        }
        
        // Update obstacles
        for i in obstacles.indices {
            obstacles[i].x -= 5
            
            // Check collision
            if abs(obstacles[i].x - playerPosition.x) < 40 &&
               abs(obstacles[i].y - playerPosition.y) < 60 {
                gameOver()
            }
            
            // Reset obstacle
            if obstacles[i].x < -20 {
                obstacles[i].x = 800
                score += 1
            }
        }
    }
    
    func jump() {
        isJumping = true
        velocity = jumpForce
    }
    
    func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    func restartGame() {
        playerPosition = CGPoint(x: 100, y: 300)
        obstacles = [CGPoint(x: 600, y: 300)]
        isGameOver = false
        score = 0
        isJumping = false
        velocity = 0
        startGame()
    }
}

#Preview {
    ContentView()
}
