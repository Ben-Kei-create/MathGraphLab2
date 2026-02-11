//
//  TouchInteractionView.swift
//  MathGraph Lab
//
//  Layer 4: Touch interaction for rubber banding and geometry drawing
//  Implements IDD Section 3.2 Layer 4 specifications
//

import SwiftUI

// MARK: - Touch Interaction View
/// Handles drag gestures for parameter adjustment and geometry drawing
struct TouchInteractionView: View {
    
    @EnvironmentObject var appState: AppState
    
    // Interaction thresholds
    private let proximityThreshold: Double = 0.5  // Math units
    private let snapThreshold: Double = 0.3       // Snap to grid/point threshold
    
    // Gesture state
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartValue: Double = 0.0
    @State private var isDraggingParabola: Bool = false
    @State private var geometryStartPoint: CGPoint?
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value: value, size: geometry.size)
                        }
                        .onEnded { value in
                            handleDragEnded(value: value, size: geometry.size)
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            // Tap gesture is handled in onChanged when distance is minimal
                        }
                )
        }
    }
    
    // MARK: - Gesture Handlers
    
    private func handleDragChanged(value: DragGesture.Value, size: CGSize) {
        let coordSystem = CoordinateSystem(size: size)
        let location = value.location
        let mathPos = coordSystem.mathPosition(from: location)
        
        // GEOMETRY MODE: Drawing points and line segments
        if appState.isGeometryModeEnabled {
            handleGeometryDrag(
                location: location,
                mathPos: mathPos,
                coordSystem: coordSystem,
                translation: value.translation
            )
            return
        }
        
        // RUBBER BANDING MODE: Adjust parabola coefficient 'a'
        if !isDraggingParabola {
            // Check if touch is near the parabola curve
            if isNearParabola(mathX: mathPos.x, mathY: mathPos.y) {
                isDraggingParabola = true
                dragStartLocation = location
                dragStartValue = appState.parabola.a
                appState.beginDrag()  // Enable ghosting
                
                // Haptic feedback on grab
                if appState.isHapticsEnabled {
                    HapticManager.shared.impact(style: .medium)
                }
            }
        }
        
        if isDraggingParabola {
            updateParabolaFromDrag(
                currentLocation: location,
                coordSystem: coordSystem
            )
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value, size: CGSize) {
        let coordSystem = CoordinateSystem(size: size)
        let mathPos = coordSystem.mathPosition(from: value.location)
        
        // GEOMETRY MODE: Finalize drawing
        if appState.isGeometryModeEnabled {
            finalizeGeometryDrag(
                location: value.location,
                mathPos: mathPos,
                coordSystem: coordSystem
            )
            geometryStartPoint = nil
            return
        }
        
        // RUBBER BANDING MODE: End drag
        if isDraggingParabola {
            isDraggingParabola = false
            appState.endDrag()  // Clear ghosting
            
            // Snap to integer if enabled
            if appState.isGridSnapEnabled {
                let snappedA = round(appState.parabola.a)
                appState.updateParabolaA(snappedA)
                
                if appState.isHapticsEnabled {
                    HapticManager.shared.impact(style: .light)
                }
            }
        } else {
            // Short tap without drag - could be a point placement
            if value.translation.width < 5 && value.translation.height < 5 {
                // This is a tap, not a drag
                // Tap behavior can be handled here if needed
            }
        }
    }
    
    // MARK: - Rubber Banding Logic
    
    /// Check if a point is near the parabola curve
    /// Threshold: |y - a(x-p)²-q| < proximityThreshold
    private func isNearParabola(mathX: Double, mathY: Double) -> Bool {
        let expectedY = appState.parabola.evaluate(at: mathX)
        let distance = abs(mathY - expectedY)
        return distance < proximityThreshold
    }
    
    /// Update parabola coefficient 'a' based on vertical drag
    private func updateParabolaFromDrag(
        currentLocation: CGPoint,
        coordSystem: CoordinateSystem
    ) {
        // Calculate vertical drag distance in screen coordinates
        let deltaY = currentLocation.y - dragStartLocation.y
        
        // Convert to math coordinates (sensitivity factor)
        let sensitivity = 0.01  // Adjust for comfortable dragging
        let deltaA = -deltaY * sensitivity  // Negative because Y is inverted
        
        let newA = dragStartValue + deltaA
        appState.updateParabolaA(newA, snap: appState.isGridSnapEnabled)
        
        // Haptic feedback when crossing integer values
        if appState.isHapticsEnabled {
            let previousInt = Int(dragStartValue)
            let currentInt = Int(appState.parabola.a)
            if previousInt != currentInt {
                HapticManager.shared.impact(style: .medium)
            }
        }
    }
    
    // MARK: - Geometry Drawing Logic
    
    private func handleGeometryDrag(
        location: CGPoint,
        mathPos: (x: Double, y: Double),
        coordSystem: CoordinateSystem,
        translation: CGSize
    ) {
        if geometryStartPoint == nil {
            // Start of drag - store starting point
            geometryStartPoint = location
            
            // Add a point if this is just a tap (will be removed if it becomes a drag)
            if translation.width < 5 && translation.height < 5 {
                // Snap to grid if enabled
                let finalX = appState.isGridSnapEnabled ? round(mathPos.x) : mathPos.x
                let finalY = appState.isGridSnapEnabled ? round(mathPos.y) : mathPos.y
                
                appState.addGeometryPoint(
                    at: location,
                    graphX: finalX,
                    graphY: finalY
                )
                
                if appState.isHapticsEnabled {
                    HapticManager.shared.impact(style: .light)
                }
            }
        } else {
            // Continuing drag - could be drawing a line
            let dragDistance = hypot(
                translation.width,
                translation.height
            )
            
            if dragDistance > 10 {
                // This is a line drag, remove any point that was added
                if let lastElement = appState.geometryElements.last,
                   case .point = lastElement {
                    appState.geometryElements.removeLast()
                }
            }
        }
    }
    
    private func finalizeGeometryDrag(
        location: CGPoint,
        mathPos: (x: Double, y: Double),
        coordSystem: CoordinateSystem
    ) {
        guard let startPoint = geometryStartPoint else { return }
        
        let dragDistance = hypot(
            location.x - startPoint.x,
            location.y - startPoint.y
        )
        
        // If drag distance is significant, create a line segment
        if dragDistance > 10 {
            var endPoint = location
            
            // Snap to existing points if close enough
            if appState.isGridSnapEnabled {
                if let snapPoint = findNearbySnapPoint(
                    at: location,
                    coordSystem: coordSystem
                ) {
                    endPoint = snapPoint
                    
                    // Heavy haptic for snapping
                    if appState.isHapticsEnabled {
                        HapticManager.shared.impact(style: .heavy)
                    }
                }
            }
            
            appState.addGeometryLineSegment(start: startPoint, end: endPoint)
        }
    }
    
    /// Find nearby point to snap to (for geometry mode)
    private func findNearbySnapPoint(
        at location: CGPoint,
        coordSystem: CoordinateSystem
    ) -> CGPoint? {
        let mathPos = coordSystem.mathPosition(from: location)
        
        // Check intersection points
        for intersection in appState.intersectionPoints {
            let screenPos = coordSystem.screenPosition(
                mathX: intersection.x,
                mathY: intersection.y
            )
            let distance = hypot(
                location.x - screenPos.x,
                location.y - screenPos.y
            )
            if distance < 20 {  // 20 points snap radius
                return screenPos
            }
        }
        
        // Check existing geometry points
        for element in appState.geometryElements {
            if case .point(_, let x, let y) = element {
                let screenPos = coordSystem.screenPosition(mathX: x, mathY: y)
                let distance = hypot(
                    location.x - screenPos.x,
                    location.y - screenPos.y
                )
                if distance < 20 {
                    return screenPos
                }
            }
        }
        
        // Snap to grid if enabled
        if appState.isGridSnapEnabled {
            let snappedX = round(mathPos.x)
            let snappedY = round(mathPos.y)
            return coordSystem.screenPosition(mathX: snappedX, mathY: snappedY)
        }
        
        return nil
    }
}

// MARK: - HapticManager is in Utilities/HapticManager.swift

// MARK: - Preview
#Preview {
    ZStack {
        GridBackgroundView()
        GraphCanvasView()
        AnalysisOverlayView()
        TouchInteractionView()
    }
    .environmentObject(AppState())
}
