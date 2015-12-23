#!/usr/bin/env ruby
# encoding: UTF-8
#
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'NetOxygen/SMS/Client'

user, password, dest, message = *ARGV
client = NetOxygen::SMS::Client.new(user, password)

die "mauvais utilisateur ou mot de passe" unless client.auth

res = client.send_message(dest, message)
id = res[0][2]
pp client.get_status(id)

puts "Il vous reste #{client.get_credits} crédits"
