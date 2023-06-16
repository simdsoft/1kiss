// nsdk1k.cpp : This file contains the 'main' function. Program execution begins and ends there.
// g++ -std=c++17 1k/nsdk1k.cpp -o build/nsdk1k

// usage: nsdk1k xcode_ver target <simulator>
// i.e. nsdk1k 13.4 ios
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string_view>
#include <unordered_map>
using namespace std::string_view_literals;

int main(int argc, char** argv)
{
    if (argc < 3) return EINVAL;
    bool simulator = false;
    if (argc >= 4) simulator = !!atoi(argv[3]);

    std::unordered_map<std::string_view, std::unordered_map<std::string_view, std::string_view>> sdks = {
      {"osx"sv,
        {
          {"13.1.0"sv, "12.0"sv},
          {"13.2.1"sv, "12.1"sv},
          {"13.3.1"sv, "12.3"sv},
          {"13.4.0"sv, "12.3"sv},
          {"13.4.1"sv, "12.3"sv},
          {"14.0.1"sv, "12.3"sv},
          {"14.1.0"sv, "13.0"sv},
          {"14.2.0"sv, "13.1"sv}
        }
      },
      {"ios"sv,
        {
          {"13.1.0"sv, "15.0"sv},
          {"13.2.1"sv, "15.2"sv},
          {"13.3.1"sv, "15.4"sv},
          {"13.4.0"sv, "15.5"sv},
          {"13.4.1"sv, "15.5"sv},
          {"14.0.1"sv, "16.0"sv},
          {"14.1.0"sv, "16.1"sv},
          {"14.2.0"sv, "16.2"sv}
        }
      },
      {"tvos"sv,
        {
          {"13.1.0"sv, "15.0"sv},
          {"13.2.1"sv, "15.2"sv},
          {"13.3.1"sv, "15.4"sv},
          {"13.4.0"sv, "15.4"sv},
          {"13.4.1"sv, "15.4"sv},
          {"14.0.1"sv, "16.0"sv},
          {"14.1.0"sv, "16.1"sv},
          {"14.2.0"sv, "16.1"sv}
        }
      },
      {"watchos"sv,
        {
          {"13.1.0"sv, "8.0"sv},
          {"13.2.1"sv, "8.3"sv},
          {"13.3.1"sv, "8.5"sv},
          {"13.4.1"sv, "8.5"sv},
          {"14.0.1"sv, "9.0"sv},
          {"14.1.0"sv, "9.1"sv},
          {"14.2.0"sv, "9.1"sv}
        }
      }
    };

    std::string_view xcode_ver = argv[1];
    std::string_view target = argv[2];
    auto target_it = sdks.find(target);
    if (target_it != sdks.end()) {
        auto sdk_it = target_it->second.find(xcode_ver);
        if (sdk_it != target_it->second.end()) {
            auto& sdk_ver = sdk_it->second;
            if (target == "osx"sv) {
                printf("%s%s", "macosx", sdk_ver.data());
            }
            else if (target == "ios"sv) { // ios
                printf("%s%s", !simulator ? "iphoneos" : "iphonesimulator", sdk_ver.data());
            }
            else if (target == "tvos"sv) { // tvos
                printf("%s%s", !simulator ? "appletvos" : "appletvsimulator", sdk_ver.data());
            }
            else if (target == "watchos"sv) { // watchos
                printf("%s%s", !simulator ? "watchos" : "watchsimulator", sdk_ver.data());
            }
            return 0;
        }
    }

    return ENOENT;
}
