// copy1.cpp : This file contains the 'main' function. Program execution begins and ends there.
// g++ -std=c++17 1k/copy1.cpp -o build/copy1

#include <stdio.h>
#include <filesystem>

namespace stdfs = std::filesystem;

int main(int argc, char** argv)
{
    if (argc < 3) return -1;

    stdfs::path src{ argv[1] };
    stdfs::path dest{ argv[2] }; // directory

    auto filename = src.filename();
    if (*filename.native().c_str() == '*') {

        stdfs::path srcparent = src.parent_path();
        if (stdfs::is_directory(srcparent)) {
            auto extension = filename.extension();
            for (const auto& entry : stdfs::directory_iterator(srcparent))
            {
                if (entry.is_regular_file())
                {
                    auto filepath = entry.path();
                    auto ext = filepath.extension();

                    if (ext == extension) {
                        std::error_code ec;
                        stdfs::copy(filepath, dest, stdfs::copy_options::overwrite_existing, ec);
                        if (!ec) printf("==> copy file %s to %s succeed.\n", filepath.c_str(), dest.c_str());
                        else printf("==> copy file %s to %s failed, ec=%d\n", filepath.c_str(), dest.c_str(), ec.value());
                    }
                }
            }
        }
    }
    else {
        std::error_code ec;
        stdfs::copy(src, dest, stdfs::copy_options::overwrite_existing, ec);
        if (!ec) printf("==> copy file %s to %s succeed.\n", src.c_str(), dest.c_str());
        else printf("==> copy file %s to %s failed, ec=%d\n", src.c_str(), dest.c_str(), ec.value());
    }

    return 0;
}
