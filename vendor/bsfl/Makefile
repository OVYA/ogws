SHELL := /bin/bash
SRC_DIR := $(CURDIR)/lib
TEST_DIR := $(CURDIR)/test
DOC_DIR := $(CURDIR)/doc
GH_PAGES_BRANG := "gh-pages"

.PHONY: doc
doc:
	@cd $(DOC_DIR); \
	doxygen Doxyfile && echo -e "\n => Doc generated in directory $(DOC_DIR){html/latex}\n" \

.PHONY: test
test:
	@cd $(TEST_DIR); \
	bats .

.PHONY: gh-pages-git-branch-init
gh-pages-git-branch-init: doc
	@git ls-remote --heads origin | grep -q gh-pages || { \
		git checkout --orphan gh-pages && \
		git reset . && \
		git clean --force -d --exclude doc && \
		mv doc/html/* . && \
		git clean --force -d doc && \
		git add . && \
		git commit -m "Generate Doc" && \
		git push -u origin gh-pages; \
	}

.PHONY: gh-pages-git-branch-create
gh-pages-git-branch-create: gh-pages-git-branch-init
	@git rev-parse --quiet --verify gh-pages > /dev/null || { \
		git checkout -b gh-pages origin/gh-pages && \
		git fetch && \
		git merge origin/gh-pages; \
	}

.PHONY: gh-pages-git-branch-create
gh-pages: gh-pages-git-branch-create
	git subtree push --prefix doc/html origin gh-pages
