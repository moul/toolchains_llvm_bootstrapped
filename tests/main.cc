#include <iostream>
#include <stdexcept>

void thrower() {
    throw std::runtime_error("testing unwind");
}

int main() {
    std::cout << "Hello, World!" << std::endl;
    try {
        thrower();
    } catch (const std::exception& e) {
        std::cout << "Caught: " << e.what() << std::endl;
    }
}
