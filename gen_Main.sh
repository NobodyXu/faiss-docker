#!/bin/bash

# Generate main.cc for testing faiss
find /usr/local/include/faiss/ \
     -maxdepth 1 \
     -path /usr/local/include/faiss/impl -prune -o \
     -name '*.h' -printf '#include <%P>\n'

echo '
#include <iostream>

int main(int argc, char* argv[])
{
    std::cout << "Hello, world!" << std::endl;
    return 0;
}'
