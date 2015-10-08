module spine.util.json;

import std.conv : to;
import std.json;

@property float number(JSONValue json) {
    if(json.type == JSON_TYPE.FLOAT)
        return json.floating.to!float;
    if(json.type == JSON_TYPE.INTEGER)
        return json.integer.to!float;
    if(json.type == JSON_TYPE.UINTEGER)
        return json.uinteger.to!float;
    throw new JSONException("Invalid JSON type: "~json.type);
}

@property string text(JSONValue json) {
    if(json.type == JSON_TYPE.NULL)
        return null;
    if(json.type == JSON_TYPE.STRING)
        return json.str;
    throw new JSONException("Invalid JSON type: "~json.type);
}