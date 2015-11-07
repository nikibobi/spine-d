module spine.atlas.atlas;

import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.math : abs;
import std.path : buildPath, dirName;

import spine.atlas;
import spine.util.argnull;

export class Atlas {
    
    this(string path, TextureLoader textureLoader) {
        auto reader = File(path, "r");
        scope(exit) reader.close();
        load(reader, dirName(path), textureLoader);
    }

    this(File reader, string dir, TextureLoader textureLoader) {
        load(reader, dir, textureLoader);
    }

    this(AtlasPage[] pages, AtlasRegion[] regions) {
        _pages = pages;
        _regions = regions;
        _textureLoader = null;
    }

    //TODO: add unittest
    
    private void load(File reader, string imagesDir, TextureLoader textureLoader) {
        mixin(ArgNull!textureLoader);
        _textureLoader = textureLoader;
        
        auto tuple = new string[4];
        AtlasPage page;
        while (true) {
            auto line = reader.readln();
            if (line == "")
                break;
            if (line.strip().length == 0)
                page = null;
            else if (page is null) {
                page = new AtlasPage;
                page.name = line.strip();

                if(readTuple(reader, tuple) == 2) { // size is only optional for an atlas packed with an old TexturePacker.
                    page.width = tuple[0].to!int;
                    page.height = tuple[1].to!int;
                    readTuple(reader, tuple);
                }
                
                page.format = tuple[0].to!Format;
                
                readTuple(reader, tuple);
                page.minFilter = tuple[0].to!TextureFilter;
                page.magFilter = tuple[1].to!TextureFilter;
                
                auto direction = readValue(reader);
                page.uWrap = TextureWrap.ClampToEdge;
                page.vWrap = TextureWrap.ClampToEdge;
                if (direction == "x")
                    page.uWrap = TextureWrap.Repeat;
                else if (direction == "y")
                    page.vWrap = TextureWrap.Repeat;
                else if (direction == "xy")
                    page.uWrap = page.vWrap = TextureWrap.Repeat;
                
                _textureLoader.load(page, buildPath(imagesDir, line.strip()));
                
                _pages ~= page;
                
            } else {
                auto region = new AtlasRegion;
                region.name = line.strip();
                region.page = page;
                
                region.rotate = readValue(reader).to!bool;
                
                readTuple(reader, tuple);
                auto x = tuple[0].to!int;
                auto y = tuple[1].to!int;
                
                readTuple(reader, tuple);
                auto width = tuple[0].to!int;
                auto height = tuple[1].to!int;
                
                region.u = x / page.width.to!float;
                region.v = y / page.height.to!float;
                region.u2 = (x + (region.rotate?height:width)) / page.width.to!float;
                region.v2 = (y + (region.rotate?width:height)) / page.height.to!float;
                region.x = x;
                region.y = y;
                region.width = abs(width);
                region.height = abs(height);
                
                if (readTuple(reader, tuple) == 4) { // split is optional
                    foreach(i; 0..4)
                        region.splits[i] = tuple[i].to!int;

                    if (readTuple(reader, tuple) == 4) { // pad is optional, but only present with splits
                        foreach(i; 0..4)
                            region.pads[i] = tuple[i].to!int;
                        readTuple(reader, tuple);
                    }
                }
                
                region.originalWidth = tuple[0].to!int;
                region.originalHeight = tuple[1].to!int;
                
                readTuple(reader, tuple);
                region.offsetX = tuple[0].to!int;
                region.offsetY = tuple[1].to!int;
                
                region.index = readValue(reader).to!int;
                
                _regions ~= region;
            }
        }
    }
    
    private static string readValue(File reader) {
        auto line = reader.readln();
        auto colon = line.indexOf(':');
        assert(colon != -1);
        return line[colon + 1..$].strip();
    }
    
    private static int readTuple(File reader, string[] tuple) {
        auto line = reader.readln();
        auto colon = line.indexOf(':');
        assert(colon != -1); //Invalid Line
        int i = 0, lastMatch = colon + 1;
        for (; i < 3; i++) {
            auto comma = line.indexOf(',', lastMatch);
            if (comma == -1)
                break;
            tuple[i] = line[lastMatch..comma].strip();
            lastMatch = comma + 1;
        }
        tuple[i] = line[lastMatch..$].strip();
        return i + 1;
    }

    void flipV() {
        foreach(region; _regions) {
            region.v = 1 - region.v;
            region.v2 = 1 - region.v2;
        }
    }
    
    AtlasRegion findRegion(string name) {
        foreach(region; _regions)
            if(region.name == name)
                return region;
        return null;
    }
    
    void dispose() {
        if(_textureLoader is null)
            return;
        foreach(page; _pages)
            _textureLoader.unload(page.rendererObject);
    }
    
private:
    AtlasPage[] _pages;
    AtlasRegion[] _regions;
    TextureLoader _textureLoader;
}