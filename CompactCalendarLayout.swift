import UIKit

final class CompactCalendarLayout: UICollectionViewLayout {

    /// A page is the equivalent to two weeks worth of dates
    fileprivate var numberOfPages = 1
    fileprivate let numberOfColumns = 7
    fileprivate let numberOfRows = 2

    fileprivate var cache = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.top + insets.bottom)
    }

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    fileprivate var oldOffset: CGPoint = .zero

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth * CGFloat(numberOfPages), height: contentHeight)
    }

    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        let cellWidth = Int(contentWidth) / numberOfColumns
        let cellHeight = Int(contentHeight) / numberOfRows

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let page = item / (numberOfColumns * numberOfRows)
            let indexInPage = item % (numberOfColumns * numberOfRows)
            let column = indexInPage % numberOfColumns
            let row = indexInPage >= numberOfColumns ? 1 : 0

            let xOffset = page * Int(contentWidth) + column * cellWidth
            let yOffset = row * cellHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = frame
            cache.append(attributes)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    override func invalidateLayout() {
        cache.removeAll()

        // this is necessary for the ensuing call to prepare() that will use the numberOfPages
        // to determine the size of the content view and the offsets of the items.
        numberOfPages = (collectionView?.numberOfItems(inSection: 0) ?? 14) / 14

        super.invalidateLayout()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
