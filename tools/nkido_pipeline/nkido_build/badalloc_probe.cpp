"""Locate the bad allocation in nkido's akkado compiler.

Not part of the pipeline. Kept because the answer is not derivable from the
build and nobody should have to walk through it again.

nkido v0.4.9 built with MSVC dies with 0xC0000409 on any non-empty patch. The
CLI has no try/catch, so the real failure is an escaping std::bad_alloc. This
binary calls the library directly and reports what it was asked for.

    nkido -DBUILD_DIR=<cloned nkido> build.cmd
    probe.exe 1     # Version only, is static init itself broken
    probe.exe 2     # compile("")          -> clean "Empty source file" diagnostic
    probe.exe 3     # compile(one line)    -> std::bad_alloc, and the size it asked for

Result on 2026-09-28, Release and Debug libraries alike, so it is not an
optimiser artefact:

    compile("")            -> ok, 1 diagnostic, 0 bytes of bytecode
    compile("sine(440) |> out(%)") -> threw: bad allocation
    largest single request  72621737992257591 bytes = 0x0102011600000037
    low 32 bits             0x37 = 55   (a plausible count)
    high 32 bits            0x01020116  (neighbouring memory, not zero)

A 64-bit size_t getting a 32-bit value without its upper half cleared. Works on
clang-cl, so the workaround is to swap the front end rather than patch the
tool. See music/PIPELINE_REVIEW.md 3-1.
"""

#include <cstdio>
#include <cstdlib>
#include <exception>
#include <new>
#include <string>

#include "akkado/akkado.hpp"

static unsigned long long g_total = 0;
static unsigned long long g_peak_one = 0;

void* operator new(std::size_t bytes) {
    if (bytes >= (1ull << 30)) {
        std::printf("  [new] %llu bytes (0x%llX, %.2f GiB)\n",
                    static_cast<unsigned long long>(bytes),
                    static_cast<unsigned long long>(bytes),
                    bytes / 1073741824.0);
        std::fflush(stdout);
    }
    if (bytes > g_peak_one) g_peak_one = bytes;
    g_total += bytes;
    void* p = std::malloc(bytes ? bytes : 1);
    if (!p) throw std::bad_alloc();
    return p;
}

void* operator new[](std::size_t bytes) { return operator new(bytes); }
void operator delete(void* p) noexcept { std::free(p); }
void operator delete[](void* p) noexcept { std::free(p); }
void operator delete(void* p, std::size_t) noexcept { std::free(p); }
void operator delete[](void* p, std::size_t) noexcept { std::free(p); }


int main(int argc, char** argv) {
    const int which = (argc > 1) ? std::atoi(argv[1]) : 1;

    if (which == 1) {
        std::printf("akkado version: %s\n", akkado::Version::string().data());
        return 0;
    }

    const std::string source = (which == 2)
        ? std::string("")
        : std::string("sine(440) |> out(%)");
    std::printf("case %d, source %zu bytes\n", which, source.size());
    std::fflush(stdout);

    try {
        akkado::CompileResult result = akkado::compile(source);
        std::printf("  ok success=%d diagnostics=%zu bytecode=%zu\n",
                    static_cast<int>(result.success), result.diagnostics.size(),
                    result.program.bytecode.size());
        for (const auto& d : result.diagnostics) {
            std::printf("  diag %s\n", d.message.c_str());
        }
    } catch (const std::bad_alloc&) {
        std::printf("  threw: std::bad_alloc\n");
    } catch (const std::exception& e) {
        std::printf("  threw: %s\n", e.what());
    }

    std::printf("  peak single request %.2f MiB, cumulative %.2f GiB\n",
                g_peak_one / 1048576.0, g_total / 1073741824.0);
    return 0;
}
