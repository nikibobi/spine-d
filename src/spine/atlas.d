module spine.atlas;

import std.stdio;

export:
 
class Atlas {

    this(File reader, string dir, TextureLoader textureLoader) {
        load(reader, dir, textureLoader);
    }

    private void load(File reader, string imagesDir, TextureLoader textureLoader) {
        //TODO: implement loading file
    }

    private static string readValue(File reader) {
        //TODO: implement
        return string.init;
    }

    private static int readTuple(File reader, string[] tuple) {
        //TODO: implement
        return int.init;
    }

    AtlasRegion findRegion(string name) {
        foreach(region; _regions)
            if(region.name == name)
                return region;
        return null;
    }

    void dispose() {
        foreach(page; _pages)
            textureLoader.unload(page.rendererObject);
    }


private:
    AtlasPage[] _pages;
    AtlasRegion[] _regions;
    TextureLoader textureLoader;
}

enum Format {
    Alpha,
    Intensity,
    LuminanceAlpha,
    RGB565,
    RGBA4444,
    RGB888,
    RGBA8888
}

enum TextureFilter {
    Nearest,
    Linear,
    MipMap,
    MipMapNearestNearest,
    MipMapLinearNearest,
    MipMapNearestLinear,
    MipMapLinearLinear
}

enum TextureWrap {
    MirroredRepeat,
    ClampToEdge,
    Repeat
}

class AtlasPage {
    string name;
    Format format;
    TextureFilter minFilter;
    TextureFilter magFilter;
    TextureWrap uWrap;
    TextureWrap vWrap;
    Object rendererObject;
    int width, height;
}

class AtlasRegion {
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

interface TextureLoader {
    void load(AtlasPage page, string path);
    void unload(Object texture);
}