require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

ca = File.read("../static/ca.pem")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 4)
countries = ["US", "FR", "DE", "ES", "IT"]
bogus_ip_prefix = "1.2.3"

cfg = {
    ep: [
        "UDP:1194",
        "TCP:443",
    ],
    frame: 1,
    ping: 60,
    reneg: 3600
}

recommended_cfg = cfg.dup
recommended_cfg["ca"] = ca
recommended_cfg["cipher"] = "AES-128-GCM"
recommended_cfg["auth"] = "SHA1"
recommended_cfg["wrap"] = tls_wrap

recommended = {
    id: "default",
    name: "Default",
    comment: "128-bit encryption",
    cfg: recommended_cfg
}
presets = [recommended]

defaults = {
    :username => "myusername",
    :pool => "us",
    :preset => "default"
}

###

pools = []
countries.each { |k|
    id = k.downcase
    hostname = "#{id}.sample-vpn-provider.bogus"

    addresses = nil
    if ARGV.length > 0 && ARGV[0] == "noresolv"
        addresses = []
    else
        #addresses = Resolv.getaddresses(hostname)
        addresses = []
        octet = 1
        5.times {
            ip = "#{bogus_ip_prefix}.#{octet}"
            addresses << ip
            octet += 1
        }
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    pool = {
        :id => id,
        :name => "Sample #{k}",
        :country => k,
        :hostname => hostname,
        :addrs => addresses
    }
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
