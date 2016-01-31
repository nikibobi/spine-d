module spine.skeleton.json;

import std.algorithm.comparison : max;
import std.algorithm.searching : countUntil;
import std.conv : to;
import std.file : readText, FileException;
import std.json;
import std.stdio;

import spine.animation;
import spine.atlas.atlas;
import spine.attachment.atlasloader;
import spine.attachment.attachment;
import spine.attachment.boundingbox;
import spine.attachment.loader;
import spine.attachment.mesh;
import spine.attachment.region;
import spine.attachment.skinnedmesh;
import spine.attachment.type;
import spine.bone.data;
import spine.event;
import spine.ikconstraint.data;
import spine.skeleton.data;
import spine.skin.skin;
import spine.slot.blendmode;
import spine.slot.data;
import spine.util.argnull;
import spine.util.json;

export class SkeletonJson {

    this(Atlas[] atlasArray ...) {
        this(new AtlasAttachmentLoader(atlasArray));
    }

    this(AttachmentLoader attachmentLoader) {
        mixin(ArgNull!attachmentLoader);
        _attachmentLoader = attachmentLoader;
        scale = 1;
    }

    @property {
        float scale() {
            return _scale;
        }
        void scale(float value) {
            _scale = value;
        }
    }

    SkeletonData readSkeletonData(string path) {
        mixin(ArgNull!path);

        auto skeletonData = new SkeletonData();
        string text;
        try {
            text = readText(path);
        } catch(FileException ex) {
            throw new Exception("something is wrong with reading file: \"" ~ path ~ "\"", __FILE__, __LINE__, ex);
        }

        try {
            JSONValue root = parseJSON(text);
            if(root.type != JSON_TYPE.OBJECT)
                throw new JSONException("Invalid JSON.");

            // Skeleton.
            if("skeleton" in root) {
                JSONValue skeletonMap = root["skeleton"];
                with(skeletonData) {
                    hash = skeletonMap["hash"].text;
                    ver = skeletonMap["spine"].text;
                    width = getFloat(skeletonMap, "width", 0);
                    height = getFloat(skeletonMap, "height", 0);
                }
            }

            // Bones.
            foreach(boneMap; root["bones"].array) {
                BoneData parent = null;
                if("parent" in boneMap) {
                    parent = skeletonData.findBone(boneMap["parent"].text);
                    if(parent is null)
                        throw new Exception("Parent bone not found: " ~ boneMap["parent"].text);
                }
                auto boneData = new BoneData(boneMap["name"].text, parent);
                with(boneData) {
                    length = getFloat(boneMap, "length", 0) * scale;
                    x = getFloat(boneMap, "x", 0) * scale;
                    y = getFloat(boneMap, "y", 0) * scale;
                    rotation = getFloat(boneMap, "rotation", 0);
                    scaleX = getFloat(boneMap, "scaleX", 1);
                    scaleY = getFloat(boneMap, "scaleY", 1);
                    flipX = getBool(boneMap, "flipX", false);
                    flipY = getBool(boneMap, "flipY", false);
                    inheritScale = getBool(boneMap, "inheritScale", true);
                    inheritRotation = getBool(boneMap, "inheritRotation", true);
                }
                skeletonData.bones ~= boneData;
            }

            // IK constraints.
            if("ik" in root) {
                foreach(ikMap; root["ik"].array) {
                    auto ikConstraintData = new IkConstraintData(ikMap["name"].text);

                    foreach(boneName; ikMap["bones"].array) {
                        BoneData bone = skeletonData.findBone(boneName.text);
                        if(bone is null)
                            throw new Exception("IK bone not found: " ~ boneName.text);
                        ikConstraintData.bones ~= bone;
                    }

                    string targetName = ikMap["target"].text;
                    ikConstraintData.target = skeletonData.findBone(targetName);
                    if(ikConstraintData.target is null)
                        throw new Exception("Target bone not found: " ~ targetName);

                    ikConstraintData.bendDirection = getBool(ikMap, "bendPositive", true) ? 1 : -1;
                    ikConstraintData.mix = getFloat(ikMap, "mix", 1);

                    skeletonData.ikConstraints ~= ikConstraintData;
                }
            }

            // Slots.
            if("slots" in root) {
                foreach(slotMap; root["slots"].array) {
                    auto slotName = slotMap["name"].text;
                    auto boneName = slotMap["bone"].text;
                    BoneData boneData = skeletonData.findBone(boneName);
                    if(boneData is null)
                        throw new Exception("Slot bone not found: " ~ boneName);
                    auto slotData = new SlotData(slotName, boneData);
                    with(slotData) {
                        if("color" in slotMap) {
                            auto color = slotMap["color"].text;
                            r = toColor(color, 0);
                            g = toColor(color, 1);
                            b = toColor(color, 2);
                            a = toColor(color, 3);
                        }

                        if("attachment" in slotMap)
                            attachmentName = slotMap["attachment"].text;
                        
                        if("blend" in slotMap)
                            blendMode = slotMap["blend"].text.to!BlendMode;
                        else
                            blendMode = BlendMode.normal;
                    }
                    skeletonData.slots ~= slotData;
                }
            }

            // Skins.
            if("skins" in root) {
                foreach(skinKey, skinValue; root["skins"].object) {
                    auto skin = new Skin(skinKey);
                    foreach(slotKey, slotValue; skinValue.object) {
                        int slotIndex = skeletonData.findSlotIndex(slotKey);
                        foreach(attachmentKey, attachmentValue; slotValue.object) {
                            Attachment attachment = readAttachment(skin, attachmentKey, attachmentValue);
                            if(attachment !is null)
                                skin.addAttachment(slotIndex, attachmentKey, attachment);
                        }
                    }
                    skeletonData.skins ~= skin;
                    if(skin.name == "default")
                        skeletonData.defaultSkin = skin;
                }
            }

            // Events.
            if("events" in root) {
                foreach(key, entryMap; root["events"].object) {
                    auto eventData = new EventData(key);
                    with(eventData) {
                        integer = getInt(entryMap, "int", 0);
                        number = getFloat(entryMap, "float", 0);
                        text = getString(entryMap, "string", null);
                    }
                    skeletonData.events ~= eventData;
                }
            }

            // Animations.
            if("animations" in root) {
                foreach(key, value; root["animations"].object) {
                    readAnimation(key, value, skeletonData);
                }
            }

        } catch(JSONException ex) {
            throw new Exception("something is wrong with json format", __FILE__, __LINE__, ex);
        }
        return skeletonData;
    }

