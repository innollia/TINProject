// Build-environment shim, not part of nkido.
//
// nkido calls std::countr_zero without including <bit>. Clang and GCC pull
// that header in transitively; MSVC does not, so /std:c++20 alone is not
// enough and pattern_compiler.hpp fails to compile. Force-including <bit>
// fixes it without touching the clone's sources.
//
// Used as: /FI C:/projects/_tools/deps/std_bit_shim.h
#include <bit>
