.PHONY: check package

check:
	tools/check.sh

package: check
	tools/package.sh
