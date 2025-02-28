#!/bin/bash

set -e

if [[ $TEST == "API" ]]; then
  # Run code linters
  flake8 .
  isort . --check-only
  # Run tests with code coverage
  pytest -v tests/ --cov=m2cgen/ --cov-report=xml:coverage.xml --ignore=tests/e2e/
  # Upload code coverage
  wget -q https://uploader.codecov.io/latest/linux/codecov -O codecov
  chmod +x codecov
  ./codecov -f coverage.xml -Z
  # Generate code examples
  python setup.py develop
  python tools/generate_code_examples.py ./generated_code_examples
fi

if [[ $TEST == "E2E" ]]; then
  python setup.py install
  rm -rfd m2cgen/
  pytest -v "-m=$LANG" "-k=not(xgboost_XGBClassifier and elixir and train_model_classification_binary2)" tests/e2e/
fi

if [[ $RELEASE == "true" ]]; then
  python setup.py bdist_wheel --plat-name=any --python-tag=py3
  python setup.py sdist
fi
