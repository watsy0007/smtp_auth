require 'net/smtp'
module SMTPAuth
  class << self
    attr_accessor :smtp
    attr_accessor :logger

    def config(&block)
      block.call(self) if block_given?
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def auth(user_name, password, &block)
      net_smtp = Net::SMTP.new smtp['smtp'], smtp['port']
      net_smtp.enable_starttls
      net_smtp.start(smtp['domain'], user_name, password, smtp['type'] || :login) { |_smtp| block.call(true) if block_given? }
      true
    rescue => e
      logger.error("authorize '#{user_name}' error, smtp: #{smtp.to_json}, error info: #{e}")
      block_given? ? block.call(false) : false
    end
  end
end
