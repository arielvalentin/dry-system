require 'logger'

module Dry
  module System
    module Plugins
      module Logging
        # @api private
        def self.extended(system)
          system.use :env

          system.setting :logger, reader: true

          system.setting :log_dir, 'log'.freeze

          system.setting :log_levels, {
                           development: Logger::DEBUG,
                           test: Logger::DEBUG,
                           production: Logger::INFO
                         }

          system.after(:configure, &:set_logger)

          super
        end

        # Set a logger
        #
        # This is invoked automatically when a container is being configured
        #
        # @return [self]
        #
        # @api private
        def set_logger
          if key?(:logger)
            self
          elsif config.logger
            register(:logger, config.logger)
          else
            config.logger = ::Logger.new(log_file_path)
            config.logger.level = config.log_levels.fetch(config.env, Logger::ERROR)
            register(:logger, config.logger)
            self
          end
        end

        # @api private
        def log_dir_path
          root.join(config.log_dir).realpath
        end

        # @api private
        def log_file_path
          log_dir_path.join(log_file_name)
        end

        # @api private
        def log_file_name
          "#{config.env}.log"
        end
      end
    end
  end
end