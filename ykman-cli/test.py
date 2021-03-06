#!/usr/bin/env python3

from subprocess import check_output
import re


def main():
    out = check_output(['./ykman', '-v'], timeout=10)
    print('ykman')
    print(out.decode('utf8'))

    assert re.search(br'libykpers\s+(1\.\d+\.\d+)', out)
    assert re.search(br'libusb', out)


if __name__ == '__main__':
    main()
