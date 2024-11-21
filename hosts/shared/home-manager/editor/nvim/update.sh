#!/bin/bash

rm install.sh && git reset HEAD --hard && git pull && chmod +x install.sh && ./install.sh
