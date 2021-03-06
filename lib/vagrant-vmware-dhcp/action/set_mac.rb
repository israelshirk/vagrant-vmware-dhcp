require "log4r"
require "digest"

module VagrantPlugins
  module VagrantVmwareDhcp
    module Action
      class SetMac
        def initialize(app, env)
          @app       = app
          @env       = env
          @logger    = Log4r::Logger.new("vagrant::plugins::vagrant-vmware-dhcp::set_mac")
        end

        def call(env)
          @env = env

          if @env[:machine]
            if (@env[:machine].provider_name == :vmware_fusion or @env[:machine].provider_name == :vmware_workstation)
              set_mac_address(@env)
            end
          end

          @app.call(@env)
        end

        private

        def set_mac_address(env)
          machine = env[:machine]

          networks = machine.config.vm.networks.select { |network| network[0] == :private_network and network[1][:ip] and not network[1][:mac] }

          networks.each { |network| network[1][:mac] = mac_from_ip(network[1][:ip]) }

          @logger.info("Added MAC addresses for #{networks}")
        end

        def mac_from_ip(ip)
          sha = Digest::SHA256.hexdigest ip

          # VMWare doesn't like odd values for the first octet.
          mac = "AA" + sha.scan(/.{10}/)[0]

          mac
        end
      end
    end
  end
end
