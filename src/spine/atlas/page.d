module spine.atlas.page;

export class AtlasPage {
    string name;
    Format format;
    TextureFilter minFilter;
    TextureFilter magFilter;
    TextureWrap uWrap;
    TextureWrap vWrap;
    Object rendererObject;
    int width, height;
}