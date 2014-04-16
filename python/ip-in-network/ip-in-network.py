#!/usr/bin/env python

import socket
import struct

def ip_in_network(mask, address):

    mask_address, mask_bits = mask.split("/",1)
    bit_val     = 2 ** 31
    mask_val    = 0

    for n in xrange(int(mask_bits)):
        if bit_val < 1:
            break
        mask_val += bit_val
        bit_val /= 2

    mask_map    = socket.inet_ntoa(
        struct.pack(
            "!I", struct.unpack(
                "!I", socket.inet_aton(address)
            )[0] & mask_val
        )
    )

    return mask_address == mask_map

if __name__ == '__main__':
    print ip_in_network("10.0.0.0/8", "10.1.2.3")
    print ip_in_network("10.0.0.0/16", "10.1.2.3")
    print ip_in_network("192.168.0.0/16", "192.168.1.2")
