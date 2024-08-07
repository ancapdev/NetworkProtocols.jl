struct IPv4HeaderRaw
    version_ihl::UInt8
    dscp_ecn::UInt8
    total_length::UInt16
    id::UInt16
    flags_fragmentoffset::UInt16
    ttl::UInt8
    protocol::UInt8
    header_checksum::UInt16
    src_ip::UInt32
    dst_ip::UInt32
end

const IPPROTOCOL_IGMP = UInt8(0x02)
const IPPROTOCOL_TCP = UInt8(0x06)
const IPPROTOCOL_UDP = UInt8(0x11)

struct IPv4Header
    header_length::UInt8
    dscp::UInt8
    total_length::UInt16
    id::UInt16
    flags::UInt8
    fragment_offset::UInt16
    ttl::UInt8
    protocol::UInt8
    src_ip::IPv4
    dst_ip::IPv4
end

struct IPv4Packet
    header::IPv4Header
    payload::UnsafeArray{UInt8, 1}
end

function decode_ipv4(data::DenseVector{UInt8})
    p = Base.unsafe_convert(Ptr{UInt8}, data)
    GC.@preserve data begin
        rh = unsafe_load(convert(Ptr{IPv4HeaderRaw}, p))
    end
    h = IPv4Header(
        (rh.version_ihl & 0x0f) * 4,
        rh.dscp_ecn >> 2,
        ntoh(rh.total_length),
        ntoh(rh.id),
        ntoh(rh.flags_fragmentoffset) >> 13,
        (ntoh(rh.flags_fragmentoffset) & 0x1fff) * 8,
        rh.ttl,
        rh.protocol,
        IPv4(ntoh(rh.src_ip)),
        IPv4(ntoh(rh.dst_ip)))
    IPv4Packet(
        h,
        UnsafeArray{UInt8, 1}(
            p + h.header_length,
            (Int(h.total_length - h.header_length),)))
end

function ismulticast(ip::IPv4)
    ip"224.0.0.0" <= ip <= ip"239.255.255.255"
end
