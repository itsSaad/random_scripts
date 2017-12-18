#!/usr/bin/ruby
require 'netaddr'
require "pry"
require 'resolv'

def ip_belongs_to_google?(ip)
  begin
    reversed_dns = Resolv.new.getname ip
    if reversed_dns.downcase.include?('google') || reversed_dns.downcase.include?('googlebot')
      matched_ip = Resolv.getaddress ip
      if matched_ip == ip
        open('google_ips', 'a') { |f| f << "#{ip}\n" }
        true
      end
      false
    end
    false
  rescue Resolv::ResolvError => err
    print "e"
    false
  end
end

def ip_is_range?(ip)
  ip.class == String and ip.include?('/') and not ip.include?('/32')
end

ip_list = File.read('ip_list.txt').split("\n")
google_owned_ips = []
ip_list.each do |ip_range|
  if ip_is_range?(ip_range)
    #We got a range. Surprise !!!
    #Lets go mad...
    NetAddr::CIDR.create(ip_range).enumerate.each do |ip|
      if ip_belongs_to_google?(ip)
        google_owned_ips << ip
        next
      end
    end
  else
    ip = ip_range.split("/")[0]
    if ip_belongs_to_google?(ip_range) then google_owned_ips.append(ip) end
  end
end
