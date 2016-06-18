#pragma once

#include <tada/base/enum.h>
#include <tada/base/math.h>
#include <tada/base/rotate.h>
#include <tada/color/color.h>
#include <tada/color/names_inl.h>

namespace tada {
namespace color {

using ColorCpp = Color;
using ColorCpp256 = Color256;

template <typename Color>
std::string colorToString(Color const& x) {
    auto c = x.unscale();
    return colorToString(ColorCpp(c[0], c[1], c[2]), Base::normal);
}

template <typename Color>
bool stringToColor(std::string const& x, Color& c) {
    ColorCpp cpp;
    if (not stringToColor(x.c_str(), cpp, Base::normal))
        return false;
    c[0] = cpp[0];
    c[1] = cpp[1];
    c[2] = cpp[2];
    c = c.scale();
    return true;
}

template <typename Color>
Color magic_abs(Color const& x) {
    return x.forEachF(std::abs);
}

template <typename Color>
Color magic_ceil(Color const& x) {
    return x.forEachF(std::ceil);
}

template <typename Color>
Color magic_floor(Color const& x) {
    return x.forEachF(std::floor);
}

template <typename Color>
Color magic_invert(Color const& x) {
    auto r = Color::range_t::range;
   return {invert(x[0], r), invert(x[1], r), invert(x[2], r)};
}

template <typename Color>
Color magic_neg(Color const& x) {
    return x.forEach(std::negate<typename Color::value_type>());
}

template <typename Color>
Color magic_round(Color const& x) {
    // TODO: two argument version!
    return x.forEachF(std::round);
}

template <typename Color>
Color magic_trunc(Color const& x) {
    return x.forEachF(std::trunc);
}

template <typename Color>
int magic_hash(Color const& x) {
    return static_cast<int>(hashPython(x.unscale()) * 256);
}

template <typename Color>
Color magic_add(Color const& x, Color const& y) {
    return {x[0] + y[0], x[1] + y[1], x[2] + y[2]};
}

template <typename Color>
Color magic_truediv(Color const& x, Color const& y) {
    return {divPython(x[0], y[0]),
            divPython(x[1], y[1]),
            divPython(x[2], y[2])};
}

template <typename Color>
Color magic_mod(Color const& x, Color const& y) {
    return {modPython(x[0], y[0]),
            modPython(x[1], y[1]),
            modPython(x[2], y[2])};
}

template <typename Color>
Color magic_mul(Color const& x, Color const& y) {
    return {x[0] * y[0], x[1] * y[1], x[2] * y[2]};
}

template <typename Color>
Color magic_sub(Color const& x, Color const& y) {
    return {x[0] - y[0], x[1] - y[1], x[2] - y[2]};
}

template <typename Color>
Color limit_min(Color const& x, Color const& y) {
    return {std::max(x[0], y[0]),
            std::max(x[1], y[1]),
            std::max(x[2], y[2])};
}

template <typename Color>
Color limit_max(Color const& x, Color const& y) {
    return {std::min(x[0], y[0]),
            std::min(x[1], y[1]),
            std::min(x[2], y[2])};
}

template <typename Color>
Color rotated(Color const& x, int pos) {
    auto y = x;
    rotate(y, pos);
    return y;
}

template <typename Color>
typename Color::value_type distance2(Color const& x, Color const& y) {
    typename Color::value_type total = 0;
    for (auto i = 0; i < x.size(); ++i) {
        auto d = x[i] - y[i];
        total += d * d;
    }
    return total;
}

template <typename Color>
float distance(Color const& x, Color const& y) {
    return std::sqrt(distance2(x, y));
}

template <typename Color>
Color magic_pow(Color const& x, Color const& y) {
    return {powPython(x[0], y[0]),
            powPython(x[1], y[1]),
            powPython(x[2], y[2])};
}

template <typename Color>
Color magic_pow(Color const& x, Color const& y, Color const& z) {
    return {modPython(powPython(x[0], y[0]), z[0]),
            modPython(powPython(x[1], y[1]), z[1]),
            modPython(powPython(x[2], y[2]), z[2])};
}

inline
std::vector<std::string> const& colorNames() {
    return tada::colorNames();
}

inline
bool fixKey(int& key, size_t size) {
    if (key < 0)
        key += size;
    return key >= 0 and key < int(size);
}

template <typename Color>
float compare(Color const& x, Color const& y) {
    if (auto a = x[0] - y[0])
        return a;
    if (auto a = x[1] - y[1])
        return a;
    if (auto a = x[2] - y[2])
        return a;
    return 0.0f;
}

template <typename Color>
bool compare(Color const& x, Color const& y, int richCmp) {
    return cmpToRichcmp(compare(x, y), richCmp);
}

template <typename Color>
void from_hex(uint32_t hex, Color& x) {
    auto c = colorFromHex(hex, Base::normal);
    x[0] = c[0];
    x[1] = c[1];
    x[2] = c[2];
    x = x.scale();
}

template <typename Color>
uint32_t to_hex(Color const& x) {
    auto c = x.unscale();
    return hexFromColor(ColorCpp(c[0], c[1], c[2]), Base::normal);
}

} // color
} // tada