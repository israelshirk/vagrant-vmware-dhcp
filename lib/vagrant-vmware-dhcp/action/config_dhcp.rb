require "log4r"
require "digest"

# Someone who's had some sleep recently is welcome to come fill in comments here...
module VagrantPlugins
  module VagrantVmwareDhcp
    module Action
      class ConfigDhcp
        def initialize(app, env)
          @app    = app
          @env    = env
          @logger = Log4r::Logger.new("vagrant::plugins::vagrant-vmware-dhcp::config_dhcp")
        end

        def call(env)
          @env = env

          if @env[:machine]
            if @env[:machine].provider_name == :vmware_fusion or @env[:machine].provider_name == :vmware_workstation
              configure_dhcp(@env[:machine])
            end
          end

          @app.call(@env)
        end

        private

        def configure_dhcp(machine)
          # dhcp_manager = VagrantPlugins::VagrantVmwareDhcp::DhcpManager.new(@env[:ui], @logger, machine)
          dhcp_manager = get_dhcp_manager(machine)

          dhcp_manager.prune()

          if machine.config.control_dhcp.enable
            dhcp_manager.configure()
          end

          dhcp_manager.reload()
        end

        def get_dhcp_manager(machine)
          if Vagrant::Util::Platform.windows?
            return VagrantPlugins::VagrantVmwareDhcp::DhcpManagerWindows.new(@env[:ui], @logger, machine)
          elsif Vagrant::Util::Platform.linux?
            return VagrantPlugins::VagrantVmwareDhcp::DhcpManagerLinux.new(@env[:ui], @logger, machine)
          elsif Vagrant::Util::Platform.darwin?
            return VagrantPlugins::VagrantVmwareDhcp::DhcpManagerDarwin.new(@env[:ui], @logger, machine)
          end
        end

      end
    end
  end
end
