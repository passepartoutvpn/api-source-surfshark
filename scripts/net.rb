require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

servers = File.read("../static/servers.json")
ca = File.read("../static/ca.pem")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 4)

cfg = {
    ca: ca,
    wrap: tls_wrap,
    cipher: "AES-256-CBC",
    auth: "SHA512",
    frame: 0,
    ping: 15,
    pingTimeout: 60,
    reneg: 0,
    eku: true
}

external = {
  hostname: "${id}.prod.surfshark.com"
}

recommended_cfg = cfg.dup
recommended_cfg["ep"] = [
    "UDP:1194",
    "TCP:1443"
]
recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: recommended_cfg,
    external: external
}

presets = [
    recommended
]

defaults = {
    :username => "4HJbkSABosB028",
    :pool => "us",
    :preset => "default"
}

###

pools = []

json = JSON.parse(servers)
json.each { |country|
    hostname = country["connectionName"]
    id = hostname.split(".").first
    code = country["countryCode"].upcase
    area = country["location"]

	addresses = nil
    if ARGV.include? "noresolv"
        addresses = []
        #addresses = ["1.2.3.4"]
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    cluster = country["transitCluster"]
    extraCountry = nil
    if !cluster.nil?
        extraCountry = cluster["countryCode"]
    end

    pool = {
        :id => id,
        :country => code,
        :hostname => hostname,
        :addrs => addresses
    }
    if extraCountry.nil?
        pool[:area] = area if !area.empty?
    else
        pool[:category] = "transit"
        pool[:extra_countries] = [extraCountry.upcase]
    end
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
