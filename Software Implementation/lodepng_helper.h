#ifndef LODEPNG_HELPER_H
#define LODEPNG_HELPER_H

#include "lodepng.h"
#include <iostream>

#define STR_EXPAND(s) #s
#define STR(s) STR_EXPAND(s)
#define ASSERT_NO_PNG_ERROR_MSG(error, message) assertNoPNGError(error, std::string("line ") + STR(__LINE__) + (std::string(message).empty() ? std::string("") : (": " + std::string(message))))
#define ASSERT_NO_PNG_ERROR(error) ASSERT_NO_PNG_ERROR_MSG(error, std::string(""))

template<typename T>
std::string valtostr(const T& val) {
    return std::to_string(val);
}

//Print char as a numeric value rather than a character
std::string valtostr(const unsigned char& val) {
    return std::to_string(static_cast<int>(val));
}

//Print char pointer as pointer, not as string
std::string valtostr1(const unsigned int* val) {
    const void *ptr = reinterpret_cast<const void *>(val);
    return std::to_string((int) ptr);
}

template<typename T>
std::string valtostr(const std::vector<T>& val) {
    return std::string("[vector with size ") + std::to_string(val.size()) + std::string("]");
}

template<typename T, typename U>
void assertEquals(const T& expected, const U& actual, const std::string& message = "") {
    if(expected != (T) actual) {
        Serial.print(F("Error: Not equal! Expected "));
        Serial.print(valtostr(expected).c_str());
        Serial.print(F(" got "));
        Serial.print(valtostr((T) actual).c_str());
        Serial.print(F(". "));
        Serial.print(F("Message: "));
        Serial.println(message.c_str());
    }
}

//assert that no error
void assertNoPNGError(unsigned error, const std::string& message = "") {
    if(error) {
        std::string msg = (message == "") ? lodepng_error_text(error)
                                        : message + std::string(": ") + lodepng_error_text(error);
        assertEquals(0, error, msg);
    }
}

int fromBase64(int v) {
    if(v >= 'A' && v <= 'Z') return (v - 'A');
    if(v >= 'a' && v <= 'z') return (v - 'a' + 26);
    if(v >= '0' && v <= '9') return (v - '0' + 52);
    if(v == '+') return 62;
    if(v == '/') return 63;
    return 0; //v == '='
}

//T and U can be std::string or std::vector<unsigned char>
template<typename T, typename U>
void fromBase64(T& out, const U& in) {
    for(size_t i = 0; i + 3 < in.size(); i += 4) {
        int v = 262144 * fromBase64(in[i]) + 4096 * fromBase64(in[i + 1]) + 64 * fromBase64(in[i + 2]) + fromBase64(in[i + 3]);
        out.push_back((v >> 16) & 0xff);
        if(in[i + 2] != '=') out.push_back((v >> 8) & 0xff);
        if(in[i + 3] != '=') out.push_back((v >> 0) & 0xff);
    }
}


#endif