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
		this._textureLoader = textureLoader;
		
		auto tuple = new string[4];
		AtlasPage page;
		while (true) {
			auto line = reader.readln();
			if (line is null) 
				break;
			if (line.strip().length == 0)
				page = null;
			else if (page is null) {
				page = new AtlasPage;
				page.name = line;
				
				page.format = readValue(reader).to!Format;
				
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
				
				_textureLoader.load(page, text(imagesDir, line));
				
				_pages ~= page;
				
			} else {
				auto region = new AtlasRegion;
				region.name = line;
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
				if (region.rotate) {
					region.u2 = (x + height) / page.width.to!float;
					region.v2 = (y + width) / page.height.to!float;
				} else {
					region.u2 = (x + width) / page.width.to!float;
					region.v2 = (y + height) / page.height.to!float;
				}
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
		assert(findSkip(line, ":"));//Chops everything before ":" and leaves everything as is
		return line.strip();
	}
	
	private static int readTuple(File reader, string[] tuple) {
		//TODO: Implement me!
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
			_textureLoader.unload(page.rendererObject);
	}
	
private:
	AtlasPage[] _pages;
	AtlasRegion[] _regions;
	TextureLoader _textureLoader;
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
	TextureFilter minFilter, magFilter;
	TextureWrap uWrap, vWrap;
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
