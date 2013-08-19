module spine.atlas.texture.loader;

import spine.atlas.page;

export interface TextureLoader {
    void load(AtlasPage page, string path);
    void unload(Object texture);
}