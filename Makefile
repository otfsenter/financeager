VERSION=$$(git describe --tags --abbrev=0)

.PHONY: all test install release coverage lint format style-check

all:
	@echo "Available targets: install, test, release, coverage, lint, format, style-check"

install:
	pip install -U -e .[develop]
	pip install -U -e .[packaging]
	pre-commit install
	gitlint install-hook

test:
	python setup.py test

release: Changelog.md setup.py
	git push --tags origin master
	hub release create -e -m $(VERSION) -m "$$(awk -v RS='' '/\[$(VERSION)\]/' Changelog.md | tail -n+2)" $(VERSION)
	rm -rf dist build
	python setup.py bdist_wheel --universal
	twine upload dist/*

coverage:
	coverage erase
	coverage run --source financeager setup.py test
	coverage report
	coverage html

lint:
	pre-commit run --all-files flake8

format:
	pre-commit run --all-files yapf
	pre-commit run --all-files isort
	pre-commit run --all-files end-of-file-fixer
	pre-commit run --all-files trailing-whitespace

style-check: format lint
