#include <gtest/gtest.h>

// Demonstrate some basic assertions.
TEST(HelloTest, BasicAssertions) {
  // Expect two strings to be equal.
  EXPECT_EQ("hello", "hello");
  // Expect equality.
  EXPECT_EQ(21, 21);
}
