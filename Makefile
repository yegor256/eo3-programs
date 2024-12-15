# The MIT License (MIT)
#
# Copyright (c) 2022-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

EO_VERSION=0.48.2
HOME_VERSION=0.48.2
EOC_VERSION=0.27.1

.PHONY: .exits test link install clean
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
SHELL := bash

EO = $(shell find eo3 -type f -name '*.eo')
JAR = .eoc/eoc.jar
PROGRAMS = $(shell find eo3 -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
EXITS = $(shell echo $(PROGRAMS) | sed 's/^/.exits\//g' | sed 's/$$/.txt/g')
PASSES = $(shell echo $(PROGRAMS) | sed 's/^/.passes\//g' | sed 's/$$/.txt/g')
OPTS = --easy --no-color --batch "--parser=$(EO_VERSION)" "--home-tag=$(HOME_VERSION)"

all: $(PASSES) $(EXITS)

$(JAR): $(EO)
	eoc $(OPTS) link

.passes/%.txt: eo3/% $(JAR)
	mkdir -p .passes
	eoc $(OPTS) --alone test
	echo "$$?" > "$@"

.exits/%.txt: eo3/% $(JAR)
	mkdir -p .exits
	eoc $(OPTS) --alone dataize --stack=256M "eo3.$$(basename "$<").program"
	echo "$$?" > "$@"

install:
	npm install --force -g "eolang@$(EOC_VERSION)"

clean:
	eoc clean
	rm -rf .exits
	rm -rf .passes
