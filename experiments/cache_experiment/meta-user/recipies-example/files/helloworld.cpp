#include <iostream>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

int main() {
    json j;
    j["happy"] = true;
    std::cout << "Hello, World!" << j << std::endl;
    
    return 0;
}

