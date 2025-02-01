#ifndef UTILS_H
#define UTILS_H

#include <string>

// Function to validate the player's name
bool isValidName(const std::string& name);

// Function to generate a random number within a specified range
int generateRandomNumber(int min, int max);

// Function to validate the guessed number
bool isValidGuess(int guess, int min, int max);

#endif // UTILS_H