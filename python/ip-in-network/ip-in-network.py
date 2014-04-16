#!/usr/bin/env python

import socket
import struct

def ip_in_network(mask, address):

    mask_address, mask_bits = mask.split("/",1)

    mask_map    = socket.inet_ntoa(
        struct.pack(
            "!I", struct.unpack("!I", socket.inet_aton( address )
        )[0] & int(
                "{0}{1}".format(
                    '1' * int(mask_bits),
                    '0' * (32 - int(mask_bits))
                ), 2
            )
        )
    )

    return mask_address == mask_map

if __name__ == '__main__':
    print ip_in_network("10.0.0.0/8", "10.1.2.3")
    print ip_in_network("10.0.0.0/16", "10.1.2.3")

