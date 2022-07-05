require 'logger'
require 'raven'

if ENV['AIRBRAKE_PROJECT_ID'] && ENV['AIRBRAKE_PROJECT_KEY']
  require 'airbrake'

  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_PROJECT_ID']
    c.project_key = ENV['AIRBRAKE_PROJECT_KEY']
  end
end

module DataDuck
  module Logs
    @@ONE_MB_IN_BYTES = 1048576

    @@logger = nil

    def Logs.ensure_logger_exists!
      log_file_path = DataDuck.project_root + '/log/dataduck.log'
      DataDuck::Util.ensure_path_exists!(log_file_path)
      @@logger ||= Logger.new(log_file_path, shift_age = 100, shift_size = 100 * @@ONE_MB_IN_BYTES)
    end


    def self.load_config!
      logging_config = DataDuck.config['dataduck_logging']

      log_file_path = DataDuck.project_root + '/log/dataduck.log'
      log_datetime_format = '%Y/%m/%d %H:%M:%S'
      unless logging_config.nil?
        unless logging_config['path'].nil?
          log_file_path = logging_config['path']
        end
        unless logging_config['datetime_format'].nil?
          log_datetime_format = logging_config['datetime_format']
        end
      end

      logger = Logger.new(log_file_path, shift_age = 100, shift_size = 100 * @@ONE_MB_IN_BYTES)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime.strftime(log_datetime_format)} [#{severity}] #{msg}\n"
      end

      @@logger = logger
    end

    def Logs.debug(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)
      @@logger.debug(message)
    end

    def Logs.info(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)
      @@logger.info(message)
    end

    def Logs.warn(message)
      self.ensure_logger_exists!
      message = Logs.sanitize_message(message)
      @@logger.warn(message)
    end

    def Logs.error(err, message = nil)
      self.ensure_logger_exists!
      message = err.to_s unless message
      message = Logs.sanitize_message(message)
      @@logger.error(message)

      Logs.third_party_error_tracking!(err)
    end

    private

      def Logs.third_party_error_tracking!(err)
        if ENV['SENTRY_DSN']
          Raven.capture_exception(err)
        end

        if ENV['AIRBRAKE_PROJECT_ID'] && ENV['AIRBRAKE_PROJECT_KEY']
          Airbrake.notify_sync(err)
        end
      end

      def Logs.sanitize_message(message)
        message = message.gsub(/aws_access_key_id=[^';]+/, "aws_access_key_id=******")
        message = message.gsub(/AWS_ACCESS_KEY_ID=[^';]+/, "AWS_ACCESS_KEY_ID=******")
        message = message.gsub(/aws_secret_access_key=[^';]+/, "aws_secret_access_key=******")
        message = message.gsub(/AWS_SECRET_ACCESS_KEY=[^';]+/, "AWS_SECRET_ACCESS_KEY=******")
        message = message.gsub("\n", '') # Remove newlines for elk
        message
      end
  end
end
