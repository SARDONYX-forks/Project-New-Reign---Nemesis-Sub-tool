#ifndef ALPHANUM__HPP
#define ALPHANUM__HPP

#include <shlwapi.h>
#include <string>

struct alphanum_less {
  using first_argument_type = std::string;
  using second_argument_type = std::string;
  using result_type = bool;

  bool operator()(const std::string &left, const std::string &right) const {
    return lstrcmpiA(LPCSTR(left.c_str()), LPCSTR(right.c_str())) < 0;
  }
};

#endif
