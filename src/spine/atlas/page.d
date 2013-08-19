module spine.atlas.page;

import spine.atlas.format;
import spine.atlas.texture.filter;
import spine.atlas.texture.wrap;

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