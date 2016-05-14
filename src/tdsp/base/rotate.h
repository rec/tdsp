#pragma once

#include <algorithm>
#include <vector>

namespace tdsp {

template <typename Collection>
void rotate(Collection& coll, int pos) {
    if (auto size = coll.size()) {
        pos = pos % size;
        if (pos < 0)
            pos += size;
        std::rotate(coll.begin(), coll.begin() + pos, coll.end());
    }
}

} // namespace tdsp
