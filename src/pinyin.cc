#include "pinyin.h"

#ifndef DISABLE_CMRC
#include <cmrc/cmrc.hpp>
#endif

#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <stdexcept>
#include <vector>
#include <fstream> // Added for file reading when CMRC is disabled

// Add these includes for macOS
#ifdef __APPLE__
#include <CoreFoundation/CoreFoundation.h>
#include <limits.h> // For PATH_MAX
#ifndef PATH_MAX
#define PATH_MAX 1024 // Fallback definition if not defined
#endif
#endif

#ifndef DISABLE_CMRC
CMRC_DECLARE(pinyin_text);
#endif

namespace simple_tokenizer
{

  PinYin::PinYin() { pinyin = build_pinyin_map(); }

  std::set<std::string> PinYin::to_plain(const std::string &input)
  {
    // This part remains unchanged
    std::set<std::string> s;
    std::string value;
    for (size_t i = 0, len = 0; i != input.length(); i += len)
    {
      auto byte = input[i];
      if (byte == ',')
      {
        s.insert(value);
        s.insert(value.substr(0, 1));
        value.clear();
        len = 1;
        continue;
      }
      len = get_str_len((unsigned char)byte);
      if (len == 1)
      {
        // Skip invisible byte
        // Fix the issue in Windows https://github.com/wangfenjin/simple/pull/143
        if (std::isspace(byte) || std::iscntrl(byte))
        {
          continue;
        }
        value.push_back(byte);
        continue;
      }
      auto it = tone_to_plain.find(input.substr(i, len));
      if (it != tone_to_plain.end())
      {
        value.push_back(it->second);
      }
      else
      {
        value.push_back(byte);
      }
    }
    s.insert(value);
    s.insert(value.substr(0, 1));
    return s;
  }

  // Modified build_pinyin_map() function with conditional implementation
  std::map<int, std::vector<std::string>> PinYin::build_pinyin_map()
  {
    std::map<int, std::vector<std::string>> map;

    std::string pinyin_content;

#ifndef DISABLE_CMRC
    // Use CMRC to load the embedded resource
    auto fs = cmrc::pinyin_text::get_filesystem();
    auto pinyin_data = fs.open("contrib/pinyin.txt");
    pinyin_content = std::string(pinyin_data.begin(), pinyin_data.end());
#else
    // Alternative implementation for macOS without CMRC
    // Adjust the file path as needed for your macOS environment
    std::string pinyin_path = "contrib/pinyin.txt";

// For macOS bundle, you might need to get the resource path
#ifdef __APPLE__
    // Using bundle resource path if available
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    if (mainBundle)
    {
      CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
      if (resourcesURL)
      {
        char path[PATH_MAX];
        if (CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
        {
          pinyin_path = std::string(path) + "/pinyin.txt";
        }
        CFRelease(resourcesURL);
      }
    }
#endif

    std::ifstream file(pinyin_path);
    if (!file.is_open())
    {
      // Fallback paths if needed
      file.open("./pinyin.txt");
      if (!file.is_open())
      {
        // As a last resort, you could include a small subset of hard-coded values
        // or throw an error
        return map; // Return empty map if file can't be found
      }
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    pinyin_content = buffer.str();
#endif

    // Common parsing code for both paths
    std::istringstream pinyin_file(pinyin_content);
    std::string line;
    char delimiter = ' ';
    std::string cp, py;

    while (std::getline(pinyin_file, line))
    {
      if (line.length() == 0 || line[0] == '#')
        continue;
      std::stringstream tokenStream(line);
      std::getline(tokenStream, cp, delimiter);
      std::getline(tokenStream, py, delimiter);
      int codepoint = static_cast<int>(std::stoul(cp.substr(2, cp.length() - 3), 0, 16l));
      std::set<std::string> s = to_plain(py);
      std::vector<std::string> m(s.size());
      std::copy(s.begin(), s.end(), m.begin());
      map[codepoint] = m;
    }

    return map;
  }

  // The rest of the file remains unchanged...
  int PinYin::get_str_len(unsigned char byte)
  {
    if (byte >= 0xF0)
      return 4;
    else if (byte >= 0xE0)
      return 3;
    else if (byte >= 0xC0)
      return 2;
    return 1;
  }

  int PinYin::codepoint(const std::string &u)
  {
    size_t l = u.length();
    if (l < 1)
      return -1;
    size_t len = get_str_len((unsigned char)u[0]);
    if (l < len)
      return -1;
    switch (len)
    {
    case 1:
      return (unsigned char)u[0];
    case 2:
      return ((unsigned char)u[0] - 192) * 64 + ((unsigned char)u[1] - 128);
    case 3: // most Chinese char in here
      return ((unsigned char)u[0] - 224) * 4096 + ((unsigned char)u[1] - 128) * 64 + ((unsigned char)u[2] - 128);
    case 4:
      return ((unsigned char)u[0] - 240) * 262144 + ((unsigned char)u[1] - 128) * 4096 +
             ((unsigned char)u[2] - 128) * 64 + ((unsigned char)u[3] - 128);
    default:
      throw std::runtime_error("should never happen");
    }
  }

  const std::vector<std::string> &PinYin::get_pinyin(const std::string &chinese) { return pinyin[codepoint(chinese)]; }

  std::vector<std::string> PinYin::_split_pinyin(const std::string &input, int begin, int end)
  {
    if (begin >= end)
    {
      return empty_vector;
    }
    if (begin == end - 1)
    {
      return {input.substr(begin, end - begin)};
    }
    std::vector<std::string> result;
    std::string full = input.substr(begin, end - begin);
    if (pinyin_prefix.find(full) != pinyin_prefix.end() || pinyin_valid.find(full) != pinyin_valid.end())
    {
      result.push_back(full);
    }
    int start = begin + 1;
    while (start < end)
    {
      std::string first = input.substr(begin, start - begin);
      if (pinyin_valid.find(first) == pinyin_valid.end())
      {
        ++start;
        continue;
      }
      std::vector<std::string> tmp = _split_pinyin(input, start, end);
      for (const auto &s : tmp)
      {
        result.push_back(first + "+" + s);
      }
      ++start;
    }
    return result;
  }

  std::set<std::string> PinYin::split_pinyin(const std::string &input)
  {
    int slen = (int)input.size();
    const int max_length = 20;
    if (slen > max_length || slen <= 1)
    {
      return {input};
    }

    std::string spacedInput;
    for (auto c : input)
    {
      spacedInput.push_back('+');
      spacedInput.push_back(c);
    }
    spacedInput = spacedInput.substr(1, spacedInput.size());

    if (slen > 2)
    {
      std::vector<std::string> tmp = _split_pinyin(input, 0, slen);
      std::set<std::string> s(tmp.begin(), tmp.end());
      s.insert(spacedInput);
      s.insert(input);
      return s;
    }
    return {input, spacedInput};
  }

} // namespace simple_tokenizer