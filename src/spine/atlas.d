module spine.atlas;

import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.math;
import std.algorithm : findSkip;

export:
 
class Atlas {

    this(File reader, string dir, TextureLoader textureLoader) {
        load(reader, dir, textureLoader);
    }

 private void load(File reader, string imagesDir, TextureLoader textureLoader) {
		this.textureLoader = textureLoader;
		
		string[] tuple = new string[4];
		AtlasPage page = null;
		while (true) {
			string line = reader.readln();
			if (line == null) break;
			if (line.strip().length == 0)
				page = null;
			else if (page is null) {
				page = new AtlasPage();
				page.name = line;
				
				page.format = to!Format(readValue(reader));
				
				readTuple(reader, tuple);
				page.minFilter = to!TextureFilter(tuple[0]); 
				page.magFilter = to!TextureFilter(tuple[1]); 
				
				string direction = readValue(reader);
				page.uWrap = TextureWrap.ClampToEdge;
				page.vWrap = TextureWrap.ClampToEdge;
				if (direction == "x")
					page.uWrap = TextureWrap.Repeat;
				else if (direction == "y")
					page.vWrap = TextureWrap.Repeat;
				else if (direction == "xy")
					page.uWrap = page.vWrap = TextureWrap.Repeat;
				
				textureLoader.load(page, text(imagesDir,line));

				_pages ~= page;
				
			} else {
				AtlasRegion region = new AtlasRegion();
				region.name = line;
				region.page = page;
				
				region.rotate = to!bool(readValue(reader));
				
				readTuple(reader, tuple);
				int x = to!int(tuple[0]);
				int y = to!int(tuple[1]);

				readTuple(reader, tuple);
				int width = to!int(tuple[0]);
				int height = to!int(tuple[1]);

				region.u = x / cast(float)page.width;
				region.v = y / cast(float)page.height;
				if (region.rotate) {
					region.u2 = (x + height) / cast(float)page.width;
					region.v2 = (y + width) / cast(float)page.height;
				} else {
					region.u2 = (x + width) / cast(float)page.width;
					region.v2 = (y + height) / cast(float)page.height;
				}
				region.x = x;
				region.y = y;
				region.width = abs(width);
				region.height = abs(height);
				
				if (readTuple(reader, tuple) == 4) { // split is optional
					region.splits[0] = to!int(tuple[0]);
					region.splits[1] = to!int(tuple[1]);
					region.splits[2] = to!int(tuple[2]);
					region.splits[3] = to!int(tuple[3]);
					
					if (readTuple(reader, tuple) == 4) { // pad is optional, but only present with splits
						region.pads[0] = to!int(tuple[0]);
						region.pads[1] = to!int(tuple[1]);
						region.pads[2] = to!int(tuple[2]);
						region.pads[3] = to!int(tuple[3]);
						readTuple(reader, tuple);
					}
				}
				
				region.originalWidth = to!int(tuple[0]);
				region.originalHeight = to!int(tuple[1]);
				
				readTuple(reader, tuple);
				region.offsetX = to!int(tuple[0]);
				region.offsetY = to!int(tuple[1]);

				region.index = to!int(readValue(reader));

				_regions ~= region;
			}
		}
	}

	private static string readValue(File reader) {
		string line = reader.readln();
		assert(findSkip(line,":") == true);//Chops everything before ":" and leaves everything as is
		return line.strip();
	}

	private static int readTuple(File reader, string[] tuple) {
		//ToDo:: Implement me!
		return 0;
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
