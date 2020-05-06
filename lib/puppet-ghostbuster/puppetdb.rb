require 'puppetdb'
require 'puppet'
require 'puppet/util/puppetdb'

class PuppetGhostbuster
  class PuppetDB
    Puppet.initialize_settings

    def self.client
      @@client ||= ::PuppetDB::Client.new({
        :server => "#{ENV['PUPPETDB_URL'] || Puppet::Util::Puppetdb.config.server_urls[0]}",
        :token => 'AJbRPfhwZNl9bO6fmgZbaIsTcCuHgRedNMuoJSjKSXFs',
        :cacert => '/home/erik/projects/puppet-ghostbuster/ca.pem'
        }
      }, 4)
    end

    def client
      self.class.client
    end

    def self.classes
      @@classes ||= client.request('', 'resources[title] { type = "Class" }').data.map { |r| r['title'] }.uniq
    end

    def classes
      self.class.classes
    end

    def self.resources
      @@resources ||= client.request('', 'resources[type] { nodes { deactivated is null } }').data.map { |r| r['type'] }.uniq
    end

    def resources
      self.class.resources
    end
  end
end