    private Attachment readAttachment(Skin skin, string name, JSONValue map) {
        if("name" in map)
            name = map["name"].text;

        auto type = AttachmentType.region;
        if("type" in map)
            type = map["type"].text.to!AttachmentType;

        string path = name;
        if("path" in map)
            path = map["path"].text;

        final switch (type) {
        case AttachmentType.region:
            RegionAttachment region = _attachmentLoader.newRegionAttachment(skin, name, path);
            if(region is null)
                return null;
            region.path = path;
            with(region) {    
                x = getFloat(map, "x", 0) * scale;
                y = getFloat(map, "y", 0) * scale;
                scaleX = getFloat(map, "scaleX", 1);
                scaleY = getFloat(map, "scaleY", 1);
                rotation = getFloat(map, "rotation", 0);
                width = getInt(map, "width", 32) * scale;
                height = getInt(map, "height", 32) * scale;
                updateOffset();

                if("color" in map) {
                    auto color = map["color"].text;
                    r = toColor(color, 0);
                    g = toColor(color, 1);
                    b = toColor(color, 2);
                    a = toColor(color, 3);
                }
            }
            return region;
        case AttachmentType.mesh:
            MeshAttachment mesh = _attachmentLoader.newMeshAttachment(skin, name, path);
            if(mesh is null)
                return null;
            mesh.path = path;
            with(mesh) {
                vertices = getFloatArray(map, "vertices", scale);
                triangles = getIntArray(map, "triangles");
                regionUVs = getFloatArray(map, "uvs", 1);
                updateUVs();

                if("color" in map) {
                    auto color = map["color"].text;
                    r = toColor(color, 0);
                    g = toColor(color, 1);
                    b = toColor(color, 2);
                    a = toColor(color, 3);
                }

                hullLength = getInt(map, "hull", 0) * 2;
                if("edges" in map)
                    edges = getIntArray(map, "edges");
                width = getInt(map, "width", 0) * scale;
                height = getInt(map, "height", 0) * scale;
            }
            return mesh;
        case AttachmentType.skinnedmesh:
            SkinnedMeshAttachment mesh = _attachmentLoader.newSkinnedMeshAttachment(skin, name, path);
            if(mesh is null)
                return null;
            mesh.path = path;
            float[] uvs = getFloatArray(map, "uvs", 1);
            float[] vertices = getFloatArray(map, "vertices", 1);
            float[] weights;
            int[] bones;
            for(int i = 0, n = vertices.length; i < n; ) {
                int boneCount = vertices[i++].to!int;
                bones ~= boneCount;
                for(int nn = i + boneCount * 4; i < nn; ) {
                    bones ~= vertices[i].to!int;
                    weights ~= vertices[i + 1] * scale;
                    weights ~= vertices[i + 2] * scale;
                    weights ~= vertices[i + 3];
                    i += 4;
                }
            }
            mesh.bones = bones;
            mesh.weights = weights;
            mesh.regionUVs = uvs;
            with(mesh) {
                triangles = getIntArray(map, "triangles");
                updateUVs();

                if("color" in map) {
                    auto color = map["color"].text;
                    r = toColor(color, 0);
                    g = toColor(color, 1);
                    b = toColor(color, 2);
                    a = toColor(color, 3);
                }

                hullLength = getInt(map, "hull", 0) * 2;
                if("edges" in map)
                    edges = getIntArray(map, "edges");
                width = getInt(map, "width", 0) * scale;
                height = getInt(map, "height", 0) * scale;
            }
            return mesh;
        case AttachmentType.boundingbox:
            BoundingBoxAttachment box = _attachmentLoader.newBoundingBoxAttachment(skin, name);
            if(box is null)
                return null;
            box.vertices = getFloatArray(map, "vertices", scale);
            return box;
        }   
        assert(0);
    }

