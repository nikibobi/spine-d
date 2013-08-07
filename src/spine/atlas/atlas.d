module spine.atlas.atlas;

export class Atlas {

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