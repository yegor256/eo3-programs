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

EO_VERSION=0.44.0
HOME_VERSION=0.44.0
EOC_VERSION=0.24.0

.PHONY: .exits
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
SHELL := bash

PROGRAMS = $(shell find . -maxdepth 1 -type d -name '[0-9][0-9]-*' -exec basename {} \;)
EXITS = $(shell echo $(PROGRAMS) | sed 's/^/.exits\//g' | sed 's/$$/.txt/g')
OPTS = --no-color --batch "--parser=$(EO_VERSION)" "--home-tag=$(HOME_VERSION)"

all: $(EXITS)

.exits/%.txt: %
	mkdir -p .exits
	txt=$$(realpath "$@")
	cd "$<" || exit 1
	eoc $(OPTS) test
	eoc $(OPTS) --alone dataize program
	echo "$$?" > "$${txt}"

install:
	npm install --force -g "eolang@$(EOC_VERSION)"

clean:
	for p in $(PROGRAMS); do eoc clean "--target=$${p}/.eoc"; done
	rm -rf .exits
