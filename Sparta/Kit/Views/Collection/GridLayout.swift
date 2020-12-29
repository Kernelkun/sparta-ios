//
//  GridLayout.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class GridLayout: UICollectionViewLayout {

    var cellHeights: [CGFloat] = [] {
        didSet {
            precondition(cellHeights.filter { $0 <= 0 }.isEmpty)
            invalidateCache()
        }
    }

    var cellWidths: [CGFloat] = [] {
        didSet {
            precondition(cellWidths.filter { $0 <= 0 }.isEmpty)
            invalidateCache()
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: totalWidth, height: totalHeight)
    }

    override class var layoutAttributesClass: AnyClass {
        return GridViewLayoutAttributes.classForCoder()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // When bouncing, rect's origin can have a negative x or y, which is bad.
        let newRect = rect.intersection(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))

        var poses = [UICollectionViewLayoutAttributes]()
        let rows: Range<Int> = 0..<cellHeights.count
        let columns = columnsOverlapping(newRect)
        for row in rows {
            for column in columns {
                let indexPath = IndexPath(item: column, section: row)
                poses.append(pose(forCellAt: indexPath))
            }
        }

        return poses
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> GridViewLayoutAttributes? {
        return pose(forCellAt: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    private struct CellSpanWidth {
        var minX: CGFloat
        var maxX: CGFloat
    }

    private struct CellSpanHeight {
        var minY: CGFloat
        var maxY: CGFloat
    }

    private struct Cache {
        var cellSpansWidth: [CellSpanWidth]
        var cellSpansHeight: [CellSpanHeight]
        var totalWidth: CGFloat
        var totalHeight: CGFloat
    }

    private var _cache: Cache?
    private var cache: Cache {
        if let cache = _cache { return cache }

        var spansWidth: [CellSpanWidth] = []
        var spansHeight: [CellSpanHeight] = []

        var x: CGFloat = 0
        var y: CGFloat = 0

        for width in cellWidths {
            spansWidth.append(CellSpanWidth(minX: x, maxX: x + width))
            x += width
        }

        for height in cellHeights {
            spansHeight.append(CellSpanHeight(minY: y, maxY: y + height))
            y += height
        }

        let cache = Cache(cellSpansWidth: spansWidth, cellSpansHeight: spansHeight, totalWidth: x, totalHeight: y)

        _cache = cache
        return cache
    }

    private var totalWidth: CGFloat { return cache.totalWidth }
    private var totalHeight: CGFloat { return cache.totalHeight }

    private var cellSpansWidth: [CellSpanWidth] { return cache.cellSpansWidth }
    private var cellSpansHeight: [CellSpanHeight] { return cache.cellSpansHeight }

    private func invalidateCache() {
        _cache = nil
        invalidateLayout()
    }

    private func rowsOverlapping(_ rect: CGRect) -> Range<Int> {
        let minY = rect.minY
        let maxY = rect.maxY

        if let start = cellSpansHeight.firstIndex(where: { $0.maxY >= minY }),
           let end = cellSpansHeight.lastIndex(where: { $0.minY <= maxY }) {

            return start ..< end + 1
        } else {
            return 0 ..< 0
        }
    }

    private func columnsOverlapping(_ rect: CGRect) -> Range<Int> {
        let minX = rect.minX
        let maxX = rect.maxX

        if let start = cellSpansWidth.firstIndex(where: { $0.maxX >= minX }),
           let end = cellSpansWidth.lastIndex(where: { $0.minX <= maxX }) {

            return start ..< end + 1
        } else {
            return 0 ..< 0
        }
    }

    private func pose(forCellAt indexPath: IndexPath) -> GridViewLayoutAttributes {
        let pose = GridViewLayoutAttributes(forCellWith: indexPath)
        let row = indexPath.section
        let column = indexPath.item
        pose.frame = CGRect(x: cellSpansWidth[column].minX, y: cellSpansHeight[row].minY,
                            width: cellWidths[column], height: cellHeights[row])

        pose.backgroundColor = indexPath.section % 2 == 0 ? UIGridViewConstants.oddLineBackgroundColor
            : UIGridViewConstants.evenLineBackgroundColor

        return pose
    }
}
