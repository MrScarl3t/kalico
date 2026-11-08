# prtouch_v2 support - Creality vendor tree
# Source: /usr/share/klipper/klippy/extras/prtouch_v2.py from the K1 Max
# vendor firmware backup.  The actual probe logic lives in the MIPS-only
# shared objects prtouch_v1_wrapper / prtouch_v2_wrapper.  Those .so files
# are NOT included in this repository — they are copied from the printer's
# own /usr/share/klipper/klippy/extras/ at deploy time.  Without them this
# module will fail to import.
#
# Copyright (C) 2018-2021  Creality <wangyulong878@sina.com>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
from . import probe
from . import prtouch_v2_wrapper
from . import prtouch_v1_wrapper

def load_config(config):
    pr_version = config.getint('pr_version', default=1, minval=0, maxval=100)
    if pr_version == 2:
        vrt = prtouch_v2_wrapper.PRTouchEndstopWrapper(config)
    if pr_version == 1:
        vrt = prtouch_v1_wrapper.PRTouchEndstopWrapper(config)
    config.get_printer().add_object('probe', probe.PrinterProbe(config, vrt))
    return vrt
