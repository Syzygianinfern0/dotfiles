ALL_FOLDERS = $(wildcard */)
HEADLESS_FOLDERS = headless/

all:
	stow --verbose --target=$$HOME --restow $(ALL_FOLDERS)

headless:
	stow --verbose --target=$$HOME --restow $(HEADLESS_FOLDERS)

clean:
	stow --verbose --target=$$HOME --delete */

.PHONY: all headless clean
