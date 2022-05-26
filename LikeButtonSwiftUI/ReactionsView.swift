//
//  ReactionsView.swift
//  LikeButtonSwiftUI
//
//  Created by Daniel Carvajal on 23-05-22.
//

import SwiftUI

// MARK: Reactions view, container of reactions. The UI is like facebook/LinkedIn reactions.
struct ReactionsView: View {
    typealias ReactionElement = (image: String, text: String, index: Int)
    let reactions: [ReactionElement] // reactions in form of tuple (sfsymbol, text, index) or ("star", "estrella", 2)
    let completion: (ReactionElement) -> () // Completion handler for some task with the reaction selected
    
    @State private var dragPosition: CGPoint = .zero // finger position
    @State private var reactionsStates: [Bool] // Store the selection state (true or false) of all reactions
    @State private var isButtonPressed: Bool = false
    @State private var selectedReaction: ReactionElement?
    @State private var startedPressingButton: Bool = false
    // Find the index of selected reaction
    private var selectedReactionIndex: Int? {
        return reactionsStates.firstIndex{$0 == true}
    }
    
    init(_ reactions:[(image: String,text: String)], defaultReaction:Int?=nil,completion: @escaping (ReactionElement) -> ()) {
        
        // Transform  (sfsymbol, text) tuple to (sfsymbol,text, index) tuple (ReactionElement)
        var reactionsConverted: [ReactionElement] = []
        
        for (i, reaction) in zip(reactions.indices, reactions){
            reactionsConverted.append((reaction.image, reaction.text,i))
        }
        // Set the initial reaction
        if let defaultReaction = defaultReaction {
            selectedReaction = (reactions[defaultReaction].image,reactions[defaultReaction].text,defaultReaction)
        }
        
        self.completion = completion
        self.reactionsStates = Array(repeating: false, count: reactions.count)
        self.reactions = reactionsConverted
        
    }
    
    var body: some View {
        VStack(alignment:.leading,spacing:7) {
            
            // Reactions view
            HStack(alignment:.top,spacing:0) {
                ForEach(reactions, id:\.self.index) { reaction in
                    Reaction(image: reaction.image, text: reaction.text, dragPosition: dragPosition, isSelected: $reactionsStates[reaction.index])
                        .scaleEffect(isButtonPressed ? 1 : 0.01)
                        .animation(.ripple(index: reaction.index))
                    
                }
            }
            .background(Color.white
                .cornerRadius(15)
                .shadow(radius: 5))
            .frame(height: 75)
            .opacity(isButtonPressed ? 1 : 0)
            .animation(.default.speed(2))
            
            // Reaction button view
            reactionButton
                .opacity(startedPressingButton ? 0.5 : 1)
                .scaleEffect(startedPressingButton ? 0.95 : 1 )
                .animation(.default.speed(2))
            
        }.gesture(longGesture.simultaneously(with: dragGesture))
        
    }
}

// Extension containing the gestures
extension ReactionsView{
    
    var longGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onChanged{ _ in
                // Initial impact on reaction button
                Impact.impactLight.impactOccurred()
            }
            .onEnded { _ in
                isButtonPressed = true
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance:0,coordinateSpace:.global)
            .onChanged { value in
                dragPosition = value.location
                startedPressingButton = true
            }
            .onEnded { _ in
                // Reset states
                dragPosition = .zero
                startedPressingButton = false
                isButtonPressed = false
                
                // If there was a reaction selection, execute the completion handler
                if let selectedReactionIndex = selectedReactionIndex {
                    let selectedReaction = reactions[selectedReactionIndex]
                    self.selectedReaction = selectedReaction
                    completion(selectedReaction)
                }
            }
    }
    
    var reactionButton: some View {
        // Here you can change the default reaction to show when none of them has been selected
        HStack(alignment: .bottom) {
            Image(systemName: selectedReaction?.image ?? "paperplane")
                .font(.system(size: 20))
                .frame(width: 20, height: 20)
            Text(selectedReaction?.text ?? "Reacciona")
                .font(.footnote)
            
        }
        .animation(nil)
        .frame(width: 100, height: 40)
        .padding(5)
        //        .background(
        //            Color.white
        //                .cornerRadius(15)
        //                .shadow(radius: 5)
        //        )
    }
}

// MARK: Single reaction view
struct Reaction: View {
    let image: String
    let text: String
    let dragPosition: CGPoint
    @Binding var isSelected: Bool
    
    var body: some View {
        GeometryReader { g in
            let localFrame = g.frame(in: .global)
            // Get the position of the Reaction View respect the screen (window)
            let rangeX = localFrame.minX...localFrame.maxX
            let rangeY = localFrame.minY...localFrame.maxY
            
            VStack {
                if isSelected {
                    Text(text)
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                        .padding(4)
                        .background(
                            Capsule(style: .circular)
                                .fill(Color.purple)
                                .shadow(radius: 1)
                        )
                }
                Image(systemName: image)
                    .font(.system(size: 30))
                    .frame(width: 30, height: 30)
            }
            .frame(width: g.size.width, height: g.size.height)
            .padding(.horizontal,5)
            .foregroundColor(isSelected ? Color.purple : Color.black)
            .scaleEffect(isSelected ? 1.5 : 1)
            .offset(y: isSelected ? -30 : 0)
            .animation(.default.speed(2))
            .onChange(of: rangeX.contains(dragPosition.x) && rangeY.contains(dragPosition.y)) { newValue in
                
                // If the range of the view contains the drag position, the user is selecting the reaction,  therefore, it's true their state in the reaction array, else false.
                if newValue {
                    // If it is true (selected), triggers impact
                    Impact.impactLight.impactOccurred()
                }
                withAnimation(.default.speed(2)) {
                    isSelected = newValue
                }
            }
        }
    }
}


// MARK: Helpers
extension Animation {
    static func ripple(index: Int = 0) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(1.5)
            .delay(0.07 * Double(index))
    }
}

struct Impact{
    static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    static let impactMed = UIImpactFeedbackGenerator(style: .medium)
    static let impactLight = UIImpactFeedbackGenerator(style: .light)
}
