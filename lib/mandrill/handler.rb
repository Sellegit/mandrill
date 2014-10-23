module Mandrill
  class MandrillDeliveryHandler
    attr_accessor :settings

    def initialize(options = {})
      self.settings = {:track_opens => true, :track_clicks => true, :from_name => 'Mandrill Email Delivery Handler'}.merge(options)
    end

    def deliver!(message)
      api_key = message.header['api-key'].blank? ? settings[:api_key] : message.header['api-key']
      
      message_payload = get_message_payload(message)
      self.settings[:return_response] = Mandrill::API.new(api_key).messages.send message_payload
    end
    
    private
    
    def get_content_for(message, format)
      mime_types = {
        :html => "text/html",
        :text => "text/plain"
      }
      
      content = message.send(:"#{format.to_s}_part")
      content ||= message.body if message.mime_type == mime_types[format]
      if content.respond_to? :raw_source
        content = content.raw_source
      end
      content
    end

    def get_message_payload(message)
      message_payload = {
        :track_opens => settings[:track_opens],
        :track_clicks => settings[:track_clicks],
        :subject => message.subject,
        :from_name => message.header['from-name'].blank? ? settings[:from_name] : message.header['from-name'],
        :from_email => message.from.first,
        :to => message.to.map {|email| { :email => email, :name => email } },
        :headers => {'Reply-To' => message.reply_to.nil? ? nil : message.reply_to }
      }
      message_payload[:bcc_address] = message.bcc.first if message.bcc && !message.bcc.empty?
      [:html, :text].each do |format|
        content = get_content_for(message, format)
        message_payload[format] = content if content
      end

      message_payload[:tags] = settings[:tags] if settings[:tags]
      if message.header['X-MC-Tags']
        message_payload[:tags] = message.header['X-MC-Tags'].value.split(',')
      end
      if message.header['X-MC-Subaccount']
        message_payload[:subaccount] = message.header['X-MC-Subaccount'].value.to_s
      end
      message_payload
    end
  end
end

if defined?(ActionMailer)
  ActionMailer::Base.add_delivery_method(:mandrill, Mandrill::MandrillDeliveryHandler)
end
