#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
import json
import types
import struct
#os.environ['PYUSB_DEBUG'] = 'debug'

from ykman.descriptor import get_descriptors
from ykman.util import CAPABILITY, TRANSPORT, Mode, modhex_encode
from binascii import b2a_hex

NON_FEATURE_CAPABILITIES = [CAPABILITY.CCID, CAPABILITY.NFC]

import ctypes.util
def find_library(libname):
    if os.path.isfile(libname):
        return libname
    return ctypes.util.find_library(libname)

import usb.backend.libusb1
backend = usb.backend.libusb1.get_backend(find_library=find_library)

def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped


class Controller(object):
    _descriptor = None
    _dev_info = None

    def __init__(self):
        # Wrap all return values as JSON.
        for f in dir(self):
            if not f.startswith('_'):
                func = getattr(self, f)
                if isinstance(func, types.MethodType):
                    setattr(self, f, as_json(func))

    def get_features(self):
        return [c.name for c in CAPABILITY if c not in NON_FEATURE_CAPABILITIES]

    def count_devices(self):
        return len(list(get_descriptors()))

    def refresh(self):
        descriptors = list(get_descriptors())
        if len(descriptors) != 1:
            self._descriptor = None
            return

        desc = descriptors[0]
        if desc.fingerprint != (self._descriptor.fingerprint if self._descriptor else None):
            dev = desc.open_device()
            self._dev_info = {
                'name': dev.device_name,
                'version': '.'.join(str(x) for x in dev.version),
                'serial': dev.serial or '',
                'enabled': [c.name for c in CAPABILITY if c & dev.enabled],
                'connections': [t.name for t in TRANSPORT if t & dev.capabilities]
            }
            self._descriptor = desc

        return self._dev_info

    def set_mode(self, connections):
        dev = self._descriptor.open_device()
        try:
            transports = sum([TRANSPORT[c] for c in connections])
            dev.mode = Mode(transports & TRANSPORT.usb_transports())
        except Exception as e:
            return str(e)
        return None

    def slots_status(self):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        return dev.driver.slot_status

    def erase_slot(self, slot):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        dev.driver.zap_slot(slot)

    def swap_slots(self):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        dev.driver.swap_slots()

    def serial_modhex(self):
        dev = self._descriptor.open_device(TRANSPORT.OTP)
        return modhex_encode(b'\xff\x00' + struct.pack(b'>I', dev.serial))

    def random_uid(self):
        return b2a_hex(os.urandom(6)).decode('ascii')

    def random_key(self):
        return b2a_hex(os.urandom(16)).decode('ascii')

controller = Controller()
