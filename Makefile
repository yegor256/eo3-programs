# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

EO_VERSION=1.0-SNAPSHOT
HOME_VERSION=$(EO_VERSION)
EOC_VERSION=0.29.0

.PHONY: test link install clean
.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
SHELL := bash

EO = $(shell find eo3 -type f -name '*.eo')
JAR = .eoc/eoc.jar
PROGRAMS = $(shell find eo3 -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
EXITS = $(shell echo $(PROGRAMS) | awk '{for(i=1;i<=NF;i++) $$i=".exits/"$$i".txt"}1')
OPTS = --easy --no-color --verbose --batch --parser "$(EO_VERSION)" --home-tag "$(HOME_VERSION)"

all: .passed.txt $(EXITS)

test: .passed.txt

$(JAR): $(EO)
	eoc $(OPTS) link

.passed.txt: $(JAR)
	eoc $(OPTS) --alone --verbose test --heap=1G --stack=256M
	echo "$$?" > "$@"

.exits/%.txt: eo3/% $(JAR)
	mkdir -p .exits
	eoc $(OPTS) --alone dataize --heap=1G --stack=256M "eo3.$$(basename "$<").program"
	echo "$$?" > "$@"

install:
	npm install --force -g "eolang@$(EOC_VERSION)"

clean:
	eoc clean
	rm -rf .exits
	rm -rf .passes
