@testset "IP" begin

@testset "decode" begin
    ep = decode_ethernet(dns_packet)
    ipp = decode_ipv4(ep.payload)
    @test ipp.header.header_length == 20
    @test ipp.header.dscp == 0
    @test ipp.header.total_length == 68
    @test ipp.header.id == 0xad0b
    @test ipp.header.flags == 0
    @test ipp.header.fragment_offset == 0
    @test ipp.header.ttl == 64
    @test ipp.header.protocol == IPPROTOCOL_UDP
    @test ipp.header.src_ip == ip"172.20.2.253"
    @test ipp.header.dst_ip == ip"172.20.0.6"
    @test length(ipp.payload) == 48
end

@testset "ismulticast" begin
    @test all(ismulticast(addr) for addr in multicast_addresses)
    @test all(!ismulticast(addr) for addr in non_multicast_addresses)
end

end
