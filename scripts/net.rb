require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

template = File.read("../template/servers.json")
ca = File.read("../static/ca.pem")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 4)

cfg = {
  ca: ca,
  tlsWrap: tls_wrap,
  cipher: "AES-256-CBC",
  digest: "SHA512",
  compressionFraming: 0,
  keepAliveInterval: 15,
  keepAliveTimeout: 60,
  renegotiatesAfter: 0,
  checksEKU: true
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:1194",
      "TCP:1443"
    ]
  }
}

presets = [
  recommended
]

defaults = {
  :username => "4HJbkSABosB028",
  :country => "US"
}

###

servers = []

json = JSON.parse(template)
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
    hostname = cluster["connectionName"]
    id = hostname.split(".").first
    extraCountry = cluster["countryCode"]
  end

  server = {
    :id => id,
    :country => code,
    :hostname => hostname,
    :addrs => addresses
  }
  if extraCountry.nil?
    server[:area] = area if !area.empty?
  else
    server[:category] = "transit"
    server[:extra_countries] = [extraCountry.upcase]
  end
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
