module spine.atlas.texture.loader;

export interface TextureLoader {
    void load(AtlasPage page, string path);
    void unload(Object texture);
}