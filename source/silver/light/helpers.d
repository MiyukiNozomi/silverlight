module silver.light.helpers;

import std.string;
import std.array;
import std.conv;
import std.range;
import std.algorithm;

/** gets a sub array, out of an array, haha!*/
auto subRange(R)(R s, size_t beg, size_t end) {
    return s.dropExactly(beg).take(end - beg);
}

/** .text is too hard to remember lol*/
string subString(string s, size_t beg, size_t end) {
    return s.subRange(beg, end).text;
}

/**well, returns the line and column of a index in a string, yeah.
it kinda sucks but it works.*/
void getLocation(string text,int textIndex,out int line,out int col) {
    line = 1;
    col = 0;
    for (int i = 0; i <= textIndex; i++) {
        if (text[i] == '\n') {
            ++line;
            col = 1;
        } else {
            ++col;
        }
    }
}