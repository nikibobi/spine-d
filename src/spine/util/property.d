module spine.util.property;

import std.algorithm : reduce;
import std.array : split;
import std.conv;
import std.uni;
import std.string;
version(unittest) {
    import std.stdio : write, writeln;
    import std.exception; 
}

alias Conv!("_||") DefaultConv;

struct Conv(string convention, string delim = "|")
if(delim.length == 1 && convention.countchars(delim) == 2)
{
    enum string pre = convention.split(delim)[0];
    enum string cases = convention.split(delim)[1];
    enum string post = convention.split(delim)[2];

    static string propertyName(string fieldName)()
    if(fieldName[0..pre.length] == pre && fieldName[$-post.length..$] == post)
    in {
        debug pragma(msg, format("%1$s('%2$s');", mixin(FUNCTION), fieldName));
    }
    body {
        string result = fieldName[pre.length..$-post.length];
        static if(cases.length > 0)
        {
            //TODO: make cases more advanced
            //snake_case
            //camelCase
            //PascalCase
            //UPPER_CASE
            static if(cases[0].isUpper())
                return to!string(result[0].toUpper())~result[1..$];
            else static if(cases[0].isLower())
                return to!string(result[0].toLower())~result[1..$];
        }
        return result;
    }

    string toString() {
        return convention;
    }
}

unittest {
    auto myConv = Conv!("my_|lowercase|_conv")();
    assert(myConv.pre == "my_");
    assert(myConv.cases == "lowercase");
    assert(myConv.post == "_conv");
    assert(myConv.propertyName!("my_IsBob_conv") == "isBob");
    assert(myConv.toString() == "my_|lowercase|_conv");

    DefaultConv def1;
    assert(def1.toString() == "_||");

    auto def2 = DefaultConv();
    assert(def2.toString() == "_||");
}

mixin template Get(alias name, alias conv = DefaultConv) {
    mixin(PropTemplate!(FormatGet, name, conv));
}

mixin template Set(alias name, alias conv = DefaultConv) {
    mixin(PropTemplate!(FormatSet, name, conv));
}

mixin template Prop(alias name, alias conv = DefaultConv) {
    mixin(PropTemplate!(FormatBoth, name, conv));
}

enum string FormatGet = 
"@property %1$s %2$s() {
    return %3$s;
}";
enum string FormatSet =
"@property void %2$s(%1$s value) {
    %3$s = value;
}";
enum string FormatBoth =
"@property {
    %1$s %2$s() {
        return %3$s;
    }
    void %2$s(%1$s value) {
        %3$s = value;
    }
}";

template PropTemplate(string mold, alias name, TConv = DefaultConv) {
    enum PropTemplate = format(mold,
                               typeof(name).stringof, //property type
                               TConv.propertyName!(name.stringof), //property name
                               name.stringof); //backing field
}

//test PropTemplate to see what it generates
debug unittest {
    int m_number__;
    alias Conv!("m_~U~__", "~") nameConv;
    writeln(PropTemplate!(FormatGet, m_number__, nameConv));
    writeln(PropTemplate!(FormatSet, m_number__, nameConv));
    writeln(PropTemplate!(FormatBoth, m_number__, nameConv));
}

//test making custom prop template using custom convention
private mixin template MPropPrivate(alias name) {
    mixin Prop!(name, Conv!("m_|camelCase|_private"));
}

unittest {
    class Foo {
        mixin Get!_readOnly; // test only 'get'
        mixin Set!_writeOnly; // test only 'set'
        mixin Prop!_readWrite; // test both 'get' and 'set'
        mixin MPropPrivate!m_prop_private; // test different naming convention

        static int my_lucky_number = 42;

        // test mixin 'get' in function declaration
        int get_number() {
            mixin Get!(my_lucky_number, Conv!("my_||"));
            return my_lucky_number;
        }

        // test mixin 'set' in function declaration
        void set_number(int value) {
            mixin Set!(my_lucky_number, Conv!("my_||"));
            my_lucky_number = value;
        }
    private:
        int _readOnly;
        int _writeOnly;
        int _readWrite;
        int m_prop_private;
    }

    //test if everything is generated properly
    Foo foo = new Foo;
    assert(foo.readOnly == 0);
    foo.writeOnly = 42;
    foo.readWrite = 2;
    assert(foo.readWrite == 2);
    foo.m_prop_private = 0;
    assert(foo.m_prop_private == foo.readOnly);
    assert(foo.get_number() == foo.my_lucky_number);
    foo.set_number(2);
    assert(foo.my_lucky_number == 2);
}