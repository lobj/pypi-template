tag:
	git tag ${TAG} -m "${MSG}"
	git push --tags

.python-version:
	@pyenv virtualenv 3.7.7 $$(basename ${CURDIR}) > /dev/null 2>&1 || true
	@pyenv local $$(basename ${CURDIR})
	@pyenv version

requirements: .python-version requirements.txt
	@pip install --upgrade -r requirements.txt > /dev/null

upgrade: requirements
	@pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U

test:
	tox

dist: 
	rm -rf $@
	python setup.py sdist bdist_wheel

publish-test: dist
	twine upload --repository testpypi dist/*

publish: dist
	twine upload dist/*

coverage: test
	coverage report

docs: requirements
	cd docs; make html
	open docs/_build/html/index.html

PROJECT:=`find . -name '__init__.py' -maxdepth 2 | xargs dirname`

lint:
	@pylint ${PROJECT} | tee lint.txt

clean:
	find . | grep '\.backup' | xargs rm

.PHONY: dist docs


install:
	python3 setup.py install
uninstall:
	pip3 uninstall pypi-template2  -y
reinstall: clean
	make uninstall
	make install

test2:
	cd ../ && mkdir aas && cd aas && pypi-template2