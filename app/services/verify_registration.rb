# frozen_string_literal: true

require 'http'

module Credence
  # Send email verfification email
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    def initialize(config, registration)
      @config = config
      @registration = registration
    end

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def send_email_verification
      HTTP
        .auth("Bearer #{@config.SENDGRID_API_KEY}")
        .post(
          @config.SENDGRID_URL,
          json: email_hash
        )
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end

    def email_hash
      {
        personalizations: email_recipient,
        from:             email_sender,
        subject:          'Credent Registration Verification',
        content:          email_content
      }
    end

    def email_recipient
      [{ to: [{ 'email' => @registration[:email] }] }]
    end

    def email_sender
      { 'email' => 'noreply@credentia.com' }
    end

    def email_content
      [{ type: 'text/html', value: email_body }]
    end

    def email_body
      verification_url = @registration[:verification_url]

      <<~END_EMAIL
        <H1>Credentia Registration Received<H1>
        <p>Please <a href=\"#{verification_url}\">click here</a> to validate your
        email. You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end
  end
end
