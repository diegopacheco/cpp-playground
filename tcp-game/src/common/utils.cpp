#include <iostream>
#include <cstdlib>
#include <ctime>
#include "utils.h"

void initializeRandom() {
    std::srand(static_cast<unsigned int>(std::time(nullptr)));
}

int generateRandomNumber(int min, int max) {
    return std::rand() % (max - min + 1) + min;
}

bool validateInput(const std::string& input) {
    for (char c : input) {
        if (!std::isdigit(c)) {
            return false;
        }
    }
    return true;
}