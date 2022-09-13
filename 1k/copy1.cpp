// copy1.cpp : This file contains the 'main' function. Program execution begins and ends there.
// g++ -std=c++17 1k/copy1.cpp -o build/copy1

#include <filesystem>

namespace stdfs = std::filesystem;

int main(int argc, char** argv)
{
    if (argc < 2) return -1;

    stdfs::path src{ argv[1] };
    stdfs::path dest{ argv[2] }; // directory

    auto filename = src.filename();
    if (*filename.native().c_str() == '*') {

        stdfs::path srcparent = src.parent_path();
        if (stdfs::is_directory(srcparent)) {
            auto extension = filename.extension();
            for (const auto& entry : stdfs::directory_iterator(srcparent))
            {
                const auto isDir = entry.is_directory();
                if (entry.is_regular_file())
                {
                    auto ext = entry.path().extension();

                    if (ext == extension) {
                        std::error_code ec;
                        stdfs::copy(entry, dest, stdfs::copy_options::overwrite_existing, ec);
                    }
                }
            }
        }
    }
    else {
        std::error_code ec;
        stdfs::copy(src, dest, stdfs::copy_options::overwrite_existing, ec);
    }

    return 0;
}
