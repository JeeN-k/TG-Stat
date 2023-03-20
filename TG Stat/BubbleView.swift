import UIKit

class BubbleView: UIView {
    
    private var bubbles: [Bubble] = []

    
    struct Bubble {
        let wordCount: Int
        let position: CGPoint
        let color: UIColor
    }
    
    struct ForceBubble {
        let wordCount: Int
        var position: CGPoint
        let color: UIColor
    }
    
    
    func addBubble(radius: CGFloat, position: CGPoint, color: UIColor, text: String, count: Int) {
        let bubble = UIView(frame: CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2))
        bubble.layer.cornerRadius = radius
        bubble.backgroundColor = color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: radius / 2)
        label.textColor = .black
        label.numberOfLines = 2
        label.text = "\(text)\n\(count)"
        bubble.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
            label.widthAnchor.constraint(equalTo: bubble.widthAnchor),
            label.heightAnchor.constraint(equalTo: bubble.heightAnchor)
        ])

        addSubview(bubble)
    }


    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for bubble in bubbles {
            context.setFillColor(bubble.color.cgColor)
            let bubbleSize = CGFloat(bubble.wordCount) // Adjust the size multiplier as needed
            let bubbleRect = CGRect(x: bubble.position.x - bubbleSize / 2,
                                    y: bubble.position.y - bubbleSize / 2,
                                    width: bubbleSize,
                                    height: bubbleSize)
            context.addEllipse(in: bubbleRect)
            context.fillPath()
        }
    }
    
    func circlePacking(bubbles: [(String, Int)], frame: CGRect) -> [CGPoint] {
        let totalWordsCount = bubbles.reduce(0) { $0 + $1.1 }
        let radii = bubbles.map { calculateRelativeBubbleRadius(wordCount: $0.1, totalWordsCount: totalWordsCount, frame: frame, topWords: bubbles) }
        
        var positions = generateRandomPositions(count: bubbles.count, radii: radii, frame: frame)
        
        let initialVelocity: CGFloat = 50
        let friction: CGFloat = 0.85
        let padding: CGFloat = 0.1
        let maxIteration = 10000
        
        var velocities = Array(repeating: CGPoint(x: 0, y: 0), count: bubbles.count)
        var iteration = 0
        var hasOverlap = false
        
        repeat {
            hasOverlap = false
            
            for i in 0..<bubbles.count {
                for j in i + 1..<bubbles.count {
                    let deltaX = positions[j].x - positions[i].x
                    let deltaY = positions[j].y - positions[i].y
                    
                    let distance = hypot(deltaX, deltaY)
                    let radiusSum = radii[i] + radii[j] + padding
                    
                    if distance < radiusSum {
                        hasOverlap = true
                        
                        let overlap = radiusSum - distance
                        
                        let directionX = deltaX / distance
                        let directionY = deltaY / distance
                        
                        velocities[i].x -= directionX * overlap / 2
                        velocities[i].y -= directionY * overlap / 2
                        
                        velocities[j].x += directionX * overlap / 2
                        velocities[j].y += directionY * overlap / 2
                    }
                }
            }
            
            for i in 0..<bubbles.count {
                let radius = radii[i]
                let position = positions[i]
                
                if position.x - radius < bounds.minX {
                    velocities[i].x += initialVelocity * abs(position.x - radius - bounds.minX) / radius
                } else if position.x + radius > bounds.maxX {
                    velocities[i].x -= initialVelocity * abs(position.x + radius - bounds.maxX) / radius
                }
                
                if position.y - radius < bounds.minY {
                    velocities[i].y += initialVelocity * abs(position.y - radius - bounds.minY) / radius
                } else if position.y + radius > bounds.maxY {
                    velocities[i].y -= initialVelocity * abs(position.y + radius - bounds.maxY) / radius
                }
            }

            
            for i in 0..<bubbles.count {
                positions[i].x += velocities[i].x
                positions[i].y += velocities[i].y
                
                velocities[i].x *= friction
                velocities[i].y *= friction
            }
            
            iteration += 1
        } while hasOverlap && iteration < maxIteration
        
        return positions
    }

    
    func generateRandomPositions(count: Int, radii: [CGFloat], frame: CGRect) -> [CGPoint] {
        return (0..<count).map { index in
            let x = CGFloat.random(in: frame.minX + radii[index] ... frame.maxX - radii[index])
            let y = CGFloat.random(in: frame.minY + radii[index] ... frame.maxY - radii[index])
            return CGPoint(x: x, y: y)
        }
    }
    
    func totalOverlap(positions: [CGPoint], radii: [CGFloat]) -> CGFloat {
        var totalOverlap: CGFloat = 0.0
        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                let distance = hypot(positions[i].x - positions[j].x, positions[i].y - positions[j].y)
                let overlap = max(0, radii[i] + radii[j] - distance)
                totalOverlap += overlap
            }
        }
        
        return totalOverlap
    }
    
    
    func calculateBubbleRadius(wordCount: Int, minRadius: CGFloat, maxRadius: CGFloat, frame: CGRect) -> CGFloat {
        let scaleFactor = min(frame.width, frame.height) / maxRadius
        let radius = CGFloat(wordCount) * scaleFactor
        return max(min(radius, maxRadius), minRadius)
    }
    
    func calculateRelativeBubbleRadius(wordCount: Int, totalWordsCount: Int, frame: CGRect, topWords: [(String, Int)]) -> CGFloat {
        let bubbleCount = CGFloat(topWords.count)
        let minDimension = min(frame.width, frame.height)
        let scaleFactor = minDimension / (sqrt(bubbleCount) * 4.5) // Оптимизированное значение для масштабирования пузырей
        
        let frameArea = frame.width * frame.height
        let wordRatio = CGFloat(wordCount) / CGFloat(totalWordsCount)
        let area = wordRatio * frameArea / bubbleCount
        let radius = sqrt(area / CGFloat.pi) * scaleFactor
        return radius
    }


}
