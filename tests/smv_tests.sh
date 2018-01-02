#! /bin/sh -
# These unit tests require ./shunit2 to be present.

oneTimeSetUp() {
	SHUNIT_TMPDIR="$(mktemp -d)"
}

oneTimeTearDown() {
	rmdir "$SHUNIT_TMPDIR"
}

setUp() {
	cd "$SHUNIT_TMPDIR"
	mkdir SOURCE
	mkdir TARGET
	mkdir TARGET/SOURCE
	echo "foo"     > SOURCE/A
	echo "bar"     > SOURCE/B
	echo "baz"     > SOURCE/C
	echo "bar"     > TARGET/B
	echo "foobar"  > TARGET/C
	echo "foo"     > TARGET/SOURCE/A
	echo "foobar"  > TARGET/SOURCE/B
}

tearDown() {
	rm -r SOURCE 2> /dev/null
	rm -r TARGET 2> /dev/null
}

test_error() {
	_EXITCODE="$EXITCODE"
	error "test" 2> /dev/null
	assertTrue '[ $EXITCODE -gt $_EXITCODE ]'
	unset _EXITCODE
	error "test" 2>&1 | grep "Error: test" > /dev/null
	assertTrue $?
}

test_usage() {
	usage 2>&1 | grep "Error: Invalid Options. See mv(1)." > /dev/null
	assertTrue $?
}

test__smvFileToFreeTarget() {
	_smv SOURCE/A TARGET/A
	assertTrue '[ ! -f SOURCE/A ] && [ "x$(cat TARGET/A)" = "xfoo" ]'
}

test__smvDirToFreeTarget() {
	_smv SOURCE TARGET/TARGET2
	assertTrue '[ ! -d SOURCE ] && [ -d TARGET/TARGET2 ]'
}

test__smvFileToFileMatching() {
	_smv SOURCE/B TARGET/B
	assertTrue '[ ! -f SOURCE/B ] && [ "x$(cat TARGET/B)" = "xbar" ] && [ ! -f "TARGET/B_*" ]'
}

test__smvFileToFileDiffering() {
	_smv SOURCE/C TARGET/C
	assertTrue '[ ! -f SOURCE/C ] && [ "x$(cat TARGET/C)" = "xfoobar" ] && [ "x$(cat TARGET/C_*)" = "xbaz" ]'
}

test__smvFileToDir() {
	_smv SOURCE/A TARGET
	assertTrue '[ ! -f SOURCE/A ] && [ -f TARGET/A ]'
}

test__smvFileToFileMatchingInDir() {
	_smv SOURCE/B TARGET
	assertTrue '[ ! -f SOURCE/B ] && [ "x$(cat TARGET/B)" = "xbar" ] && [ ! -f "TARGET/B_*" ]'
}

test__smvFileToFileDifferingInDir() {
	_smv SOURCE/C TARGET
	assertTrue '[ ! -f SOURCE/C ] && [ "x$(cat TARGET/C)" = "xfoobar" ] && [ "x$(cat TARGET/C_*)" = "xbaz" ]'
}

test__smvDirToFile() {
	_smv SOURCE TARGET/B
	assertTrue '[ ! -d SOURCE ] && [ "x$(cat TARGET/B_*/B)" = "xbar" ]'
}

test__smvDirToDirMatching() {
	_smv SOURCE TARGET/
	assertTrue '[ ! -d SOURCE ] && [ -f TARGET/SOURCE/A ] && [ -f TARGET/SOURCE/B ] && [ "x$(cat TARGET/SOURCE/B_*)" = "xbar" ] && [ -f TARGET/SOURCE/C ]'
}

test__srmTargetSameFileAsSource() {
	_srm SOURCE/A SOURCE/A
	assertTrue '[ -f SOURCE/A ]'
}

test__srmTargetSameContentsAsSource() {
	_srm SOURCE/B TARGET/B
	assertTrue '[ ! -f SOURCE/B ] && [ -f TARGET/B ] && [ -z "$(cat TARGET/B_*)" ]'
}

test_smvWithNoArguments() {
	"$TESTS_PATH"/../smv 2> /dev/null
	assertFalse $?
}

test_smvTooManyArgumentsWhenTargetIsFile() {
	"$TESTS_PATH"/../smv SOURCE/A SOURCE/B SOURCE/C 2> /dev/null
	assertFalse $?
}

test_smvSimpleExecution() {
	"$TESTS_PATH"/../smv SOURCE/A TARGET/A
	assertTrue $?
}

TESTS_PATH="$(pwd)/$(dirname "$0")"

. "$TESTS_PATH"/../smv 2> /dev/null

. "$TESTS_PATH"/shunit2