    private float[] getFloatArray(JSONValue map, string name, float scale) {
        if(map[name].type != JSON_TYPE.ARRAY)
            throw new Exception("JSON is not array");
        auto list = map[name].array;
        auto values = new float[list.length];
        if(scale == 1) {
            for(int i = 0; i < list.length; i++)
                values[i] = list[i].number;
        } else {
            for(int i = 0; i < list.length; i++)
                values[i] = list[i].number * scale;
        }
        return values;
    }

    private int[] getIntArray(JSONValue map, string name) {
        if(map[name].type != JSON_TYPE.ARRAY)
            throw new Exception("JSON is not array");
        auto list = map[name].array;
        auto values = new int[list.length];
        for(int i = 0; i < list.length; i++)
            values[i] = list[i].integer.to!int;
        return values;
    }

    private float getFloat(JSONValue map, string name, float defaultValue) {
        if(name in map)
            return map[name].number;
        return defaultValue;
    }

    private int getInt(JSONValue map, string name, int defaultValue) {
        if(name in map)
            return map[name].integer.to!int;
        return defaultValue;
    }

    private bool getBool(JSONValue map, string name, bool defaultValue) {
        if(name in map)
            return map[name].type == JSON_TYPE.TRUE;
        return defaultValue;
    }

    private string getString(JSONValue map, string name, string defaultValue) {
        if(name in map)
            return map[name].text;
        return defaultValue;
    }

    private float toColor(string hexString, int colorIndex) {
        if(hexString.length != 8)
            throw new Exception("Color hexidecimal length must be 8, recieved: " ~ hexString);
        auto i = colorIndex * 2;
        return to!int(hexString[i..i + 2], 16) / 255f;
    }

