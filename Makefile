SHELL := /bin/bash
DOC_DIR := $(CURDIR)/doc
TEST_DIR := $(CURDIR)/test
GH_PAGES_BRANG := "gh-pages"

.PHONY: install
install:
	@./bin/install.sh $(CURDIR)

.PHONY: uninstall
uninstall:
	@./bin/uninstall.sh $(CURDIR)

.PHONY: doc
doc:
	@cd $(DOC_DIR); \
	doxygen Doxyfile && echo -e "\n => Doc can be acceded at $(DOC_DIR)/html/index.html\n" \

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

.PHONY: test
test:
	@cd $(TEST_DIR); \
	bats .
