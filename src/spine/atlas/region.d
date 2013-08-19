module spine.atlas.region;

import spine.atlas.page;

export class AtlasRegion {
    AtlasPage page;
    string name;
    int x, y, width, height;
    float u, v, u2, v2;
    float offsetX, offsetY;
    int originalWidth, originalHeight;
    int index;
    bool rotate;
    int[] splits;
    int[] pads;
}