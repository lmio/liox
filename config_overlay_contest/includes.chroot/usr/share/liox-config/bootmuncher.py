#!/usr/bin/env python3

import argparse
import re
import subprocess

def _get_boot_info():
    return subprocess.check_output("efibootmgr", encoding="utf-8").splitlines()

def _get_boot_order(info):
    _BO = "BootOrder: "
    for l in info:
        if l.startswith(_BO):
            return l.removeprefix(_BO).split(",")

def _get_boot_entries(info):
    _BRE = "Boot([0-9A-F]{4})"
    _BEX = "Boot0000  "
    entries = {}
    for l in info:
        m = re.match(_BRE, l)
        if m:
            entries[m.group(1)] = l[len(_BEX):].split("\t")[0]
    return entries

def _set_boot_order(order):
    subprocess.check_output(["efibootmgr", "-o", ",".join(order)])

def _is_pxe(entry):
    entry = entry.upper()
    return re.search("(PXE|IPV4|IPV6|PCI LAN)", entry)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="boot order manipulation")
    parser.add_argument("-n", "--dry-run", action="store_true",
                        help="don't perform any actions")
    parser.add_argument("pxedst", choices=["pxe-to-front", "pxe-to-back"],
                        help="where to put PXE in boot order")

    args = parser.parse_args()

    bi = _get_boot_info()
    bo = _get_boot_order(bi)
    be = _get_boot_entries(bi)

    is_pxe = lambda k: _is_pxe(be[k])
    is_not_pxe = lambda k: not is_pxe(k)
    nonpxe = list(filter(is_not_pxe, bo))
    pxe = list(filter(is_pxe, bo))

    if args.pxedst == "pxe-to-front":
        nbo = pxe + nonpxe
    else:
        nbo = nonpxe + pxe

    if args.dry_run:
        print("Current order:", ",".join(bo))
        print("Would set new boot order:", ",".join(nbo))
    else:
        _set_boot_order(nbo)
