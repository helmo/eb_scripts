#!/bin/bash

# Run all .t test scripts

export TEST_VERBOSE=0
export TEST_FILES=*.t
export PERL_DL_NONLAZY=1 

perl "-MExtUtils::Command::MM" "-e" "test_harness($TEST_VERBOSE, 'module', '')" $TEST_FILES