    private void readAnimation(string name, JSONValue map, SkeletonData skeletonData) {
        Timeline[] timelines;
        float duration = 0;

        if("slots" in map) {
            foreach(slotName, timelineMap; map["slots"].object) {
                int slotIndex = skeletonData.findSlotIndex(slotName);
                foreach(timelineName, values; timelineMap.object) {
                    if(timelineName == "color") {
                        auto timeline = new ColorTimeline(values.array.length);
                        timeline.slotIndex = slotIndex;

                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float time = valueMap["time"].number;
                            string c = valueMap["color"].text;
                            timeline.setFrame(frameIndex, time, toColor(c, 0), toColor(c, 1), toColor(c, 2), toColor(c, 3));
                            readCurve(timeline, frameIndex, valueMap);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount * 5 - 5]);
                    } else if(timelineName == "attachment") {
                        auto timeline = new AttachmentTimeline(values.array.length);
                        timeline.slotIndex = slotIndex;

                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float time = valueMap["time"].number;
                            timeline.setFrame(frameIndex, time, valueMap["name"].text);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount - 1]);
                    } else {
                        throw new Exception("Invalid timeline type for a slot: " ~ timelineName ~ " (" ~ slotName ~ ")");
                    }
                }
            }
        }

        if("bones" in map) {
            foreach(boneName, timelineMap; map["bones"].object) {
                int boneIndex = skeletonData.findBoneIndex(boneName);
                if(boneIndex == -1)
                    throw new Exception("Bone not found: " ~ boneName);
                
                foreach(timelineName, values; timelineMap.object) {
                    if(timelineName == "rotate") {
                        auto timeline = new RotateTimeline(values.array.length);
                        timeline.boneIndex = boneIndex;

                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float time = valueMap["time"].number;
                            timeline.setFrame(frameIndex, time, valueMap["angle"].number);
                            readCurve(timeline, frameIndex, valueMap);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount * 2 - 2]);
                    } else if(timelineName == "translate" || timelineName == "scale") {
                        TranslateTimeline timeline;
                        float timelineScale = 1;
                        if(timelineName == "scale") {
                            timeline = new ScaleTimeline(values.array.length);
                        } else {
                            timeline = new TranslateTimeline(values.array.length);
                            timelineScale = scale;
                        }
                        timeline.boneIndex = boneIndex;

                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float time = valueMap["time"].number;
                            float x = getFloat(valueMap, "x", 0);
                            float y = getFloat(valueMap, "y", 0);
                            timeline.setFrame(frameIndex, time, x * timelineScale, y * timelineScale);
                            readCurve(timeline, frameIndex, valueMap);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount * 3 - 3]);
                    } else if(timelineName == "flipX" || timelineName == "flipY") {
                        bool x = (timelineName == "flipX");
                        auto timeline = x ? new FlipXTimeline(values.array.length) : new FlipYTimeline(values.array.length);
                        timeline.boneIndex = boneIndex;

                        string field = x ? "x" : "y";
                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float time = valueMap["time"].number;
                            timeline.setFrame(frameIndex, time, field in valueMap ? valueMap[field].type == JSON_TYPE.TRUE : false);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount * 2 - 2]);
                    } else {
                        throw new Exception("Invalid timeline type for a bone: " ~ timelineName ~ " (" ~ boneName ~ ")");
                    }
                }
            }
        }

        if("ik" in map) {
            foreach(ikName, values; map["ik"].object) {
                IkConstraintData ikConstraint = skeletonData.findIkConstraint(ikName);
                auto timeline = new IkConstraintTimeline(values.array.length);
                timeline.ikConstraintIndex = countUntil(skeletonData.ikConstraints, ikConstraint);
                int frameIndex = 0;
                foreach(valueMap; values.array) {
                    float time = valueMap["time"].number;
                    float mix = getFloat(valueMap, "mix", 1);
                    bool bendPositive = getBool(valueMap, "bendPositive", true);
                    timeline.setFrame(frameIndex, time, mix, bendPositive ? 1 : -1);
                    readCurve(timeline, frameIndex, valueMap);
                    frameIndex++;
                }
                timelines ~= timeline;
                duration = max(duration, timeline.frames[timeline.frameCount * 3 - 3]);
            }
        }

        if("ffd" in map) {
            foreach(ffdName, ffdValue; map["ffd"].object) {
                Skin skin = skeletonData.findSkin(ffdName);
                foreach(slotKey, slotValue; ffdValue.object) {
                    int slotIndex = skeletonData.findSlotIndex(slotKey);
                    foreach(key, values; slotValue.object) {
                        auto timeline = new FFDTimeline(values.array.length);
                        Attachment attachment = skin.getAttachment(slotIndex, key);
                        if(attachment is null)
                            throw new Exception("FFD attachment not found: " ~ key);
                        timeline.slotIndex = slotIndex;
                        timeline.attachment = attachment;

                        int vertexCount;
                        if(cast(MeshAttachment)attachment)
                            vertexCount = (cast(MeshAttachment)attachment).vertices.length;
                        else
                            vertexCount = (cast(SkinnedMeshAttachment)attachment).weights.length / 3 * 2;

                        int frameIndex = 0;
                        foreach(valueMap; values.array) {
                            float[] vertices;
                            if("vertices" !in valueMap) {
                                if(cast(MeshAttachment)attachment) {
                                    vertices = (cast(MeshAttachment)attachment).vertices;
                                } else {
                                    vertices = new float[vertexCount];
									vertices[] = 0;
								}
                            } else {
                                auto verticesValue = valueMap["vertices"].array;
                                vertices = new float[vertexCount];
								vertices[] = 0;
                                int start = getInt(valueMap, "offset", 0);
                                if(scale == 1) {
                                    for(int i = 0; i < verticesValue.length; i++)
                                        vertices[i + start] = verticesValue[i].number;
                                } else {
                                    for(int i = 0; i < verticesValue.length; i++)
                                        vertices[i + start] = verticesValue[i].number * scale;
                                }
                                if(cast(MeshAttachment)attachment) {
                                    float[] meshVertices = (cast(MeshAttachment)attachment).vertices;
                                    for(int i = 0; i < vertexCount; i++)
                                        vertices[i] += meshVertices[i];
                                }
                            }

                            timeline.setFrame(frameIndex, valueMap["time"].number, vertices);
                            readCurve(timeline, frameIndex, valueMap);
                            frameIndex++;
                        }
                        timelines ~= timeline;
                        duration = max(duration, timeline.frames[timeline.frameCount - 1]);
                    }
                }
            }
        }

        if("drawOrder" in map || "draworder" in map) {
            auto values = map["drawOrder" in map ? "drawOrder" : "draworder"].array;
            auto timeline = new DrawOrderTimeline(values.length);
            int slotCount = skeletonData.slots.length;
            int frameIndex = 0;
            foreach(drawOrderMap; values) {
                int[] drawOrder;
                if("offsets" in drawOrderMap) {
                    drawOrder = new int[slotCount];
                    for(int i = slotCount - 1; i >= 0; i--)
                        drawOrder[i] = -1;
                    auto offsets = drawOrderMap["offsets"].array;
                    int[] unchanged = new int[slotCount - offsets.length];
                    int originalIndex = 0, unchangedIndex = 0;
                    foreach(offsetMap; offsets) {
                        int slotIndex = skeletonData.findSlotIndex(offsetMap["slot"].text);
                        if(slotIndex == -1)
                            throw new Exception("Slot not found: " ~ offsetMap["slot"].text);
                        // Collect unchanged items.
                        while(originalIndex != slotIndex)
                            unchanged[unchangedIndex++] = originalIndex++;
                        // Set changed items.
                        int index = originalIndex + offsetMap["offset"].integer.to!int;
                        drawOrder[index] = originalIndex++;
                    }
                    // Collect remaining unchanged items.
                    while(originalIndex < slotCount)
                        unchanged[unchangedIndex++] = originalIndex++;
                    // Fill in unchanged items.
                    for(int i = slotCount - 1; i >= 0; i--)
                        if(drawOrder[i] == -1)
                            drawOrder[i] = unchanged[--unchangedIndex];
                }
                timeline.setFrame(frameIndex++, drawOrderMap["time"].number, drawOrder);
            }
            timelines ~= timeline;
            duration = max(duration, timeline.frames[timeline.frameCount - 1]);
        }

        if("events" in map) {
            auto eventsMap = map["events"].array;
            auto timeline = new EventTimeline(eventsMap.length);
            int frameIndex = 0;
            foreach(eventMap; eventsMap) {
                EventData eventData = skeletonData.findEvent(eventMap["name"].text);
                if(eventData is null)
                    throw new Exception("Event not found: " ~ eventMap["name"].text);
                auto e = new Event(eventData);
                e.integer = getInt(eventMap, "int", eventData.integer);
                e.number = getFloat(eventMap, "float", eventData.number);
                e.text = getString(eventMap, "string", eventData.text);
                timeline.setFrame(frameIndex++, eventMap["time"].number, e);
            }
            timelines ~= timeline;
            duration = max(duration, timeline.frames[timeline.frameCount - 1]);
        }

        skeletonData.animations ~= new Animation(name, timelines, duration);
    }

    private void readCurve(CurveTimeline timeline, int frameIndex, JSONValue valueMap) {
        if("curve" !in valueMap)
            return;
        JSONValue curveObject = valueMap["curve"];
        if(curveObject.type == JSON_TYPE.STRING && curveObject.text == "stepped") {
            timeline.setStepped(frameIndex);
        } else if(curveObject.type == JSON_TYPE.ARRAY) {
            timeline.setCurve(frameIndex,
                curveObject[0].number,
                curveObject[1].number,
                curveObject[2].number,
                curveObject[3].number);
        }
    }

private:
    AttachmentLoader _attachmentLoader;
    float _scale;
}