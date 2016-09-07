module spine.skeleton.bounds;

import std.algorithm.comparison : min, max;
import std.algorithm.searching : countUntil;

import spine.skeleton.skeleton;
import spine.attachment.boundingbox;
import spine.slot.slot;

export class SkeletonBounds {

    this() {
    }

    @property {
        ref BoundingBoxAttachment[] boundingBoxes() {
            return _boundingBoxes;
        }
        private void boundingBoxes(BoundingBoxAttachment[] value) {
            _boundingBoxes = value;
        }
    }

    @property {
        ref Polygon[] polygons() {
            return _polygons;
        }
        private void polygons(Polygon[] value) {
            _polygons = value;
        }
    }

    @property {
        float minX() {
            return _minX;
        }
        void minX(float value) {
            _minX = value;
        }
    }

    @property {
        float minY() {
            return _minY;
        }
        void minY(float value) {
            _minY = value;
        }
    }

    @property {
        float maxX() {
            return _maxX;
        }
        void maxX(float value) {
            _maxX = value;
        }
    }

    @property {
        float maxY() {
            return _maxY;
        }
        void maxY(float value) {
            _maxY = value;
        }
    }

    @property {
        float width() {
            return _maxX - _minX;
        }
    }

    @property {
        float height() {
            return _maxY - _minY;
        }
    }

    void Update(Skeleton skeleton, bool updateAabbb) {
        auto slots = skeleton.slots;
        size_t slotCount = slots.length;

        boundingBoxes.length = 0;
        foreach(polygon; polygons) {
            polygonPool ~= polygon;
        }
        polygons.length = 0;

        for(size_t i = 0; i < slotCount; i++) {
            Slot slot = slots[i];
            auto boundingBox = cast(BoundingBoxAttachment)slot.attachment;
            if(boundingBox is null)
                continue;
            boundingBoxes ~= boundingBox;

            Polygon polygon;
            if(polygonPool.length > 0) {
                polygon = polygonPool[$ - 1];
                polygonPool = polygonPool[0..($ - 1)];
            } else {
                polygon = new Polygon();
            }
            polygons ~= polygon;
            
            size_t count = boundingBox.vertices.length;
            polygon.count = count;
            if(polygon.vertices.length < count) {
                polygon.vertices = new float[count];
            }
            boundingBox.computeWorldVertices(slot.bone, polygon.vertices);
        }

        if(updateAabbb) {
            aabbCompute();
        }
    }

    private void aabbCompute() {
        float minX = int.max;
        float minY = int.max;
        float maxX = int.min;
        float maxY = int.min;
        foreach(polygon; polygons) {
            float[] vertices = polygon.vertices;
            for(size_t i = 0; i < polygon.count; i += 2) {
                float x = vertices[i];
                float y = vertices[i + 1];
                minX = min(minX, x);
                minY = min(minY, y);
                maxX = max(maxX, x);
                maxY = max(maxY, y);
            }
        }
        this.minX = minX;
        this.minY = minY;
        this.maxX = maxX;
        this.maxY = maxY;
    }

    bool aabbContainsPoint(float x, float y) {
        return x >= minX && x <= maxX && y >= minY && y <= maxY;
    }

    bool aabbIntersectsSegment(float x1, float y1, float x2, float y2) {
        if((x1 <= minX && x2 <= minX) ||
           (y1 <= minY && y2 <= minY) ||
           (x1 >= maxX && x2 >= maxX) ||
           (y1 >= maxY && y2 >= maxY)) {
            return false;
        }
        float m = (y2 - y1) / (x2 - x1);
        float y = m * (minX - x1) + y1;
        if(y > minY && y < maxY)
            return true;
        y = m * (maxX - x1) + y1;
        if(y > minY && y < maxY)
            return true;
        float x = (minY - y1) / m + x1;
        if(x > minX && x < maxX)
            return true;
        x = (maxY - y1) / m + x1;
        if(x > minX && x < maxX)
            return true;
        return false;
    }

    bool aabbIntersectsSkeleton(SkeletonBounds bounds) {
        return minX < bounds.maxX && maxX > bounds.minX && minY < bounds.maxY && maxY > bounds.minY;
    }

    bool containsPoint(Polygon polygon, float x, float y) {
        float[] vertices = polygon.vertices;
        size_t count = polygon.count;

        int prevIndex = count - 2;
        bool inside = false;
        for(size_t i = 0; i < count; i += 2) {
            float vertexY = vertices[i + 1];
            float prevY = vertices[prevIndex + 1];
            if((vertexY < y && prevY >= y) || (prevY < y && vertexY >= y)) {
                float vertexX = vertices[i];
                if(vertexX + (y - vertexY) / (prevY - vertexY) * (vertices[prevIndex] - vertexX) < x) {
                    inside = !inside;
                }
            }
            prevIndex = i;
        }
        return inside;
    }

    BoundingBoxAttachment containsPoint(float x, float y) {
        for(size_t i = 0; i < polygons.length; i++)
            if(containsPoint(polygons[i], x, y))
                return boundingBoxes[i];
        return null;
    }

    BoundingBoxAttachment intersectsSegment(float x1, float y1, float x2, float y2) {
        for(size_t i = 0; i < polygons.length; i++)
            if(intersectsSegment(polygons[i], x1, y1, x2, y2))
                return boundingBoxes[i];
        return null;
    }

    bool intersectsSegment(Polygon polygon, float x1, float y1, float x2, float y2) {
        float[] vertices = polygon.vertices;
        size_t count = polygon.count;

        float width12 = x1 - x2;
        float height12 = y1 - y2;
        float det1 = x1 * y2 - y1 * x2;
        float x3 = vertices[count - 2];
        float y3 = vertices[count - 1];
        for(size_t i = 0; i < count; i += 2) {
            float x4 = vertices[i];
            float y4 = vertices[i + 1];
            float det2 = x3 * y4 - y3 * x4;
            float width34 = x3 - x4;
            float height34 = y3 - y4;
            float det3 = width12 * height34 - height12 * width34;
            float x = (det1 * width34 - width12 * det2) / det3;
            if(((x >= x3 && x <= x4) || (x >= x4 && x <= x3)) &&
               ((x >= x1 && x <= x2) || (x >= x2 && x <= x1))) {
                float y = (det1 * height34 - height12 * det2) / det3;
                if(((y >= y3 && y <= y4) || (y >= y4 && y <= y3)) &&
                   ((y >= y1 && y <= y2) || (y >= y2 && y <= y1))) {
                    return true;
                }
            }
            x3 = x4;
            y3 = y4;
        }
        return false;
    }

    Polygon getPolygon(BoundingBoxAttachment attachment) {
        int index = countUntil(boundingBoxes, attachment);
        return index == -1 ? null : polygons[index];
    }

private:
    float _minX, _minY, _maxX, _maxY;
    BoundingBoxAttachment[] _boundingBoxes;
    Polygon[] _polygons;
    Polygon[] polygonPool;
}

export class Polygon {

    this() {
        this.vertices = new float[16];
    }

    @property {
        ref float[] vertices() {
            return _vertices;
        }
        void vertices(float[] value) {
            _vertices = value;
        }
    }

    @property {
        size_t count() {
            return _count;
        }
        void count(size_t value) {
            _count = value;
        }
    }

private:
    float[] _vertices;
    size_t _count;
}